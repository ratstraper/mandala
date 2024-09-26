// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import './interfaces/ISVGRenderer.sol';

/**
 * @title BaseVariable
 * @dev Contract containing common variables and structures for inheriting contracts.
 */
contract BaseVariable is Initializable, OwnableUpgradeable {
    /**
     * @dev Structure representing a user's NFT.
     * @param name Name on NFT
     * @param reserv Reserved value for the NFT.
     */    
    struct NFT { 
        string name;
        uint256 reserv;
    }
    
    /// @dev Mapping to store the number of uses for each promo code by its hash.
    mapping(bytes32 => uint256) promocodeCount;
    
    /// @dev Mapping to store discount values for each promo code by its hash.
    mapping(bytes32 => uint256) discount;
    
    /// @dev Mapping to store user data by token ID.
    mapping(uint256 => NFT) userdata;

    /// @dev Interface for the SVG renderer.
    ISVGRenderer renderer;

    /// @dev URL of the collection.
    string collectionURL = "https://mandala.garageno9.site";

    /// @notice Price for minting an NFT
    uint256 public price = 0.01 ether;

    /// @notice Price for changing the name of an NFT
    uint256 public priceToChangeName = 0.002 ether;
}