// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../interfaces/ISwappaRouter.sol";

contract PathFinder {
    event PathAdded(address indexed token0, address indexed token1);
    event PathRemoved(address indexed token0, address indexed token1);

    struct Path {
        address[] path;
        address[] pairs;
        bytes[] extras;
    }

    struct Pair {
        address toToken;
        Path path;
    }

    ISwappaRouterV1 public swappa;
    mapping(address => Pair[]) public pairsByToken;
    mapping(address => bool) public owners;

    modifier onlyOwner() {
        require(owners[msg.sender], "caller is not the owner");
        _;
    }

    constructor(ISwappaRouterV1 _swappa) {
        swappa = _swappa;
        owners[msg.sender] = true;
    }

    function addPair(address from, Pair memory pair) public onlyOwner {
        pairsByToken[from].push(pair);
        emit PathAdded(from, pair.toToken);
    }

    function addPairs(address[] memory from, Pair[] memory pairs)
        external
        onlyOwner
    {
        require(from.length == pairs.length, "Invalid parameters");
        for (uint256 i = 0; i < from.length; i++) {
            addPair(from[i], pairs[i]);
        }
    }

    function removePair(address from, uint256 index) external onlyOwner {
        Pair memory pair = pairsByToken[from][index];
        pairsByToken[from][index] = pairsByToken[from][
            pairsByToken[from].length - 1
        ];
        delete pairsByToken[from][pairsByToken[from].length - 1];
        emit PathRemoved(from, pair.toToken);
    }

    function getPair(address from, uint256 index)
        external
        view
        onlyOwner
        returns (Pair memory pair)
    {
        pair = pairsByToken[from][index];
    }

    function getTokenPairs(address from)
        external
        view
        onlyOwner
        returns (Pair[] memory pairs)
    {
        pairs = pairsByToken[from];
    }

    function getBestSwapPath(
        address from,
        address to,
        uint256 inputAmount,
        uint256 maxSteps
    ) external view returns (Path[] memory bestPath, uint256 bestOutput) {
        require(inputAmount > 0, "inputAmount can't be 0");

        (bestPath, bestOutput) = getBestRate(
            from,
            inputAmount,
            to,
            new Path[](0),
            new address[](0),
            new Path[](0),
            0,
            maxSteps
        );
    }

    function getBestRate(
        address fromToken,
        uint256 inputAmount,
        address targetToken,
        Path[] memory activePath,
        address[] memory tokensUsed,
        Path[] memory bestPathSoFar,
        uint256 bestOutputSoFar,
        uint256 stepsLeft
    ) public view returns (Path[] memory bestPath, uint256 bestOutput) {
        bestPath = bestPathSoFar;
        bestOutput = bestOutputSoFar;

        Pair[] memory pairs = pairsByToken[fromToken];
        if (pairs.length == 0 || stepsLeft == 0) {
            return (bestPath, bestOutput);
        }

        Path[] memory currentPath = new Path[](activePath.length + 1);
        for (uint256 i = 0; i < activePath.length; i += 1) {
            currentPath[i] = activePath[i];
        }
        address[] memory newTokensUsed = new address[](tokensUsed.length + 1);
        for (uint256 i = 0; i < tokensUsed.length; i += 1) {
            newTokensUsed[i] = tokensUsed[i];
        }

        for (uint256 i = 0; i < pairs.length; i++) {
            Pair memory pair = pairs[i];
            currentPath[activePath.length] = pair.path;
            uint256 outputAmount = swappa.getOutputAmount(
                pair.path.path,
                pair.path.pairs,
                pair.path.extras,
                inputAmount
            );
            if (pair.toToken == targetToken) {
                if (outputAmount > bestOutput) {
                    bestOutput = outputAmount;
                    bestPath = copyOfArray(currentPath);
                }
            } else if (!contains(newTokensUsed, pair.toToken)) {
                newTokensUsed[tokensUsed.length] = pair.toToken;
                (
                    Path[] memory potentialBestPath,
                    uint256 potentialBestOutput
                ) = getBestRate(
                        pair.toToken,
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
                    // Could use pointer if needed, but gas cost is not a concern.
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

    function copyOfArray(Path[] memory original)
        private
        pure
        returns (Path[] memory copy)
    {
        copy = new Path[](original.length);
        for (uint256 i = 0; i < original.length; i += 1) {
            copy[i] = original[i];
        }
    }

    function setOwner(address newOwner, bool isOwner) external onlyOwner {
        owners[newOwner] = isOwner;
    }

    function emergency(address token) external onlyOwner {
        ERC20(token).transfer(
            msg.sender,
            ERC20(token).balanceOf(address(this))
        );
    }
}
