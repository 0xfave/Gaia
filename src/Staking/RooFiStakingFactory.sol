// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.23;

import { Ownable } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { StakingContract } from "./RooFiStaking.sol";

/**
 * @title RooFi Staking Factory
 * @author RooFi
 * @notice This is the contract in charge of deploying staking contracts for other nft collections
 */
contract FactoryContract is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 public fee;
    EnumerableSet.AddressSet private deployedContracts;

    event ContractDeployed(address indexed newContract);
    event FundsWithdrawn(uint256 indexed amount);

    error Roofi_NotEnoughEtherToCoverFee();
    error Roofi_NoEtherToWithdraw(uint256 amount);

    /**
     * @param _fee The fee to be paid before usage
     */
    constructor(uint256 _fee) Ownable(msg.sender) {
        fee = _fee;
    }

    /**
     * @notice updates the fee and can only be called by the owner
     * @param _newFee The new fee
     */
    function updateFee(uint256 _newFee) external onlyOwner {
        fee = _newFee;
    }

    /**
     * @notice deploys new staking contract
     * @param _collectionName This is the name of the nft collection to be staked
     * @param _description This is the description to be shown when the contract is called
     * @param _collectionAddress NFT collection address to be staked
     * @param _rewardTokenAddress The reward token address
     * @param _stakingFee the fee to be sent to the owner
     */
    function deployStakingContract(
        string memory _collectionName,
        string memory _description,
        address _collectionAddress,
        address _rewardTokenAddress,
        uint256 _stakingFee,
        uint256 _timeUnit,
        uint256 _rewardsPerUnitTime,
        uint256 _endDate
    )
        external
        payable
    {
        if (msg.value != fee) revert Roofi_NotEnoughEtherToCoverFee();
        StakingContract newContract = new StakingContract(
            _collectionName,
            _description,
            _collectionAddress,
            _rewardTokenAddress,
            _stakingFee,
            msg.sender,
            _timeUnit,
            _rewardsPerUnitTime,
            _endDate
        );

        deployedContracts.add(address(newContract));
        emit ContractDeployed(address(newContract));
    }

    /**
     * @notice withdrawEther to the owner
     */
    function withdrawEther() public onlyOwner returns (uint256 amount) {
        amount = address(this).balance;
        if (amount > 0) revert Roofi_NoEtherToWithdraw(amount);

        payable(owner()).transfer(amount);
        emit FundsWithdrawn(amount);
    }

    /**
     * @notice This returns all the staking contracts deployed by this factory
     */
    function getDeployedStakingContracts() external view returns (address[] memory) {
        uint256 count = deployedContracts.length();
        address[] memory contracts = new address[](count);

        for (uint256 i = 0; i < count; i++) {
            contracts[i] = deployedContracts.at(i);
        }

        return contracts;
    }
}
