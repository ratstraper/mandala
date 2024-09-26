// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./BaseVariable.sol";

/**
 * @title Discount
 * @dev Contract for managing promo codes and discounts.
 */
contract Discount is BaseVariable {
    
    /**
     * @notice Sets promo codes with a specified number of uses and discount value.
     * @param _codes Array of promo code hashes in bytes32 format.
     * @param _count Number of available uses for each promo code.
     * @param _discount Discount value in basis points (maximum 10000).
     */
    function setPromocode(bytes32[] memory _codes, uint256 _count, uint256 _discount) external onlyOwner {
        require(10000 >= _discount); //, 'Discount must be <= 10000');
        uint256 count = _codes.length;
        for(uint256 i = 0; i < count; i++) {
            promocodeCount[_codes[i]] = _count;
            discount[_codes[i]] = _discount;
        }  
    }
    
    /**
     * @notice Calculates the discount based on the provided promo word.
     * @param _word The promo word string to check and apply the discount.
     * @return The discount amount in ether. Returns 0 if the promo code is invalid or exhausted.
     */
    function getDiscount(string memory _word) internal returns(uint256) {
        bytes32 hash = keccak256(abi.encodePacked(_word));
        if(promocodeCount[hash] > 0) {
            promocodeCount[hash] -= 1;
            return (price * discount[hash]) / 10000;
        }
        return 0;
    } 
}