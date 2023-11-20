// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

contract Distribute {
    address[6] public contributors;
    uint256 public createTime;

    constructor(address[6] memory _contributors) payable {
        createTime = block.timestamp;
        contributors = _contributors;
    }

    function distribute() external {
        require(
            block.timestamp > createTime + 2 weeks,
            "cannot call distribute yet"
        );
        uint256 amount = address(this).balance / 4;
        payable(contributors[0]).transfer(amount);
        payable(contributors[1]).transfer(amount);
        payable(contributors[2]).transfer(amount);
        payable(contributors[3]).transfer(amount);
        payable(contributors[4]).transfer(amount);
        payable(contributors[5]).transfer(amount);
    }
}
