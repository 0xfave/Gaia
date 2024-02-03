# Sstan - v0.1.0 

 --- 
 TODO: add description

# Summary




## Vulnerabilities 

 | Classification | Title | Instances | 
 |:-------:|:---------|:-------:| 
 | [[Low-0]](#[Low-0]) | Unsafe ERC20 Operation | 8 |
## Optimizations 

 | Classification | Title | Instances | 
 |:-------:|:---------|:-------:| 
 | [[Gas-0]](#[Gas-0]) | Tightly pack storage variables | 1 |
 | [[Gas-1]](#[Gas-1]) | Avoid Reading From Storage in a for loop | 2 |
 | [[Gas-2]](#[Gas-2]) | Mark storage variables as `immutable` if they never change after contract initialization. | 1 |
 | [[Gas-3]](#[Gas-3]) | `unchecked{++i}` instead of `i++` (or use assembly when applicable) | 3 |
 | [[Gas-4]](#[Gas-4]) | Cache Storage Variables in Memory | 3 |
 | [[Gas-5]](#[Gas-5]) | Use assembly to check for address(0) | 1 |
 | [[Gas-6]](#[Gas-6]) | Optimal Comparison | 1 |
 | [[Gas-7]](#[Gas-7]) | Use `calldata` instead of `memory` for function arguments that do not get mutated. | 1 |
 | [[Gas-8]](#[Gas-8]) | Use custom errors instead of string error messages | 1 |
 | [[Gas-9]](#[Gas-9]) | Use assembly for math (add, sub, mul, div) | 2 |
 | [[Gas-10]](#[Gas-10]) | Use assembly to write storage values | 2 |
 | [[Gas-11]](#[Gas-11]) | Event is not properly indexed. | 2 |
 | [[Gas-12]](#[Gas-12]) | Mark functions as payable (with discretion) | 4 |
 | [[Gas-13]](#[Gas-13]) | Use assembly when getting a contract's balance of ETH | 2 |
 | [[Gas-14]](#[Gas-14]) | Cache array length during for loop definition. | 2 |
## Quality Assurance 

 | Classification | Title | Instances | 
 |:-------:|:---------|:-------:| 
 | [[NonCritical-0]](#[NonCritical-0]) | Private variables should contain a leading underscore | 3 |
 | [[NonCritical-1]](#[NonCritical-1]) | Constructor should check that all parameters are not 0 | 10 |
 | [[NonCritical-2]](#[NonCritical-2]) | This error has no parameters, the state of the contract when the revert occured will not be available | 16 |
 | [[NonCritical-3]](#[NonCritical-3]) | Function names should be in camelCase | 1 |
 | [[NonCritical-4]](#[NonCritical-4]) | Consider marking public function External | 2 |
 | [[NonCritical-5]](#[NonCritical-5]) | Function parameters should be in camelCase | 19 |
 | [[NonCritical-6]](#[NonCritical-6]) | Consider explicitly naming mapping parameters | 4 |

## Vulnerabilities - Total: 8 

<a name=[Low-0]></a>
### [Low-0] Unsafe ERC20 Operation - Instances: 8 

 > ""
        ERC20 operations can be unsafe due to different implementations and vulnerabilities in the standard. To account for this, either use OpenZeppelin's SafeERC20 library or wrap each operation in a require statement. \n
        > Additionally, ERC20's approve functions have a known race-condition vulnerability. To account for this, use OpenZeppelin's SafeERC20 library's `safeIncrease` or `safeDecrease` Allowance functions.
        <details>
        <summary>Expand Example</summary>

        #### Unsafe Transfer

        ```js
        IERC20(token).transfer(msg.sender, amount);
        ```

        #### OpenZeppelin SafeTransfer

        ```js
        import {SafeERC20} from \"openzeppelin/token/utils/SafeERC20.sol\";
        //--snip--

        IERC20(token).safeTransfer(msg.sender, address(this), amount);
        ```
                
        #### Safe Transfer with require statement.

        ```js
        bool success = IERC20(token).transfer(msg.sender, amount);
        require(success, \"ERC20 transfer failed\");
        ```
                
        #### Unsafe TransferFrom

        ```js
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        ```

        #### OpenZeppelin SafeTransferFrom

        ```js
        import {SafeERC20} from \"openzeppelin/token/utils/SafeERC20.sol\";
        //--snip--

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        ```
                
        #### Safe TransferFrom with require statement.

        ```js
        bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
        require(success, \"ERC20 transfer failed\");
        ```

        </details>
        "" 

 --- 

File:Raffle.sol#L42
```solidity
41:        IERC721(_nft).transferFrom(msg.sender, address(this), _tokenId);
``` 



File:Raffle.sol#L67
```solidity
66:            participant.transfer(raffle.ticketPrice);
``` 



File:Raffle.sol#L99
```solidity
98:        payable(owner()).transfer(address(this).balance);
``` 



File:RooFiStaking.sol#L221
```solidity
220:        require(rewardToken.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");
``` 



File:RooFiStaking.sol#L316
```solidity
315:        require(rewardToken.transfer(msg.sender, rewards), "Token transfer failed");
``` 



File:RooFiStaking.sol#L343
```solidity
342:            require(IERC20(_tokenAddress).transfer(owner(), amountToSend), "Token transfer failed");
``` 



File:RooFiStaking.sol#L352
```solidity
351:            require(IERC20(_tokenAddress).transfer(owner(), _amount), "Token transfer failed");
``` 



File:RooFiStakingFactory.sol#L85
```solidity
84:        payable(owner()).transfer(amount);
``` 



 --- 



## Optimizations - Total: 28 

<a name=[Gas-0]></a>
### [Gas-0] Tightly pack storage variables - Instances: 1 

 > 
 When defining storage variables, make sure to declare them in ascending order, according to size. When multiple variables are able to fit into one 256 bit slot, this will save storage size and gas during runtime. For example, if you have a `bool`, `uint256` and a `bool`, instead of defining the variables in the previously mentioned order, defining the two boolean variables first will pack them both into one storage slot since they only take up one byte of storage. - Savings: ~0 
 

 --- 

File:RooFiStaking.sol#L25
```solidity
24:    string public collectionName;
``` 



 --- 

<a name=[Gas-1]></a>
### [Gas-1] Avoid Reading From Storage in a for loop - Instances: 2 

 > 
  - Savings: ~0 
 

 --- 

File:RooFiStakingFactory.sol#L96
```solidity
95:        for (uint256 i = 0; i < count; i++) {
96:            contracts[i] = deployedContracts.at(i);
97:        }
98:
``` 



File:RooFiStaking.sol#L143
```solidity
142:        for (uint256 i = 0; i < len; ++i) {
143:            isStaking = 2;
144:            collectionAddress.safeTransferFrom(msg.sender, address(this), _tokenIds[i]);
145:            isStaking = 1;
146:
147:            stakerAddress[_tokenIds[i]] = msg.sender;
148:
149:            if (!isIndexed[_tokenIds[i]]) {
150:                isIndexed[_tokenIds[i]] = true;
151:                indexedTokens.push(_tokenIds[i]);
152:            }
153:        }
154:        stakers[msg.sender].amountStaked += len;
``` 



File:RooFiStaking.sol#L143
```solidity
142:        for (uint256 i = 0; i < len; ++i) {
143:            isStaking = 2;
144:            collectionAddress.safeTransferFrom(msg.sender, address(this), _tokenIds[i]);
145:            isStaking = 1;
146:
147:            stakerAddress[_tokenIds[i]] = msg.sender;
148:
149:            if (!isIndexed[_tokenIds[i]]) {
150:                isIndexed[_tokenIds[i]] = true;
151:                indexedTokens.push(_tokenIds[i]);
152:            }
153:        }
154:        stakers[msg.sender].amountStaked += len;
``` 



File:RooFiStaking.sol#L143
```solidity
142:        for (uint256 i = 0; i < len; ++i) {
143:            isStaking = 2;
144:            collectionAddress.safeTransferFrom(msg.sender, address(this), _tokenIds[i]);
145:            isStaking = 1;
146:
147:            stakerAddress[_tokenIds[i]] = msg.sender;
148:
149:            if (!isIndexed[_tokenIds[i]]) {
150:                isIndexed[_tokenIds[i]] = true;
151:                indexedTokens.push(_tokenIds[i]);
152:            }
153:        }
154:        stakers[msg.sender].amountStaked += len;
``` 



File:RooFiStaking.sol#L143
```solidity
142:        for (uint256 i = 0; i < len; ++i) {
143:            isStaking = 2;
144:            collectionAddress.safeTransferFrom(msg.sender, address(this), _tokenIds[i]);
145:            isStaking = 1;
146:
147:            stakerAddress[_tokenIds[i]] = msg.sender;
148:
149:            if (!isIndexed[_tokenIds[i]]) {
150:                isIndexed[_tokenIds[i]] = true;
151:                indexedTokens.push(_tokenIds[i]);
152:            }
153:        }
154:        stakers[msg.sender].amountStaked += len;
``` 



File:RooFiStaking.sol#L143
```solidity
142:        for (uint256 i = 0; i < len; ++i) {
143:            isStaking = 2;
144:            collectionAddress.safeTransferFrom(msg.sender, address(this), _tokenIds[i]);
145:            isStaking = 1;
146:
147:            stakerAddress[_tokenIds[i]] = msg.sender;
148:
149:            if (!isIndexed[_tokenIds[i]]) {
150:                isIndexed[_tokenIds[i]] = true;
151:                indexedTokens.push(_tokenIds[i]);
152:            }
153:        }
154:        stakers[msg.sender].amountStaked += len;
``` 



File:RooFiStaking.sol#L143
```solidity
142:        for (uint256 i = 0; i < len; ++i) {
143:            isStaking = 2;
144:            collectionAddress.safeTransferFrom(msg.sender, address(this), _tokenIds[i]);
145:            isStaking = 1;
146:
147:            stakerAddress[_tokenIds[i]] = msg.sender;
148:
149:            if (!isIndexed[_tokenIds[i]]) {
150:                isIndexed[_tokenIds[i]] = true;
151:                indexedTokens.push(_tokenIds[i]);
152:            }
153:        }
154:        stakers[msg.sender].amountStaked += len;
``` 



File:RooFiStaking.sol#L143
```solidity
142:        for (uint256 i = 0; i < len; ++i) {
143:            isStaking = 2;
144:            collectionAddress.safeTransferFrom(msg.sender, address(this), _tokenIds[i]);
145:            isStaking = 1;
146:
147:            stakerAddress[_tokenIds[i]] = msg.sender;
148:
149:            if (!isIndexed[_tokenIds[i]]) {
150:                isIndexed[_tokenIds[i]] = true;
151:                indexedTokens.push(_tokenIds[i]);
152:            }
153:        }
154:        stakers[msg.sender].amountStaked += len;
``` 



File:RooFiStaking.sol#L143
```solidity
142:        for (uint256 i = 0; i < len; ++i) {
143:            isStaking = 2;
144:            collectionAddress.safeTransferFrom(msg.sender, address(this), _tokenIds[i]);
145:            isStaking = 1;
146:
147:            stakerAddress[_tokenIds[i]] = msg.sender;
148:
149:            if (!isIndexed[_tokenIds[i]]) {
150:                isIndexed[_tokenIds[i]] = true;
151:                indexedTokens.push(_tokenIds[i]);
152:            }
153:        }
154:        stakers[msg.sender].amountStaked += len;
``` 



File:RooFiStaking.sol#L180
```solidity
179:        for (uint256 i = 0; i < len; ++i) {
180:            if (stakerAddress[_tokenIds[i]] != msg.sender) revert Roofi_NotStaker();
181:            stakerAddress[_tokenIds[i]] = address(0);
182:            collectionAddress.safeTransferFrom(address(this), msg.sender, _tokenIds[i]);
183:        }
184:
``` 



 --- 

<a name=[Gas-2]></a>
### [Gas-2] Mark storage variables as `immutable` if they never change after contract initialization. - Instances: 1 

 > 
 State variables can be declared as constant or immutable. In both cases, the variables cannot be modified after the contract has been constructed. For constant variables, the value has to be fixed at compile-time, while for immutable, it can still be assigned at construction time. 
 The compiler does not reserve a storage slot for these variables, and every occurrence is inlined by the respective value. 
 Compared to regular state variables, the gas costs of constant and immutable variables are much lower. For a constant variable, the expression assigned to it is copied to all the places where it is accessed and also re-evaluated each time. This allows for local optimizations. Immutable variables are evaluated once at construction time and their value is copied to all the places in the code where they are accessed. For these values, 32 bytes are reserved, even if they would fit in fewer bytes. Due to this, constant values can sometimes be cheaper than immutable values. 
 - Savings: ~2103 
 

 --- 

File:RooFiStaking.sol#L26
```solidity
25:    string public description;
``` 



File:RooFiStaking.sol#L25
```solidity
24:    string public collectionName;
``` 



File:RooFiStaking.sol#L27
```solidity
26:    IERC721 public collectionAddress;
``` 



File:RooFiStaking.sol#L28
```solidity
27:    address public rewardTokenAddress;
``` 



File:RooFiStaking.sol#L29
```solidity
28:    uint256 public stakingFee;
``` 



 --- 

<a name=[Gas-3]></a>
### [Gas-3] `unchecked{++i}` instead of `i++` (or use assembly when applicable) - Instances: 3 

 > 
 Use `++i` instead of `i++`. This is especially useful in for loops but this optimization can be used anywhere in your code. You can also use `unchecked{++i;}` for even more gas savings but this will not check to see if `i` overflows. For extra safety if you are worried about this, you can add a require statement after the loop checking if `i` is equal to the final incremented value. For best gas savings, use inline assembly, however this limits the functionality you can achieve. For example you cant use Solidity syntax to internally call your own contract within an assembly block and external calls must be done with the `call()` or `delegatecall()` instruction. However when applicable, inline assembly will save much more gas. - Savings: ~342 
 

 --- 

File:RooFiStakingFactory.sol#L96
```solidity
95:        for (uint256 i = 0; i < count; i++) {
``` 



File:RooFiStaking.sol#L288
```solidity
287:        for (uint256 i = 0; i < indexedTokenCount; i++) {
``` 



File:RooFiStaking.sol#L365
```solidity
364:        for (uint256 i = 0; i < stakersArray.length; i++) {
``` 



File:RooFiStaking.sol#L180
```solidity
179:        for (uint256 i = 0; i < len; ++i) {
``` 



File:RooFiStaking.sol#L143
```solidity
142:        for (uint256 i = 0; i < len; ++i) {
``` 



File:RooFiStaking.sol#L281
```solidity
280:        for (uint256 i = 0; i < indexedTokenCount; i++) {
``` 



File:RooFiStaking.sol#L170
```solidity
169:            for (uint256 i = 0; i < _stakersArray.length; ++i) {
``` 



File:Raffle.sol#L87
```solidity
86:        for (uint256 i = 0; i < tickets; i++) {
``` 



File:Raffle.sol#L65
```solidity
64:        for (uint256 i = 0; i < raffle.participants.length; i++) {
``` 



File:Raffle.sol#L56
```solidity
55:        nextRaffleId++;
``` 



 --- 

<a name=[Gas-4]></a>
### [Gas-4] Cache Storage Variables in Memory - Instances: 3 

 > 
  - Savings: ~0 
 

 --- 

File:RooFiStakingFactory.sol#L97
```solidity
96:            contracts[i] = deployedContracts.at(i);
``` 



File:Raffle.sol#L54
```solidity
53:        emit RaffleCreated(nextRaffleId, msg.sender, _nft, _tokenId);
``` 



File:Raffle.sol#L56
```solidity
55:        nextRaffleId++;
``` 



File:RooFiStaking.sol#L139
```solidity
138:            stakers[msg.sender].timeOfLastUpdate = uint128(block.timestamp);
``` 



File:RooFiStaking.sol#L140
```solidity
139:            stakers[msg.sender].conditionIdOflastUpdate = nextConditionId - 1;
``` 



File:RooFiStaking.sol#L145
```solidity
144:            collectionAddress.safeTransferFrom(msg.sender, address(this), _tokenIds[i]);
``` 



File:RooFiStaking.sol#L146
```solidity
145:            isStaking = 1;
``` 



File:RooFiStaking.sol#L151
```solidity
150:                isIndexed[_tokenIds[i]] = true;
``` 



File:RooFiStaking.sol#L155
```solidity
154:        stakers[msg.sender].amountStaked += len;
``` 



File:RooFiStaking.sol#L139
```solidity
138:            stakers[msg.sender].timeOfLastUpdate = uint128(block.timestamp);
``` 



File:RooFiStaking.sol#L140
```solidity
139:            stakers[msg.sender].conditionIdOflastUpdate = nextConditionId - 1;
``` 



File:RooFiStaking.sol#L145
```solidity
144:            collectionAddress.safeTransferFrom(msg.sender, address(this), _tokenIds[i]);
``` 



File:RooFiStaking.sol#L146
```solidity
145:            isStaking = 1;
``` 



File:RooFiStaking.sol#L151
```solidity
150:                isIndexed[_tokenIds[i]] = true;
``` 



File:RooFiStaking.sol#L155
```solidity
154:        stakers[msg.sender].amountStaked += len;
``` 



File:RooFiStaking.sol#L172
```solidity
171:                    stakersArray[i] = _stakersArray[_stakersArray.length - 1];
``` 



File:RooFiStaking.sol#L173
```solidity
172:                    stakersArray.pop();
``` 



File:RooFiStaking.sol#L178
```solidity
177:        stakers[msg.sender].amountStaked -= len;
``` 



File:RooFiStaking.sol#L182
```solidity
181:            stakerAddress[_tokenIds[i]] = address(0);
``` 



File:RooFiStaking.sol#L233
```solidity
232:        stakers[_staker].timeOfLastUpdate = uint128(block.timestamp);
``` 



File:RooFiStaking.sol#L234
```solidity
233:        stakers[_staker].conditionIdOflastUpdate = nextConditionId - 1;
``` 



File:RooFiStaking.sol#L233
```solidity
232:        stakers[_staker].timeOfLastUpdate = uint128(block.timestamp);
``` 



File:RooFiStaking.sol#L234
```solidity
233:        stakers[_staker].conditionIdOflastUpdate = nextConditionId - 1;
``` 



File:RooFiStaking.sol#L261
```solidity
260:        nextConditionId += 1;
``` 



File:RooFiStaking.sol#L271
```solidity
270:            stakingConditions[conditionId - 1].endTimestamp = block.timestamp;
``` 



File:RooFiStaking.sol#L301
```solidity
300:            _rewards = stakers[_user].unclaimedRewards;
``` 



File:RooFiStaking.sol#L303
```solidity
302:            _rewards = stakers[_user].unclaimedRewards + _calculateRewards(_user);
``` 



File:RooFiStaking.sol#L301
```solidity
300:            _rewards = stakers[_user].unclaimedRewards;
``` 



File:RooFiStaking.sol#L303
```solidity
302:            _rewards = stakers[_user].unclaimedRewards + _calculateRewards(_user);
``` 



File:RooFiStaking.sol#L312
```solidity
311:        stakers[msg.sender].timeOfLastUpdate = uint128(block.timestamp);
``` 



File:RooFiStaking.sol#L313
```solidity
312:        stakers[msg.sender].unclaimedRewards = 0;
``` 



File:RooFiStaking.sol#L314
```solidity
313:        stakers[msg.sender].conditionIdOflastUpdate = nextConditionId - 1;
``` 



File:RooFiStaking.sol#L341
```solidity
340:            uint256 amountToSend = rewardToken.balanceOf(address(this)) - rewardTokenBalance;
``` 



File:RooFiStaking.sol#L341
```solidity
340:            uint256 amountToSend = rewardToken.balanceOf(address(this)) - rewardTokenBalance;
``` 



File:RooFiStaking.sol#L366
```solidity
365:            totalStakedAmount += stakers[stakersArray[i]].amountStaked;
``` 



File:RooFiStaking.sol#L380
```solidity
379:        StakingCondition memory latestCondition = stakingConditions[nextConditionId - 1];
``` 



 --- 

<a name=[Gas-5]></a>
### [Gas-5] Use assembly to check for address(0) - Instances: 1 

 > 
  - Savings: ~6 
 

 --- 

File:RooFiStaking.sol#L116
```solidity
115:        if (_collectionAddress == address(0)) revert RoofiStake_AddressCantBeZero();
``` 



File:RooFiStaking.sol#L117
```solidity
116:        if (_rewardTokenAddress == address(0)) revert RoofiStake_AddressCantBeZero();
``` 



File:RooFiStaking.sol#L338
```solidity
337:        if (_tokenAddress == address(0)) revert RoofiStake_AddressCantBeZero();
``` 



 --- 

<a name=[Gas-6]></a>
### [Gas-6] Optimal Comparison - Instances: 1 

 > 
 When comparing integers, it is cheaper to use strict `>` & `<` operators over `>=` & `<=` operators, even if you must increment or decrement one of the operands. 
 Note: before using this technique, it's important to consider whether incrementing/decrementing one of the operators could result in an over/underflow. This optimization is applicable when the optimizer is turned off. - Savings: ~3 
 

 --- 

File:RooFiStaking.sol#L133
```solidity
132:        if (collectionAddress.balanceOf(msg.sender) >= len) revert RooFine_BalanceTooLow(len);
``` 



File:RooFiStaking.sol#L349
```solidity
348:            require(_amount <= tokenBalance, "Amount exceeds token balance");
``` 



File:RooFiStaking.sol#L383
```solidity
382:        if (latestCondition.timeUnit <= 0) revert Roofi_InvalidTimeUnit();
``` 



File:RooFiStaking.sol#L406
```solidity
405:        if (remainingDuration <= 0) revert RoofiStake_StakingEnded();
``` 



 --- 

<a name=[Gas-7]></a>
### [Gas-7] Use `calldata` instead of `memory` for function arguments that do not get mutated. - Instances: 1 

 > 
 Mark data types as `calldata` instead of `memory` where possible. This makes it so that the data is not automatically loaded into memory. If the data passed into the function does not need to be changed (like updating values in an array), it can be passed in as `calldata`. The one exception to this is if the argument must later be passed into another function that takes an argument that specifies `memory` storage. - Savings: ~1716 
 

 --- 

File:RooFiStakingFactory.sol#L49
```solidity
48:        string memory _collectionName,
``` 



File:RooFiStakingFactory.sol#L50
```solidity
49:        string memory _description,
``` 



 --- 

<a name=[Gas-8]></a>
### [Gas-8] Use custom errors instead of string error messages - Instances: 1 

 > 
 Using custom errors will save you gas, and can be used to provide more information about the error. - Savings: ~57 
 

 --- 

File:RooFiStaking.sol#L191
```solidity
190:        require(_rewardsPerUnitTime != condition.rewardsPerUnitTime, "Reward unchanged.");
``` 



File:RooFiStaking.sol#L200
```solidity
199:        require(_timeUnit != condition.timeUnit, "Time-unit unchanged.");
``` 



File:RooFiStaking.sol#L210
```solidity
209:        require(_endTimestamp != condition.endTimestamp, "Time-unit unchanged.");
``` 



File:RooFiStaking.sol#L218
```solidity
217:        require(_amount > 0, "Amount must be greater than 0");
``` 



File:RooFiStaking.sol#L221
```solidity
220:        require(rewardToken.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");
``` 



File:RooFiStaking.sol#L259
```solidity
258:        require(_timeUnit != 0, "time-unit can't be 0");
``` 



File:RooFiStaking.sol#L310
```solidity
309:        require(rewards != 0, "No rewards");
``` 



File:RooFiStaking.sol#L316
```solidity
315:        require(rewardToken.transfer(msg.sender, rewards), "Token transfer failed");
``` 



File:RooFiStaking.sol#L332
```solidity
331:        require(isStaking == 2, "Direct transfer");
``` 



File:RooFiStaking.sol#L343
```solidity
342:            require(IERC20(_tokenAddress).transfer(owner(), amountToSend), "Token transfer failed");
``` 



File:RooFiStaking.sol#L349
```solidity
348:            require(_amount <= tokenBalance, "Amount exceeds token balance");
``` 



File:RooFiStaking.sol#L352
```solidity
351:            require(IERC20(_tokenAddress).transfer(owner(), _amount), "Token transfer failed");
``` 



 --- 

<a name=[Gas-9]></a>
### [Gas-9] Use assembly for math (add, sub, mul, div) - Instances: 2 

 > 
 Use assembly for math instead of Solidity. You can check for overflow/underflow in assembly to ensure safety. If using Solidity versions < 0.8.0 and you are using Safemath, you can gain significant gas savings by using assembly to calculate values and checking for overflow/underflow. - Savings: ~60 
 

 --- 

File:RooFiStaking.sol#L140
```solidity
139:            stakers[msg.sender].conditionIdOflastUpdate = nextConditionId - 1;
``` 



File:RooFiStaking.sol#L172
```solidity
171:                    stakersArray[i] = _stakersArray[_stakersArray.length - 1];
``` 



File:RooFiStaking.sol#L190
```solidity
189:        StakingCondition memory condition = stakingConditions[nextConditionId - 1];
``` 



File:RooFiStaking.sol#L199
```solidity
198:        StakingCondition memory condition = stakingConditions[nextConditionId - 1];
``` 



File:RooFiStaking.sol#L208
```solidity
207:        StakingCondition memory condition = stakingConditions[nextConditionId - 1];
``` 



File:RooFiStaking.sol#L209
```solidity
208:        _endTimestamp = block.timestamp + _endTimestamp;
``` 



File:RooFiStaking.sol#L234
```solidity
233:        stakers[_staker].conditionIdOflastUpdate = nextConditionId - 1;
``` 



File:RooFiStaking.sol#L249
```solidity
248:            uint256 rewardsProduct = (endTime - startTime) * staker.amountStaked * condition.rewardsPerUnitTime;
``` 



File:RooFiStaking.sol#L249
```solidity
248:            uint256 rewardsProduct = (endTime - startTime) * staker.amountStaked * condition.rewardsPerUnitTime;
``` 



File:RooFiStaking.sol#L249
```solidity
248:            uint256 rewardsProduct = (endTime - startTime) * staker.amountStaked * condition.rewardsPerUnitTime;
``` 



File:RooFiStaking.sol#L250
```solidity
249:            uint256 rewardsPerTimeUnit = rewardsProduct / condition.timeUnit;
``` 



File:RooFiStaking.sol#L267
```solidity
266:            endTimestamp: block.timestamp + _endTime
267:        });
``` 



File:RooFiStaking.sol#L271
```solidity
270:            stakingConditions[conditionId - 1].endTimestamp = block.timestamp;
``` 



File:RooFiStaking.sol#L303
```solidity
302:            _rewards = stakers[_user].unclaimedRewards + _calculateRewards(_user);
``` 



File:RooFiStaking.sol#L308
```solidity
307:        uint256 rewards = stakers[msg.sender].unclaimedRewards + _calculateRewards(msg.sender);
``` 



File:RooFiStaking.sol#L314
```solidity
313:        stakers[msg.sender].conditionIdOflastUpdate = nextConditionId - 1;
``` 



File:RooFiStaking.sol#L341
```solidity
340:            uint256 amountToSend = rewardToken.balanceOf(address(this)) - rewardTokenBalance;
``` 



File:RooFiStaking.sol#L380
```solidity
379:        StakingCondition memory latestCondition = stakingConditions[nextConditionId - 1];
``` 



File:RooFiStaking.sol#L386
```solidity
385:        uint256 rate = (totalStakedAmount * latestCondition.rewardsPerUnitTime) / latestCondition.timeUnit;
``` 



File:RooFiStaking.sol#L386
```solidity
385:        uint256 rate = (totalStakedAmount * latestCondition.rewardsPerUnitTime) / latestCondition.timeUnit;
``` 



File:RooFiStaking.sol#L392
```solidity
391:        uint256 currentConditionId = nextConditionId - 1;
``` 



File:RooFiStaking.sol#L403
```solidity
402:        uint256 remainingDuration = currentCondition.endTimestamp - block.timestamp;
``` 



File:Raffle.sol#L83
```solidity
82:        if (raffle.ticketsSold + tickets > raffle.maxTickets) revert Roofi_MaxTicketExceeded();
``` 



File:Raffle.sol#L84
```solidity
83:        if (msg.value != raffle.ticketPrice * tickets) revert Roofi_NotEnoughFund();
``` 



 --- 

<a name=[Gas-10]></a>
### [Gas-10] Use assembly to write storage values - Instances: 2 

 > 
 You can save a fair amount of gas by using assembly to write storage values. - Savings: ~66 
 

 --- 

File:RooFiStakingFactory.sol#L29
```solidity
28:        fee = _fee;
``` 



File:RooFiStakingFactory.sol#L37
```solidity
36:        fee = _newFee;
``` 



File:RooFiStaking.sol#L121
```solidity
120:        collectionName = _collectionName;
``` 



File:RooFiStaking.sol#L122
```solidity
121:        description = _description;
``` 



File:RooFiStaking.sol#L124
```solidity
123:        rewardTokenAddress = _rewardTokenAddress;
``` 



File:RooFiStaking.sol#L125
```solidity
124:        stakingFee = _stakingFee;
``` 



File:RooFiStaking.sol#L144
```solidity
143:            isStaking = 2;
``` 



File:RooFiStaking.sol#L146
```solidity
145:            isStaking = 1;
``` 



 --- 

<a name=[Gas-11]></a>
### [Gas-11] Event is not properly indexed. - Instances: 2 

 > 
 When possible, always include a minimum of 3 indexed event topics to save gas - Savings: ~0 
 

 --- 

File:Raffle.sol#L22
```solidity
21:    event RaffleCreated(uint256 raffleId, address indexed creator, IERC721 indexed nft, uint256 tokenId);
``` 



File:Raffle.sol#L23
```solidity
22:    event RaffleCancelled(uint256 raffleId);
``` 



File:Raffle.sol#L24
```solidity
23:    event TicketPurchased(uint256 raffleId, address indexed participant, uint256 tickets);
``` 



File:RooFiStaking.sol#L67
```solidity
66:    event UpdatedRewardsPerUnitTime(uint256 oldRewardsPerUnitTime, uint256 newRewardsPerUnitTime);
``` 



File:RooFiStaking.sol#L68
```solidity
67:    event NFTStaked(uint256);
``` 



File:RooFiStaking.sol#L70
```solidity
69:    event UpdatedTimeUnit(uint256 oldTimeUnit, uint256 newTimeUnit);
``` 



File:RooFiStaking.sol#L72
```solidity
71:    event UpdatedEndTimestamp(uint256 oldEndTimestamp, uint256 newEndTimeStamp);
``` 



File:RooFiStaking.sol#L75
```solidity
74:    event RewardTokensDeposited(uint256 amountDeposited);
``` 



File:RooFiStaking.sol#L78
```solidity
77:    event ERC20Recovered(address indexed tokenAddress, address indexed recipient, uint256 amount);
``` 



File:RooFiStaking.sol#L81
```solidity
80:    event TokensWithdrawn(address indexed staker, uint256[] indexed tokenIds);
``` 



File:RooFiStaking.sol#L84
```solidity
83:    event RewardsClaimed(address indexed staker, uint256 rewardAmount);
``` 



 --- 

<a name=[Gas-12]></a>
### [Gas-12] Mark functions as payable (with discretion) - Instances: 4 

 > 
 You can mark public or external functions as payable to save gas. Functions that are not payable have additional logic to check if there was a value sent with a call, however, making a function payable eliminates this check. This optimization should be carefully considered due to potentially unwanted behavior when a function does not need to accept ether. - Savings: ~24 
 

 --- 

File:Raffle.sol#L38
```solidity
37:    function createRaffle(IERC721 _nft, uint256 _tokenId, uint256 _ticketPrice, uint256 _maxTickets) external {
``` 



File:Raffle.sol#L59
```solidity
58:    function cancelRaffle(uint256 raffleId) external onlyRaffleCreator(raffleId) {
``` 



File:Raffle.sol#L98
```solidity
97:    function withdrawEther() external onlyOwner {
``` 



File:RooFiStakingFactory.sol#L36
```solidity
35:    function updateFee(uint256 _newFee) external onlyOwner {
``` 



File:RooFiStakingFactory.sol#L81
```solidity
80:    function withdrawEther() public onlyOwner returns (uint256 amount) {
``` 



File:RooFiStakingFactory.sol#L92
```solidity
91:    function getDeployedStakingContracts() external view returns (address[] memory) {
``` 



File:RooFiStaking.sol#L130
```solidity
129:    function stakeTokens(uint256[] calldata _tokenIds) external whenNotPaused {
``` 



File:RooFiStaking.sol#L160
```solidity
159:    function unStake(uint256[] calldata _tokenIds) external {
``` 



File:RooFiStaking.sol#L189
```solidity
188:    function setRewardsPerUnitTime(uint256 _rewardsPerUnitTime) external onlyOwner {
``` 



File:RooFiStaking.sol#L198
```solidity
197:    function setTimeUnit(uint256 _timeUnit) external onlyOwner {
``` 



File:RooFiStaking.sol#L207
```solidity
206:    function setEndTimeStamp(uint256 _endTimestamp) external onlyOwner {
``` 



File:RooFiStaking.sol#L217
```solidity
216:    function depositRewardTokens(uint256 _amount) external onlyOwner {
``` 



File:RooFiStaking.sol#L275
```solidity
274:    function getStakeInfo(address _staker) external view returns (uint256[] memory _tokensStaked, uint256 _rewards) {
``` 



File:RooFiStaking.sol#L307
```solidity
306:    function claimReward() external {
``` 



File:RooFiStaking.sol#L321
```solidity
320:    function onERC721Received(
321:        address operator,
322:        address from,
323:        uint256 tokenId,
324:        bytes calldata data
325:    )
326:        external
327:        override
328:        whenNotPaused
329:        returns (bytes4)
330:    {
``` 



File:RooFiStaking.sol#L337
```solidity
336:    function recoverERC20(address _tokenAddress, uint256 _amount) public onlyOwner {
``` 



File:RooFiStaking.sol#L358
```solidity
357:    function getStakersCount() external view returns (uint256) {
``` 



File:RooFiStaking.sol#L362
```solidity
361:    function totalStaked() external view returns (uint256) {
``` 



File:RooFiStaking.sol#L372
```solidity
371:    function poolRate() external view returns (uint256) {
``` 



File:RooFiStaking.sol#L391
```solidity
390:    function rewardDuration() external view returns (uint256) {
``` 



File:Foo.sol#L5
```solidity
4:    function id(uint256 value) external pure returns (uint256) {
``` 



 --- 

<a name=[Gas-13]></a>
### [Gas-13] Use assembly when getting a contract's balance of ETH - Instances: 2 

 > 
 You can use `selfbalance()` instead of `address(this).balance` when getting your contract's balance of ETH to save gas. Additionally, you can use `balance(address)` instead of `address.balance()` when getting an external contract's balance of ETH. - Savings: ~15 
 

 --- 

File:Raffle.sol#L99
```solidity
98:        payable(owner()).transfer(address(this).balance);
``` 



File:RooFiStakingFactory.sol#L82
```solidity
81:        amount = address(this).balance;
``` 



 --- 

<a name=[Gas-14]></a>
### [Gas-14] Cache array length during for loop definition. - Instances: 2 

 > 
 A typical for loop definition may look like: `for (uint256 i; i < arr.length; i++){}`. Instead of using `array.length`, cache the array length before the loop, and use the cached value to safe gas. This will avoid an `MLOAD` every loop for arrays stored in memory and an `SLOAD` for arrays stored in storage. This can have significant gas savings for arrays with a large length, especially if the array is stored in storage. - Savings: ~22 
 

 --- 

File:RooFiStaking.sol#L170
```solidity
169:            for (uint256 i = 0; i < _stakersArray.length; ++i) {
``` 



File:RooFiStaking.sol#L365
```solidity
364:        for (uint256 i = 0; i < stakersArray.length; i++) {
``` 



File:Raffle.sol#L65
```solidity
64:        for (uint256 i = 0; i < raffle.participants.length; i++) {
``` 



 --- 



## Quality Assurance - Total: 55 

<a name=[NonCritical-0]></a>
### [NonCritical-0] Private variables should contain a leading underscore - Instances: 3 

 > Consider adding an underscore to the beginning of the variable name 

 --- 

File:RooFiStaking.sol#L43
```solidity
42:    uint256 private rewardTokenBalance;
``` 



File:RooFiStaking.sol#L49
```solidity
48:    uint8 internal isStaking = 1;
``` 



File:RooFiStaking.sol#L40
```solidity
39:    uint64 private nextConditionId;
``` 



 --- 

<a name=[NonCritical-1]></a>
### [NonCritical-1] Constructor should check that all parameters are not 0 - Instances: 10 

 > Consider adding a require statement to check that all parameters are not 0 in the constructor 

 --- 

File:RooFiStaking.sol#L100
```solidity
99:    constructor(
100:        string memory _collectionName,
101:        string memory _description,
102:        address _collectionAddress,
103:        address _rewardTokenAddress,
104:        uint256 _stakingFee,
105:        address initialOwner,
106:        uint256 _timeUnit,
107:        uint256 _rewardsPerUnitTime,
108:        uint256 _endDate
109:    )
110:        Ownable(initialOwner)
111:    {
``` 



File:RooFiStaking.sol#L100
```solidity
99:    constructor(
100:        string memory _collectionName,
101:        string memory _description,
102:        address _collectionAddress,
103:        address _rewardTokenAddress,
104:        uint256 _stakingFee,
105:        address initialOwner,
106:        uint256 _timeUnit,
107:        uint256 _rewardsPerUnitTime,
108:        uint256 _endDate
109:    )
110:        Ownable(initialOwner)
111:    {
``` 



File:RooFiStaking.sol#L100
```solidity
99:    constructor(
100:        string memory _collectionName,
101:        string memory _description,
102:        address _collectionAddress,
103:        address _rewardTokenAddress,
104:        uint256 _stakingFee,
105:        address initialOwner,
106:        uint256 _timeUnit,
107:        uint256 _rewardsPerUnitTime,
108:        uint256 _endDate
109:    )
110:        Ownable(initialOwner)
111:    {
``` 



File:RooFiStaking.sol#L100
```solidity
99:    constructor(
100:        string memory _collectionName,
101:        string memory _description,
102:        address _collectionAddress,
103:        address _rewardTokenAddress,
104:        uint256 _stakingFee,
105:        address initialOwner,
106:        uint256 _timeUnit,
107:        uint256 _rewardsPerUnitTime,
108:        uint256 _endDate
109:    )
110:        Ownable(initialOwner)
111:    {
``` 



File:RooFiStaking.sol#L100
```solidity
99:    constructor(
100:        string memory _collectionName,
101:        string memory _description,
102:        address _collectionAddress,
103:        address _rewardTokenAddress,
104:        uint256 _stakingFee,
105:        address initialOwner,
106:        uint256 _timeUnit,
107:        uint256 _rewardsPerUnitTime,
108:        uint256 _endDate
109:    )
110:        Ownable(initialOwner)
111:    {
``` 



File:RooFiStaking.sol#L100
```solidity
99:    constructor(
100:        string memory _collectionName,
101:        string memory _description,
102:        address _collectionAddress,
103:        address _rewardTokenAddress,
104:        uint256 _stakingFee,
105:        address initialOwner,
106:        uint256 _timeUnit,
107:        uint256 _rewardsPerUnitTime,
108:        uint256 _endDate
109:    )
110:        Ownable(initialOwner)
111:    {
``` 



File:RooFiStaking.sol#L100
```solidity
99:    constructor(
100:        string memory _collectionName,
101:        string memory _description,
102:        address _collectionAddress,
103:        address _rewardTokenAddress,
104:        uint256 _stakingFee,
105:        address initialOwner,
106:        uint256 _timeUnit,
107:        uint256 _rewardsPerUnitTime,
108:        uint256 _endDate
109:    )
110:        Ownable(initialOwner)
111:    {
``` 



File:RooFiStaking.sol#L100
```solidity
99:    constructor(
100:        string memory _collectionName,
101:        string memory _description,
102:        address _collectionAddress,
103:        address _rewardTokenAddress,
104:        uint256 _stakingFee,
105:        address initialOwner,
106:        uint256 _timeUnit,
107:        uint256 _rewardsPerUnitTime,
108:        uint256 _endDate
109:    )
110:        Ownable(initialOwner)
111:    {
``` 



File:RooFiStaking.sol#L100
```solidity
99:    constructor(
100:        string memory _collectionName,
101:        string memory _description,
102:        address _collectionAddress,
103:        address _rewardTokenAddress,
104:        uint256 _stakingFee,
105:        address initialOwner,
106:        uint256 _timeUnit,
107:        uint256 _rewardsPerUnitTime,
108:        uint256 _endDate
109:    )
110:        Ownable(initialOwner)
111:    {
``` 



File:RooFiStakingFactory.sol#L28
```solidity
27:    constructor(uint256 _fee) Ownable(msg.sender) {
``` 



 --- 

<a name=[NonCritical-2]></a>
### [NonCritical-2] This error has no parameters, the state of the contract when the revert occured will not be available - Instances: 16 

 > Consider adding parameters to the error to provide more context when a transaction fails 

 --- 

File:Raffle.sol#L26
```solidity
25:    error Roofi_NotNFTOwner();
``` 



File:Raffle.sol#L27
```solidity
26:    error Roofi_RaffleNotActive();
``` 



File:Raffle.sol#L28
```solidity
27:    error Roofi_MaxTicketExceeded();
``` 



File:Raffle.sol#L29
```solidity
28:    error Roofi_NotEnoughFund();
``` 



File:RooFiStakingFactory.sol#L22
```solidity
21:    error Roofi_NotEnoughEtherToCoverFee();
``` 



File:RooFiStaking.sol#L88
```solidity
87:    error RoofiStake_EmptyCollectionName();
``` 



File:RooFiStaking.sol#L89
```solidity
88:    error RoofiStake_EmptyDescription();
``` 



File:RooFiStaking.sol#L90
```solidity
89:    error RoofiStake_AddressCantBeZero();
``` 



File:RooFiStaking.sol#L91
```solidity
90:    error RoofiStake_InvalidStakingFee();
``` 



File:RooFiStaking.sol#L92
```solidity
91:    error RoofiStake_StakingEnded();
``` 



File:RooFiStaking.sol#L93
```solidity
92:    error RoofiStake_UnstakeAmountTooHigh();
``` 



File:RooFiStaking.sol#L94
```solidity
93:    error RoofiStake_NoNFTToUnStake();
``` 



File:RooFiStaking.sol#L95
```solidity
94:    error RooFine_HasNoEndTime();
``` 



File:RooFiStaking.sol#L96
```solidity
95:    error Roofi_NotStaker();
``` 



File:RooFiStaking.sol#L97
```solidity
96:    error Roofi_NoStakingCondition();
``` 



File:RooFiStaking.sol#L98
```solidity
97:    error Roofi_InvalidTimeUnit();
``` 



 --- 

<a name=[NonCritical-3]></a>
### [NonCritical-3] Function names should be in camelCase - Instances: 1 

 > Ensure that function definitions are declared using camelCase 

 --- 

File:Foo.sol#L5
```solidity
4:    function id(uint256 value) external pure returns (uint256) {
``` 



 --- 

<a name=[NonCritical-4]></a>
### [NonCritical-4] Consider marking public function External - Instances: 2 

 > If a public function is never called internally, it is best practice to mark it as external. 

 --- 

File:RooFiStaking.sol#L337
```solidity
336:    function recoverERC20(address _tokenAddress, uint256 _amount) public onlyOwner {
``` 



File:RooFiStakingFactory.sol#L81
```solidity
80:    function withdrawEther() public onlyOwner returns (uint256 amount) {
``` 



 --- 

<a name=[NonCritical-5]></a>
### [NonCritical-5] Function parameters should be in camelCase - Instances: 19 

 > Ensure that function parameters are declared using camelCase 

 --- 

File:Raffle.sol#L38
```solidity
37:    function createRaffle(IERC721 _nft, uint256 _tokenId, uint256 _ticketPrice, uint256 _maxTickets) external {
``` 



File:Raffle.sol#L79
```solidity
78:    function purchaseTickets(uint256 raffleId, uint256 tickets) external payable {
``` 



File:RooFiStakingFactory.sol#L28
```solidity
27:    constructor(uint256 _fee) Ownable(msg.sender) {
``` 



File:RooFiStakingFactory.sol#L50
```solidity
49:        string memory _description,
``` 



File:RooFiStakingFactory.sol#L81
```solidity
80:    function withdrawEther() public onlyOwner returns (uint256 amount) {
``` 



File:RooFiStaking.sol#L102
```solidity
101:        string memory _description,
``` 



File:RooFiStaking.sol#L217
```solidity
216:    function depositRewardTokens(uint256 _amount) external onlyOwner {
``` 



File:RooFiStaking.sol#L230
```solidity
229:    function _updateUnclaimedRewardsForStaker(address _staker) internal virtual {
``` 



File:RooFiStaking.sol#L237
```solidity
236:    function _calculateRewards(address _staker) internal view returns (uint256 _rewards) {
``` 



File:RooFiStaking.sol#L237
```solidity
236:    function _calculateRewards(address _staker) internal view returns (uint256 _rewards) {
``` 



File:RooFiStaking.sol#L275
```solidity
274:    function getStakeInfo(address _staker) external view returns (uint256[] memory _tokensStaked, uint256 _rewards) {
``` 



File:RooFiStaking.sol#L275
```solidity
274:    function getStakeInfo(address _staker) external view returns (uint256[] memory _tokensStaked, uint256 _rewards) {
``` 



File:RooFiStaking.sol#L299
```solidity
298:    function _availableRewards(address _user) internal view virtual returns (uint256 _rewards) {
``` 



File:RooFiStaking.sol#L299
```solidity
298:    function _availableRewards(address _user) internal view virtual returns (uint256 _rewards) {
``` 



File:RooFiStaking.sol#L322
```solidity
321:        address operator,
``` 



File:RooFiStaking.sol#L323
```solidity
322:        address from,
``` 



File:RooFiStaking.sol#L325
```solidity
324:        bytes calldata data
325:    )
``` 



File:RooFiStaking.sol#L337
```solidity
336:    function recoverERC20(address _tokenAddress, uint256 _amount) public onlyOwner {
``` 



File:Foo.sol#L5
```solidity
4:    function id(uint256 value) external pure returns (uint256) {
``` 



 --- 

<a name=[NonCritical-6]></a>
### [NonCritical-6] Consider explicitly naming mapping parameters - Instances: 4 

 > Consider explicitly naming mapping parameters for readability 

 --- 

File:Raffle.sol#L19
```solidity
18:    mapping(uint256 raffleId => Raffle) public raffles;
``` 



File:RooFiStaking.sol#L52
```solidity
51:    mapping(uint256 _tokenIds => bool) public isIndexed;
``` 



File:RooFiStaking.sol#L55
```solidity
54:    mapping(address staker => Staker) public stakers;
``` 



File:RooFiStaking.sol#L58
```solidity
57:    mapping(uint256 _tokenIds => StakingCondition) private stakingConditions;
``` 



 --- 


