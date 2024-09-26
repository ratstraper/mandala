// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;


library SB {
    struct StringBuilder {
        bytes data;
    }

    function create(uint256 capacity) internal pure returns(StringBuilder memory) {
        return StringBuilder(new bytes(capacity + 32));
    }

    function resize(StringBuilder memory sb, uint256 newCapacity) internal view {
        StringBuilder memory newSb = create(newCapacity);
        
        assembly {
            let data := mload(sb)
            let newData := mload(newSb)
            let size := mload(add(data, 32)) // get used byte count
            let bytesToCopy := add(size, 32) // copy the used bytes, plus the size field in first 32 bytes
            
            pop(staticcall(
                gas(), 
                0x4, 
                add(data, 32), 
                bytesToCopy, 
                add(newData, 32), 
                bytesToCopy))
        }
        
        sb.data = newSb.data;
    }

    function resizeIfNeeded(StringBuilder memory sb, uint256 spaceNeeded) internal view {
        uint capacity;
        uint size;
        assembly {
            let data := mload(sb)
            capacity := sub(mload(data), 32)
            size := mload(add(data, 32))
        }

        uint remaining = capacity - size;
        if (remaining >= spaceNeeded) {
            return;
        }

        uint newCapacity = capacity << 1;
        uint newRemaining = newCapacity - size;
        if (newRemaining >= spaceNeeded) {
            resize(sb, newCapacity);
        } else {
            newCapacity = spaceNeeded + size;
            resize(sb, newCapacity);
        }
    }
    
    function getString(StringBuilder memory sb) internal pure returns(string memory) {
        string memory ret;
        assembly {
            let data := mload(sb)
            ret := add(data, 32)
        }
        return ret;
    }

    function writeStr(StringBuilder memory sb, string memory str) internal view {
        resizeIfNeeded(sb, bytes(str).length);

        assembly {
            let data := mload(sb)
            let size := mload(add(data, 32))
            pop(staticcall(gas(), 0x4, add(str, 32), mload(str), add(size, add(data, 64)), mload(str)))
            mstore(add(data, 32), add(size, mload(str)))
        }
    }

    function concat(StringBuilder memory dst, StringBuilder memory src) internal view {
        string memory asString;
        assembly {
            let srcData := mload(src)
            asString := add(srcData, 32)
        }

        writeStr(dst, asString);
    }

    function writeUint(StringBuilder memory sb, uint u) internal view {
        if (u > 0) {
            uint len;
            uint size;
            
            assembly {
                // get length string will be
                len := 0
                
                for {let val := u} gt(val, 0) {val := div(val,  10) len := add(len, 1)} {}

                // get bytes currently used
                let data := mload(sb)
                size := mload(add(data, 32))
            }
            
            // make sure there's room
            resizeIfNeeded(sb, len);
            
            assembly {
                let data := mload(sb)

                for {let i := 0 let val := u} lt(i, len) {i := add(i, 1) val := div(val, 10)} {
                    // sb.data[64 + size + (len - i - 1)] = (val % 10) + 48
                    mstore8(add(data, add(63, add(size, sub(len, i)))), add(mod(val, 10), 48))
                }
            
                size := add(size, len)
            
                mstore(add(data, 32), size)
            }
        } else {
            uint size;
            assembly {
                let data := mload(sb)
                size := mload(add(data, 32))
            }
            // make sure there's room
            resizeIfNeeded(sb, 1);
            
            assembly {
                let data := mload(sb)
                mstore(add(data, 32), add(size, 1))
                mstore8(add(data, add(64, size)), 48)
            }
        }
    }
/*    
    function writeInt(StringBuilder memory sb, int i) internal view {
        if (i < 0) {
            // write the - sign
            uint size;
            assembly {
                let data := mload(sb)
                size := mload(add(data, 32))
            }
            resizeIfNeeded(sb, 1);
            
            assembly {
                let data := mload(sb)
                mstore(add(data, 32), add(size, 1))
                mstore8(add(data, add(64, size)), 45)
            }

            // now the digits can be written as a uint
            i *= -1;
        }
        writeUint(sb, uint(i));
    }

    function writeRgb(StringBuilder memory sb, uint256 col) internal view {
        resizeIfNeeded(sb, 6);

        string[16] memory nibbles = [
            "0", "1", "2", "3", "4", "5", "6", "7", 
            "8", "9", "a", "b", "c", "d", "e", "f"];

        string memory asStr = string(abi.encodePacked(
            nibbles[(col >> 20) & 0xf],
            nibbles[(col >> 16) & 0xf],
            nibbles[(col >> 12) & 0xf],
            nibbles[(col >> 8) & 0xf],
            nibbles[(col >> 4) & 0xf],
            nibbles[col & 0xf]
        ));

        writeStr(sb, asStr);
    }
    */
}