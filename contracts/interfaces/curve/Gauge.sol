// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface Gauge is IERC20 {
    function integrate_fraction(address userAddress)
        external
        view
        returns (uint256);

    function reward_count() external view returns (uint256);

    function reward_tokens(uint256 index) external view returns (address);

    function claimable_reward(address userAddress, address rewardToken)
        external
        view
        returns (uint256);

    function lp_token() external view returns (address);
}
