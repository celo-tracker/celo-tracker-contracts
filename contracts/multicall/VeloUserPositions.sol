// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../interfaces/velodrome/IGauge.sol";
import "../interfaces/velodrome/IVoter.sol";

contract VeloUserPositions {
    struct VeloPosition {
        address pool;
        address gauge;
        Reward[] rewards;
        uint256 userShare;
    }

    struct Reward {
        address token;
        uint256 amount;
    }

    function getPositions(
        IVoter voter,
        address[] memory pools,
        address owner
    ) external view returns (VeloPosition[] memory positions) {
        positions = new VeloPosition[](pools.length);

        for (uint256 index = 0; index < pools.length; index++) {
            address pool = pools[index];
            address gaugeAddress = voter.gauges(pool);
            if (gaugeAddress == address(0)) {
                continue;
            }

            IGauge gauge = IGauge(gaugeAddress);
            uint256 rewardCount = gauge.rewardsListLength();
            Reward[] memory rewards = new Reward[](rewardCount);
            for (uint256 i = 0; i < rewardCount; i++) {
                address rewardToken = gauge.rewards(i);
                uint256 amount = gauge.earned(rewardToken, owner);
                rewards[i] = Reward(rewardToken, amount);
            }

            uint256 userGaugeBalance = IERC20(gaugeAddress).balanceOf(owner);
            uint256 userShare = 0;
            if (userGaugeBalance > 0) {
                uint256 gaugePoolBalance = IERC20(pool).balanceOf(gaugeAddress);
                uint256 poolSupply = IERC20(pool).totalSupply();
                uint256 gaugePoolShare = (gaugePoolBalance * 10**18) /
                    poolSupply;

                uint256 gaugeSupply = IERC20(gaugeAddress).totalSupply();
                userShare = (gaugePoolShare * userGaugeBalance) / gaugeSupply;
            }

            positions[index] = VeloPosition(
                pool,
                gaugeAddress,
                rewards,
                userShare
            );
        }
    }
}
