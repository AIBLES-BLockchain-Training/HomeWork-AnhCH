// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract DemoTransparent is Initializable {
    address public owner;
    uint public value;

     modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
     function initialize(address _owner,uint _value) public initializer {
        owner = _owner;
        value = _value;
    }
      function increment2() public {
        value = value + 3;
    }

    function decrement2() public {
        value = value - 3;
    }

}
