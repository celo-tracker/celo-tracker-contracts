// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../../interfaces/ISwappaRouter.sol";
import "./PairGraph.sol";

contract PathFinder is Ownable {
    ISwappaRouterV1 public swappa;

    constructor(ISwappaRouterV1 _swappa) {
        swappa = _swappa;
    }

    function getBestSwapPath(
        PairGraph graph,
        address from,
        address to,
        uint256 inputAmount,
        uint256 maxSteps
    )
        external
        view
        returns (PairGraph.Path[] memory bestPath, uint256 bestOutput)
    {
        require(inputAmount > 0, "inputAmount can't be 0");

        address[] memory usedTokens = new address[](1);
        usedTokens[0] = from;

        (bestPath, bestOutput) = getBestRate(
            graph,
            from,
            inputAmount,
            to,
            new PairGraph.Path[](0),
            usedTokens,
            new PairGraph.Path[](0),
            0,
            maxSteps
        );
    }

    function getBestRate(
        PairGraph graph,
        address fromToken,
        uint256 inputAmount,
        address targetToken,
        PairGraph.Path[] memory activePath,
        address[] memory tokensUsed,
        PairGraph.Path[] memory bestPathSoFar,
        uint256 bestOutputSoFar,
        uint256 stepsLeft
    )
        public
        view
        returns (PairGraph.Path[] memory bestPath, uint256 bestOutput)
    {
        bestPath = bestPathSoFar;
        bestOutput = bestOutputSoFar;

        PairGraph.Path[] memory pairs = graph.getTokenPairs(fromToken);
        if (pairs.length == 0 || stepsLeft == 0) {
            return (bestPath, bestOutput);
        }

        PairGraph.Path[] memory currentPath = new PairGraph.Path[](
            activePath.length + 1
        );
        for (uint256 i = 0; i < activePath.length; i += 1) {
            currentPath[i] = activePath[i];
        }
        address[] memory newTokensUsed = new address[](tokensUsed.length + 1);
        for (uint256 i = 0; i < tokensUsed.length; i += 1) {
            newTokensUsed[i] = tokensUsed[i];
        }

        for (uint256 i = 0; i < pairs.length; i++) {
            PairGraph.Path memory pair = pairs[i];
            currentPath[activePath.length] = pair;
            uint256 outputAmount = swappa.getOutputAmount(
                pair.path,
                pair.pairs,
                pair.extras,
                inputAmount
            );
            address toToken = pair.path[1];
            if (toToken == targetToken) {
                if (outputAmount > bestOutput) {
                    bestOutput = outputAmount;
                    bestPath = copyOfArray(currentPath);
                }
            } else if (!contains(newTokensUsed, toToken)) {
                newTokensUsed[tokensUsed.length] = toToken;
                (
                    PairGraph.Path[] memory potentialBestPath,
                    uint256 potentialBestOutput
                ) = getBestRate(
                        graph,
                        toToken,
                        outputAmount,
                        targetToken,
                        currentPath,
                        newTokensUsed,
                        bestPath,
                        bestOutput,
                        stepsLeft - 1
                    );
                delete newTokensUsed[tokensUsed.length];
                if (potentialBestOutput > bestOutput) {
                    bestOutput = potentialBestOutput;
                    bestPath = potentialBestPath;
                }
            }
        }
    }

    function contains(address[] memory tokens, address token)
        private
        pure
        returns (bool)
    {
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == token) {
                return true;
            }
        }
        return false;
    }

    function copyOfArray(PairGraph.Path[] memory original)
        private
        pure
        returns (PairGraph.Path[] memory copy)
    {
        copy = new PairGraph.Path[](original.length);
        for (uint256 i = 0; i < original.length; i += 1) {
            copy[i] = original[i];
        }
    }

    function emergency(address token) external onlyOwner {
        ERC20(token).transfer(
            msg.sender,
            ERC20(token).balanceOf(address(this))
        );
    }
}
