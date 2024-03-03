// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library MonetizadoLibrary {
    struct ProtectedContent {
        string name;
        uint256 accessCost;
        bool isProtected;
        uint256 sequenceId;
        address creator;
        uint256 amountAvailable;
        uint256 amountCollected;
        mapping(address => Subscriber) subscribers;
    }

    struct Subscriber {
        bool paid;
        uint256 amount;
    }
}