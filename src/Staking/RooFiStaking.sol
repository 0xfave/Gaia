// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.23;

import { Ownable } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract StakingContract is Ownable, Pausable, IERC721Receiver {
    struct Staker {
        uint64 amountStaked;
        uint64 conditionIdOflastUpdate;
        uint128 timeOfLastUpdate;
        uint256 unclaimedRewards;
    }

    struct StakingCondition {
        uint256 timeUnit;
        uint256 rewardsPerUnitTime;
        uint256 startTimestamp;
        uint256 endTimestamp;
    }

    string public collectionName;
    string public description;
    IERC721 public collectionAddress;
    address public rewardTokenAddress;
    uint256 public stakingFee;

    IERC20 public rewardToken;

    /// @dev List of accounts that have staked their NFTs.
    address[] public stakersArray;

    ///@dev List of token-ids ever staked.
    uint256[] public indexedTokens;

    ///@dev Next staking condition Id. Tracks number of conditon updates so far.
    uint64 private nextConditionId;

    /// @dev Total amount of reward tokens in the contract.
    uint256 private rewardTokenBalance;

    /// @dev Mapping from staked token-id to staker address.
    mapping(uint256 _tokenIds => address stakers) public stakerAddress;

    /// @dev Flag to check direct transfers of staking tokens.
    uint8 internal isStaking = 1;

    ///@dev Mapping from token-id to whether it is indexed or not.
    mapping(uint256 _tokenIds => bool) public isIndexed;

    ///@dev Mapping from staker address to Staker struct. See {struct IStaking721.Staker}.
    mapping(address staker => Staker) public stakers;

    ///@dev Mapping from condition Id to staking condition. See {struct IStaking721.StakingCondition}
    mapping(uint256 _tokenIds => StakingCondition) private stakingConditions;

    // Reward distribution parameters
    // uint256 public poolRate;
    // uint256 public totalRewards;
    // uint256 public rewardsDuration;
    // uint256 public rewardRate;

    /// @dev Emitted when contract admin updates rewardsPerUnitTime.
    event UpdatedRewardsPerUnitTime(uint256 oldRewardsPerUnitTime, uint256 newRewardsPerUnitTime);
    event NFTStaked(uint256);
    /// @dev Emitted when contract admin updates timeUnit.
    event UpdatedTimeUnit(uint256 oldTimeUnit, uint256 newTimeUnit);
    ///
    event UpdatedEndTimestamp(uint256 oldEndTimestamp, uint256 newEndTimeStamp);

    ///
    event RewardTokensDeposited(uint256 amountDeposited);

    ///
    event ERC20Recovered(address indexed tokenAddress, address indexed recipient, uint256 amount);

    /// @dev Emitted when a set of staked token-ids are withdrawn.
    event TokensWithdrawn(address indexed staker, uint256[] indexed tokenIds);

    /// @dev Emitted when a staker claims staking rewards.
    event RewardsClaimed(address indexed staker, uint256 rewardAmount);

    error RoofiStake_AmountTooLow(uint256);
    error RooFine_BalanceTooLow(uint256);
    error RoofiStake_EmptyCollectionName();
    error RoofiStake_EmptyDescription();
    error RoofiStake_AddressCantBeZero();
    error RoofiStake_InvalidStakingFee();
    error RoofiStake_StakingEnded();
    error RoofiStake_UnstakeAmountTooHigh();
    error RoofiStake_NoNFTToUnStake();
    error RooFine_HasNoEndTime();
    error Roofi_NotStaker();
    error Roofi_NoStakingCondition();
    error Roofi_InvalidTimeUnit();

    constructor(
        string memory _collectionName,
        string memory _description,
        address _collectionAddress,
        address _rewardTokenAddress,
        uint256 _stakingFee,
        address initialOwner,
        uint256 _timeUnit,
        uint256 _rewardsPerUnitTime,
        uint256 _endDate
    )
        Ownable(initialOwner)
    {
        // Ensure parameters are not empty or zero
        if (bytes(_collectionName).length == 0) revert RoofiStake_EmptyCollectionName();
        if (bytes(_description).length == 0) revert RoofiStake_EmptyDescription();
        if (_collectionAddress == address(0)) revert RoofiStake_AddressCantBeZero();
        if (_rewardTokenAddress == address(0)) revert RoofiStake_AddressCantBeZero();
        if (_stakingFee < 0) revert RoofiStake_InvalidStakingFee();

        // Initialize contract state variables with provided values
        collectionName = _collectionName;
        description = _description;
        collectionAddress = IERC721(_collectionAddress);
        rewardTokenAddress = _rewardTokenAddress;
        stakingFee = _stakingFee;

        _setStakingCondition(_timeUnit, _rewardsPerUnitTime, _endDate);
    }

    function stakeTokens(uint256[] calldata _tokenIds) external whenNotPaused {
        uint64 len = uint64(_tokenIds.length);
        if (len > 0) revert RoofiStake_AmountTooLow(len);
        if (collectionAddress.balanceOf(msg.sender) >= len) revert RooFine_BalanceTooLow(len);

        if (stakers[msg.sender].amountStaked > 0) {
            _updateUnclaimedRewardsForStaker(msg.sender);
        } else {
            stakersArray.push(msg.sender);
            stakers[msg.sender].timeOfLastUpdate = uint128(block.timestamp);
            stakers[msg.sender].conditionIdOflastUpdate = nextConditionId - 1;
        }

        for (uint256 i = 0; i < len; ++i) {
            isStaking = 2;
            collectionAddress.safeTransferFrom(msg.sender, address(this), _tokenIds[i]);
            isStaking = 1;

            stakerAddress[_tokenIds[i]] = msg.sender;

            if (!isIndexed[_tokenIds[i]]) {
                isIndexed[_tokenIds[i]] = true;
                indexedTokens.push(_tokenIds[i]);
            }
        }
        stakers[msg.sender].amountStaked += len;

        emit NFTStaked(len);
    }

    function unStake(uint256[] calldata _tokenIds) external {
        uint256 _amountStaked = stakers[msg.sender].amountStaked;
        uint64 len = uint64(_tokenIds.length);
        if (len == 0) revert RoofiStake_NoNFTToUnStake();
        if (_amountStaked > len) revert RoofiStake_UnstakeAmountTooHigh();

        _updateUnclaimedRewardsForStaker(msg.sender);

        if (_amountStaked == len) {
            address[] memory _stakersArray = stakersArray;
            for (uint256 i = 0; i < _stakersArray.length; ++i) {
                if (_stakersArray[i] == msg.sender) {
                    stakersArray[i] = _stakersArray[_stakersArray.length - 1];
                    stakersArray.pop();
                    break;
                }
            }
        }
        stakers[msg.sender].amountStaked -= len;

        for (uint256 i = 0; i < len; ++i) {
            if (stakerAddress[_tokenIds[i]] != msg.sender) revert Roofi_NotStaker();
            stakerAddress[_tokenIds[i]] = address(0);
            collectionAddress.safeTransferFrom(address(this), msg.sender, _tokenIds[i]);
        }

        emit TokensWithdrawn(msg.sender, _tokenIds);
    }

    function setRewardsPerUnitTime(uint256 _rewardsPerUnitTime) external onlyOwner {
        StakingCondition memory condition = stakingConditions[nextConditionId - 1];
        require(_rewardsPerUnitTime != condition.rewardsPerUnitTime, "Reward unchanged.");

        _setStakingCondition(condition.timeUnit, _rewardsPerUnitTime, condition.endTimestamp);

        emit UpdatedRewardsPerUnitTime(condition.rewardsPerUnitTime, _rewardsPerUnitTime);
    }

    function setTimeUnit(uint256 _timeUnit) external onlyOwner {
        StakingCondition memory condition = stakingConditions[nextConditionId - 1];
        require(_timeUnit != condition.timeUnit, "Time-unit unchanged.");

        _setStakingCondition(_timeUnit, condition.rewardsPerUnitTime, condition.endTimestamp);

        emit UpdatedTimeUnit(condition.timeUnit, _timeUnit);
    }

    function setEndTimeStamp(uint256 _endTimestamp) external onlyOwner {
        StakingCondition memory condition = stakingConditions[nextConditionId - 1];
        _endTimestamp = block.timestamp + _endTimestamp;
        require(_endTimestamp != condition.endTimestamp, "Time-unit unchanged.");

        _setStakingCondition(condition.timeUnit, condition.rewardsPerUnitTime, _endTimestamp);

        emit UpdatedEndTimestamp(condition.endTimestamp, _endTimestamp);
    }

    function depositRewardTokens(uint256 _amount) external onlyOwner {
        require(_amount > 0, "Amount must be greater than 0");

        // Assuming rewardToken is an ERC20 token
        require(rewardToken.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");

        // Update the totalRewards variable or any other relevant state variables
        rewardTokenBalance += _amount;

        // Emit an event indicating the successful deposit
        emit RewardTokensDeposited(_amount);
    }

    function _updateUnclaimedRewardsForStaker(address _staker) internal virtual {
        uint256 rewards = _calculateRewards(_staker);
        stakers[_staker].unclaimedRewards += rewards;
        stakers[_staker].timeOfLastUpdate = uint128(block.timestamp);
        stakers[_staker].conditionIdOflastUpdate = nextConditionId - 1;
    }

    function _calculateRewards(address _staker) internal view returns (uint256 _rewards) {
        Staker memory staker = stakers[_staker];

        uint256 _stakerConditionId = staker.conditionIdOflastUpdate;
        uint256 _nextConditionId = nextConditionId;

        for (uint256 i = _stakerConditionId; i < _nextConditionId; i += 1) {
            StakingCondition memory condition = stakingConditions[i];

            uint256 startTime = i != _stakerConditionId ? condition.startTimestamp : staker.timeOfLastUpdate;
            uint256 endTime = condition.endTimestamp != 0 ? condition.endTimestamp : block.timestamp;

            uint256 rewardsProduct = (endTime - startTime) * staker.amountStaked * condition.rewardsPerUnitTime;
            uint256 rewardsPerTimeUnit = rewardsProduct / condition.timeUnit;

            _rewards += rewardsPerTimeUnit;
        }

        return _rewards;
    }

    function _setStakingCondition(uint256 _timeUnit, uint256 _rewardsPerUnitTime, uint256 _endTime) internal {
        require(_timeUnit != 0, "time-unit can't be 0");
        uint256 conditionId = nextConditionId;
        nextConditionId += 1;

        stakingConditions[conditionId] = StakingCondition({
            timeUnit: _timeUnit,
            rewardsPerUnitTime: _rewardsPerUnitTime,
            startTimestamp: block.timestamp,
            endTimestamp: block.timestamp + _endTime
        });

        if (conditionId > 0) {
            stakingConditions[conditionId - 1].endTimestamp = block.timestamp;
        }
    }

    function getStakeInfo(address _staker) external view returns (uint256[] memory _tokensStaked, uint256 _rewards) {
        uint256[] memory _indexedTokens = indexedTokens;
        bool[] memory _isStakerToken = new bool[](_indexedTokens.length);
        uint256 indexedTokenCount = _indexedTokens.length;
        uint256 stakerTokenCount = 0;

        for (uint256 i = 0; i < indexedTokenCount; i++) {
            _isStakerToken[i] = stakerAddress[_indexedTokens[i]] == _staker;
            if (_isStakerToken[i]) stakerTokenCount += 1;
        }

        _tokensStaked = new uint256[](stakerTokenCount);
        uint256 count = 0;
        for (uint256 i = 0; i < indexedTokenCount; i++) {
            if (_isStakerToken[i]) {
                _tokensStaked[count] = _indexedTokens[i];
                count += 1;
            }
        }

        _rewards = _availableRewards(_staker);
    }

    /// @dev View available rewards for a user.
    function _availableRewards(address _user) internal view virtual returns (uint256 _rewards) {
        if (stakers[_user].amountStaked == 0) {
            _rewards = stakers[_user].unclaimedRewards;
        } else {
            _rewards = stakers[_user].unclaimedRewards + _calculateRewards(_user);
        }
    }

    function claimReward() external {
        uint256 rewards = stakers[msg.sender].unclaimedRewards + _calculateRewards(msg.sender);

        require(rewards != 0, "No rewards");

        stakers[msg.sender].timeOfLastUpdate = uint128(block.timestamp);
        stakers[msg.sender].unclaimedRewards = 0;
        stakers[msg.sender].conditionIdOflastUpdate = nextConditionId - 1;

        require(rewardToken.transfer(msg.sender, rewards), "Token transfer failed");

        emit RewardsClaimed(msg.sender, rewards);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    )
        external
        override
        whenNotPaused
        returns (bytes4)
    {
        require(isStaking == 2, "Direct transfer");
        // Handle ERC721 token reception logic here
        return IERC721Receiver.onERC721Received.selector;
    }

    function recoverERC20(address _tokenAddress, uint256 _amount) public onlyOwner {
        if (_tokenAddress == address(0)) revert RoofiStake_AddressCantBeZero();
        if (_amount < 0) revert RoofiStake_AmountTooLow(_amount);
        if (_tokenAddress == address(rewardToken)) {
            uint256 amountToSend = rewardToken.balanceOf(address(this)) - rewardTokenBalance;

            require(IERC20(_tokenAddress).transfer(owner(), amountToSend), "Token transfer failed");
        } else {
            // Check the balance of the token
            uint256 tokenBalance = IERC20(_tokenAddress).balanceOf(address(this));

            // Ensure the amount to recover does not exceed the token balance
            require(_amount <= tokenBalance, "Amount exceeds token balance");

            // Transfer the tokens to the owner
            require(IERC20(_tokenAddress).transfer(owner(), _amount), "Token transfer failed");
        }
        // Emit an event indicating the successful recovery
        emit ERC20Recovered(_tokenAddress, owner(), _amount);
    }

    function getStakersCount() external view returns (uint256) {
        return stakersArray.length;
    }

    function totalStaked() external view returns (uint256) {
        uint256 totalStakedAmount = 0;

        for (uint256 i = 0; i < stakersArray.length; i++) {
            totalStakedAmount += stakers[stakersArray[i]].amountStaked;
        }

        return totalStakedAmount;
    }

    function poolRate() external view returns (uint256) {
        // Get the total amount staked
        uint256 totalStakedAmount = this.totalStaked();

        // Ensure there is at least one staking condition
        if (nextConditionId == 0) revert Roofi_NoStakingCondition();

        // Get the details of the latest staking condition
        StakingCondition memory latestCondition = stakingConditions[nextConditionId - 1];

        // Check if the staking condition has a time unit
        if (latestCondition.timeUnit <= 0) revert Roofi_InvalidTimeUnit();

        // Calculate the pool rate by multiplying total staked amount with rewards per unit time
        uint256 rate = (totalStakedAmount * latestCondition.rewardsPerUnitTime) / latestCondition.timeUnit;

        return rate;
    }

    function rewardDuration() external view returns (uint256) {
        uint256 currentConditionId = nextConditionId - 1;

        // Ensure there is at least one staking condition
        if (currentConditionId == 0) revert Roofi_NoStakingCondition();

        StakingCondition memory currentCondition = stakingConditions[currentConditionId];

        // Check if the current staking condition has an end timestamp
        if (currentCondition.endTimestamp == 0) revert RooFine_HasNoEndTime();

        // Calculate the remaining duration until the end of the current staking condition
        uint256 remainingDuration = currentCondition.endTimestamp - block.timestamp;

        // Ensure the remaining duration is non-negative
        if (remainingDuration <= 0) revert RoofiStake_StakingEnded();

        return remainingDuration;
    }
}
