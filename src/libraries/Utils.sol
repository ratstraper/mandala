// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @title Library for SVGRenderer
/// @author bepossible
/// @notice I left only necessary functions for rendering
library Utils {

    /// @notice Convert string to uint256.
    function toUint(bytes memory str) internal pure returns (uint256 tokenId) {
        // for(uint256 a; a < 8; ++a) {
        //     tokenId *= 10;
        //     tokenId += (uint8(bytes(str)[a]) - 48);
        // }
        uint len = str.length;
        assembly {
            tokenId := 0
            for{let i := len} iszero(iszero(i)) { i := sub(i, 1) } {
                tokenId := mul(tokenId, 10)
                tokenId := add(tokenId, sub(byte(31, mload(add(str, sub(add(len, 1), i)))), 48))
            }
        }
    }

    /// @notice From library to encode strings in Base64.
    /// @dev Encodes `data` using the base64 encoding described in RFC 4648.
    // @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/Base64.sol)
    /// See: https://datatracker.ietf.org/doc/html/rfc4648
    function encode(bytes memory data) internal pure returns (string memory result) {
        assembly ("memory-safe") {
            let dataLength := mload(data)

            if dataLength {
                // Multiply by 4/3 rounded up.
                // The `shl(2, ...)` is equivalent to multiplying by 4.
                let encodedLength := shl(2, div(add(dataLength, 2), 3))

                // Set `result` to point to the start of the free memory.
                result := mload(0x40)

                // Store the table into the scratch space.
                // Offsetted by -1 byte so that the `mload` will load the character.
                // We will rewrite the free memory pointer at `0x40` later with
                // the allocated size.
                // The magic constant 0x0670 will turn "-_" into "+/".
                mstore(0x1f, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef")
                // mstore(0x3f, xor("ghijklmnopqrstuvwxyz0123456789-_", 0x0670))
                mstore(0x3f, "ghijklmnopqrstuvwxyz0123456789+/")

                // Skip the first slot, which stores the length.
                let ptr := add(result, 0x20)
                let end := add(ptr, encodedLength)

                // Run over the input, 3 bytes at a time.
                for {} 1 {} {
                    data := add(data, 3) // Advance 3 bytes.
                    let input := mload(data)

                    // Write 4 bytes. Optimized for fewer stack operations.
                    mstore8(0, mload(and(shr(18, input), 0x3F)))
                    mstore8(1, mload(and(shr(12, input), 0x3F)))
                    mstore8(2, mload(and(shr(6, input), 0x3F)))
                    mstore8(3, mload(and(input, 0x3F)))
                    mstore(ptr, mload(0x00))

                    ptr := add(ptr, 4) // Advance 4 bytes.
                    if iszero(lt(ptr, end)) { break }
                }
                mstore(0x40, add(end, 0x20)) // Allocate the memory.
                // Equivalent to `o = [0, 2, 1][dataLength % 3]`.
                let o := div(2, mod(dataLength, 3))
                // Offset `ptr` and pad with '='. We can simply write over the end.
                mstore(sub(ptr, o), shl(240, 0x3d3d))
                mstore(ptr, 0) // Zeroize the slot after the string.
                mstore(result, encodedLength) // Store the length.
            }
        }
    }
}