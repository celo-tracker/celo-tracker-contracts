// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PairGraph {
    event PathAdded(address indexed token0, address indexed token1);
    event PathRemoved(address indexed token0, address indexed token1);

    struct Path {
        address[] path;
        address[] pairs;
        bytes[] extras;
    }

    mapping(address => Path[]) private pairsByToken;
    mapping(address => bool) public owners;

    modifier onlyOwner() {
        require(owners[msg.sender], "caller is not the owner");
        _;
    }

    constructor() {
        owners[msg.sender] = true;
    }

    function addPair(address from, Path memory pair) public onlyOwner {
        pairsByToken[from].push(pair);
        emit PathAdded(from, pair.path[1]);
    }

    function addPairs(address[] memory from, Path[] memory pairs)
        external
        onlyOwner
    {
        require(from.length == pairs.length, "Invalid parameters");
        for (uint256 i = 0; i < from.length; i++) {
            addPair(from[i], pairs[i]);
        }
    }

    function removePair(address from, uint256 index) external onlyOwner {
        Path memory pair = pairsByToken[from][index];
        pairsByToken[from][index] = pairsByToken[from][
            pairsByToken[from].length - 1
        ];
        pairsByToken[from].pop();
        emit PathRemoved(from, pair.path[1]);
    }

    function getPair(address from, uint256 index)
        external
        view
        returns (Path memory pair)
    {
        pair = pairsByToken[from][index];
    }

    function getTokenPairs(address from)
        external
        view
        returns (Path[] memory pairs)
    {
        pairs = pairsByToken[from];
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
