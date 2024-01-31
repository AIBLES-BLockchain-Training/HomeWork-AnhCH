// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract NumberManager{
    uint private totalSum;
    uint public lastAddedNumber;
    constructor(){
    }
    function addNumber (uint number) public {
        totalSum += number;
        totalSum = lastAddedNumber;
    }
    function getTotalSum() external view returns (uint){
        return totalSum;
    }
    function incrementTotalSum(uint number) private {
        totalSum += number;
    }
}