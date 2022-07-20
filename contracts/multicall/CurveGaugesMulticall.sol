// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/curve/GaugeFactory.sol";
import "../interfaces/curve/Gauge.sol";
import "../interfaces/curve/LpToken.sol";

contract CurveGaugesMulticall is Ownable {
    struct GaugeInfo {
        address gauge;
    }

    struct UserGauge {
        address gauge;
        address lpToken;
        uint256 poolShare; // in wei.
        uint256 claimableCrv;
        address[2] extraRewardTokens;
        uint256[2] extraRewardAmounts;
    }

    function getGaugesInfo(GaugeFactory factory)
        external
        view
        returns (GaugeInfo[] memory gauges)
    {
        uint256 count = factory.get_gauge_count();

        gauges = new GaugeInfo[](count);

        for (uint256 i = 0; i < count; i++) {
            Gauge gauge = Gauge(factory.get_gauge(i));

            gauges[i] = GaugeInfo(address(gauge));
        }
    }

    function getUserGauges(
        GaugeFactory factory,
        address[] memory gauges,
        address userAddress
    ) external view returns (UserGauge[] memory userGauges) {
        userGauges = new UserGauge[](gauges.length);

        for (uint256 i = 0; i < gauges.length; i++) {
            Gauge gauge = Gauge(gauges[i]);

            uint256 userGaugeBalance = gauge.balanceOf(userAddress);
            if (userGaugeBalance == 0) {
                continue;
            }

            // CRV Rewards
            uint256 minted = factory.minted(userAddress, address(gauge));
            uint256 totalMint = gauge.integrate_fraction(userAddress);
            uint256 claimableCrv = totalMint - minted;

            // External Rewards
            uint256 rewardCount = min(gauge.reward_count(), 2);
            address[2] memory extraRewardTokens;
            uint256[2] memory extraRewardAmounts;
            for (uint256 j = 0; j < rewardCount; j++) {
                extraRewardTokens[j] = gauge.reward_tokens(j);
                extraRewardAmounts[j] = gauge.claimable_reward(
                    userAddress,
                    extraRewardTokens[j]
                );
            }

            uint256 userGaugeShare = (userGaugeBalance * 10**18) /
                gauge.totalSupply();

            LpToken lpToken = LpToken(gauge.lp_token());
            uint256 gaugeBalance = lpToken.balanceOf(address(gauge));
            uint256 gaugeShare = (gaugeBalance * 10**18) /
                lpToken.totalSupply();

            userGauges[i] = UserGauge(
                address(gauge),
                address(lpToken),
                (userGaugeShare * gaugeShare) / 10**18,
                claimableCrv,
                extraRewardTokens,
                extraRewardAmounts
            );
        }
    }

    // Shouldn't hold funds, just in case.
    function recoverFunds(address to, address token) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(IERC20(token).transfer(to, balance), "Token recovery failed");
    }

    function min(uint256 a, uint256 b) public pure returns (uint256) {
        return a < b ? a : b;
    }
}
