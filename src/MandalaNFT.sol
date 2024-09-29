// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/** 
* ________________________________________________            _______ 
* __  ____/__    |__  __ \__    |_  ____/__  ____/______________  __ \
* _  / __ __  /| |_  /_/ /_  /| |  / __ __  __/  __  __ \  __ \  /_/ /
* / /_/ / _  ___ |  _, _/_  ___ / /_/ / _  /___  _  / / / /_/ /\__, / 
* \____/  /_/  |_/_/ |_| /_/  |_\____/  /_____/  /_/ /_/\____//____/  
* 71 97 114 97 103 101  110 111 57
*
*
*      .      .
*      _\/  \/_     We create personalized on-chain NFT mandalas
*       _\/\/_      that connect you with the energies of the universe
*   _\_\_\/\/_/_/_  through art, color, and symbolism.
*    / /_/\/\_\ \   Whether for meditation, inspiration, or simply as
*       _/\/\_      a meaningful keepsake, our mandalas are designed
*       /\  /\      to bring balance and harmony into your life.
*      '      '
*/

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./Discount.sol";

/**
 * @title MandalaNFT
 * @dev Contract for creating and managing personalized on-chain NFT mandalas.
 */
contract MandalaNFT is Discount, ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721BurnableUpgradeable, UUPSUpgradeable {

    /// @dev Event emitted when an NFT is successfully minted.
    event LogMinted(address indexed sender, uint256 token); 

    /// @dev Event emitted when the name of an NFT is changed.
    event LogNameChanged(address indexed sender, uint256 token); 

    /// @dev Error thrown when the birthdate data is incorrect.
    error IncorrectData(string date);

    constructor() {
        _disableInitializers();
    }

    /**
     * @param initialOwner Address of the initial owner of the contract.
     * @param _renderer Address of the SVG renderer contract.
     */
    function initialize(address initialOwner, address _renderer) initializer public {
        __ERC721_init("Exclusive Spirit Mandala", "ESM");
        __ERC721Enumerable_init();
        __ERC721Burnable_init();
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        renderer = ISVGRenderer(_renderer);
        collectionURL = "https://mandala.garageno9.site";
        price = 0.05 ether;
        priceToChangeName = 0.01 ether;
    } 

    /**
     * @notice Sets a new name for the specified token.
     * @dev Requires a minimum payment and ownership confirmation of the token.
     * @param tokenId The identifier of the token whose name is to be changed.
     * @param name The new name for the token. Maximum length of 20 characters.
     */
    function setName(uint256 tokenId, string calldata name) payable external {
        require(msg.value >= priceToChangeName, "Insufficient funds");
        require(_requireOwned(tokenId) == msg.sender, "You must own this token");
        require(bytes(name).length <= 20, "Name must be 20 characters max");
        userdata[tokenId].name = name;
        emit LogNameChanged(msg.sender, tokenId);
    }

    /**
     * @notice Sets new prices for minting and name changing.
     * @param _price New price for minting an NFT.
     * @param _priceToChangeName New price for changing the name of an NFT.
     */
    function setPrice(uint256 _price, uint256 _priceToChangeName) external onlyOwner { 
        price = _price; 
        priceToChangeName = _priceToChangeName;    
    }

    /**
     * @param url The new URL for the collection's homepage.
     */
    function setCollectionHomeURL(string calldata url) external onlyOwner { collectionURL = url; }
    
    /**
     * @notice Updates the address of the SVG renderer.
     * @dev Used to update the renderer in case of fixing "rounded-stroke-gradient" misprints.
     * @param newRenderer Address of the new SVG renderer contract.
     */    
    function updateRenderer(address newRenderer) external onlyOwner {
        renderer = ISVGRenderer(newRenderer);
    }

    /**
     * @notice Withdraws a specified amount of ether to a given address.
     * @param _to Address of the recipient.
     * @param _tokenamount Amount of ether to withdraw.
     */
    function withdrawTo(address payable _to, uint256 _tokenamount) external onlyOwner {
        (bool os, ) = _to.call{value: _tokenamount}('');
        require(os);
    }

    /**
     * @notice Mints a new NFT with the provided birthdate, name, and promo code.
     * @param bday String representing the birthdate in DDMMYYYY format.
     * @param name Name for the new NFT. Maximum length of 20 characters.
     * @param word Promo code for obtaining a discount. Can be empty.
     * @return tokenId The identifier of the created token.
     */
    function mint(string calldata bday, string calldata name, string memory word) public payable returns(uint256){
        require(msg.value >= price, "Insufficient funds");
        require(bytes(bday).length == 8, "Incorrect date of birth");
        require(bytes(name).length <= 20, "Name must be 20 characters max");
        uint256 tokenId;
        for(uint256 a; a < 8; a++) {
            uint8 c = uint8(bytes(bday)[a]);
            if(c < 0x30 || c > 0x39) revert IncorrectData(bday);
            tokenId *= 10;
            tokenId += (c - 48);
        }

        NFT memory token;
        token.name = name;
        _safeMint(msg.sender, tokenId, "");
        userdata[tokenId] = token;
        uint256 finalPrice = price;
        if(bytes(word).length > 0) {
            finalPrice = price - getDiscount(word);
        }
        if (msg.value > finalPrice) {
			payable(msg.sender).send(msg.value - finalPrice);
		}
        emit LogMinted(msg.sender, tokenId);
        return(tokenId);
    }

    /**
     * @notice Returns the contract metadata in JSON format.
     */
    function contractURI() public view returns (string memory) {
        string memory desc = unicode'{"name":"Exclusive Spirit Mandalas","description":"Exclusive Spirit Mandalas is a generative NFT collection where each unique mandala is crafted based on your birthdate, reflecting your personal energy and cosmic alignment. Owning your mandala isn\'t just holding a piece of digital art—it\'s a connection to your inner self and the universe. With only one mandala for each birthdate in existence, this is your chance to claim a truly one-of-a-kind token that evolves with you.","external_link":"';
        string memory json = string.concat(string.concat(desc, collectionURL), '"}');
        return string.concat("data:application/json;utf8,", json);
    }
    
    /**
     * @notice Returns information about a token by the owner's index.
     * @dev Used to retrieve a list of tokens owned by a user.
     * @param owner Address of the token owner.
     * @param index Index of the token in the owner's list.
     * @return index The ordinal number of the token.
     * @return tokenId The identifier of the token.
     * @return name The name associated with the token.
     */
    function fullTokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256, uint256, string memory) {
        uint256 tokenId = super.tokenOfOwnerByIndex(owner, index);
        return (index, tokenId, userdata[tokenId].name);
    }

    /**
     * @notice Returns the URI of the token's metadata.
     * @param tokenId The identifier of the token.
     * @return URI of the token's metadata in SVG format.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        NFT storage token = userdata[tokenId];
        return renderer.mandala(uint32ToBytes(uint32(tokenId)), bytes(token.name), token.reserv);
    }

    /**
     * @notice Converts a uint32 number to a byte array with leading zeros up to 8 characters.
     * @dev Used to generate a fixed-length string from a number.
     * @param num The number to convert. Must be no more than 99999999.
     * @return buffer Byte array representing the number.
     */
    function uint32ToBytes(uint32 num) internal pure returns (bytes memory buffer) {
        require(num <= 99999999, "Number exceeds 8 digits");
        buffer = "00000000"; 
        
        assembly {
            let ptr := add(buffer, 32)
            let index := 8
            for { } gt(num, 0) { } {
                let digit := mod(num, 10)
                index := sub(index, 1)
                mstore8(add(ptr, index), add(digit, 48))
                num := div(num, 10)
                if iszero(index) { break }
            }
        }
    }

    /**
     * @dev Authorizes the contract upgrade.
     * @param newImplementation Address of the new implementation contract.
     */
    function _authorizeUpgrade(address newImplementation) internal onlyOwner override { }

    // The following functions are overrides required by Solidity.
    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}