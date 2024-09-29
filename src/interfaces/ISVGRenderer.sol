// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface ISVGRenderer {

    /**
     * @dev Returns the mandala token.
     */
    function mandala(bytes memory, bytes memory, uint256 reserv) external view returns (string memory);
}