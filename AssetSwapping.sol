// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract CrossChainAssetSwapping {
    struct Swap {
        address initiator;
        address recipient;
        uint256 amount;
        bytes32 secretHash;
        bool completed;
    }

    mapping(bytes32 => Swap) public swaps;

    event SwapInitiated(bytes32 indexed swapId, address indexed initiator, address indexed recipient, uint256 amount, bytes32 secretHash);
    event SwapCompleted(bytes32 indexed swapId);
    event SwapCancelled(bytes32 indexed swapId);

    function initiateSwap(address _recipient, uint256 _amount, bytes32 _secretHash) external returns (bytes32 swapId) {
        swapId = keccak256(abi.encodePacked(msg.sender, _recipient, _amount, _secretHash, block.timestamp));
        swaps[swapId] = Swap({
            initiator: msg.sender,
            recipient: _recipient,
            amount: _amount,
            secretHash: _secretHash,
            completed: false
        });

        emit SwapInitiated(swapId, msg.sender, _recipient, _amount, _secretHash);
    }

    function completeSwap(bytes32 _swapId, string memory _secret) external {
        require(msg.sender == swaps[_swapId].recipient, "Only recipient can complete the swap");
        require(!swaps[_swapId].completed, "Swap already completed");
        require(keccak256(abi.encodePacked(_secret)) == swaps[_swapId].secretHash, "Invalid secret");

        swaps[_swapId].completed = true;
        emit SwapCompleted(_swapId);
        // Logic to transfer assets from initiator to recipient goes here
    }

    function cancelSwap(bytes32 _swapId) external {
        require(msg.sender == swaps[_swapId].initiator, "Only initiator can cancel the swap");
        require(!swaps[_swapId].completed, "Swap already completed");

        delete swaps[_swapId];
        emit SwapCancelled(_swapId);
    }

    function getSwapDetails(bytes32 _swapId) external view returns (address, address, uint256, bytes32, bool) {
        Swap memory swap = swaps[_swapId];
        return (swap.initiator, swap.recipient, swap.amount, swap.secretHash, swap.completed);
    }
}
