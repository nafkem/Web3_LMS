// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

error notOwner();

contract Managed {
    /**
     * @notice CONTRACT MODIFIERS
     */
    modifier onlyAdmin(address[] memory admins) {
        bool isAdmin = false;
        for (uint256 i; i < admins.length; i++) {
            if (msg.sender == admins[i]) {
                isAdmin = true;
                break;
            }
        }
        require(isAdmin == true, "Only Admins");
        _;
    }

    modifier onlyOwner(address _Owner) {
        if (msg.sender != _Owner) {
            revert notOwner();
        }
        _;
    }

    modifier blankCompliance(
        string memory _name,
        string memory _symbol,
        string memory _duration,
        uint256 _value
    ) {
        require(
            bytes(_name).length > 0 &&
                bytes(_duration).length > 0 &&
                bytes(_symbol).length > 0 &&
                _value > 0,
            "can't be left blank"
        );
        _;
    }

    modifier registerInstructorCompliance(
        string memory _valueA,
        string memory _valueB,
        string memory _valueC,
        string memory _valueD,
        uint256 _valueE
    ) {
        require(
            bytes(_valueA).length > 0 &&
                bytes(_valueB).length > 0 &&
                bytes(_valueC).length > 0 &&
                bytes(_valueC).length > 0 &&
                bytes(_valueD).length > 0 &&
                _valueE > 0,
            "can't be empty"
        );
        _;
    }

    modifier paymentCompliance(uint256 _amount) {
        require(msg.value == _amount, "Insufficient Funds");
        _;
    }
}
