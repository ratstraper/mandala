// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// import { SVGRenderer } from "../src/SVGRenderer.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { MandalaNFT } from "../src/MandalaNFT.sol";
import { SVGRenderer } from "../src/SVGRenderer.sol";
import { Test } from "forge-std/Test.sol";
import "forge-std/console.sol";

contract SVGRendererTest is Test, IERC721Receiver {
    // Proxy public proxy;
    SVGRenderer public renderer;
    MandalaNFT public nft;
    address owner = address(this);
    address org1  = vm.addr(1);
    address org2  = vm.addr(10);
    address user1 = vm.addr(2);
    address user2 = vm.addr(3);
    address user3 = vm.addr(4);
    address user4 = vm.addr(5);
    address user5 = vm.addr(6);
    address user6 = vm.addr(7);
    address user7 = vm.addr(8);
    address user8 = vm.addr(9);

    function setUp() public {
        renderer = new SVGRenderer();
        nft = new MandalaNFT();
        // ERC1967Proxy proxy = new ERC1967Proxy(address(mandala), "");
        // proxy = new ProxyM();
        // proxy.upgrade(address(mandala));
        // nft = MandalaNFT(address(proxy));
        nft.initialize(owner, address(renderer));

        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
        vm.deal(user3, 100 ether);
        vm.deal(user4, 100 ether);
    }

    function testSvgRenderer() public {
        nft.setCollectionHomeURL("https://mandala.garageno9.site");
        nft.setPrice(0.02 ether, 0.01 ether);
        
        vm.startPrank(user1);
        console.log(nft.contractURI());

        uint256 price = nft.price();
        uint256 priceName = nft.priceToChangeName();
        console.log("price:", price);

        nft.mint{value: price}("27091874", "Joker", "");
        nft.mint{value: price}("01091999", "Nino 1999", "");
        nft.mint{value: price}("30032000", "Miranda 2000 - Boom", "");
        nft.setName{value: priceName}(30032000, "T3000");
        vm.assertEq(nft.balanceOf(user1), 3);
        
        vm.expectRevert();
        nft.setName{value: priceName}(30032000, "T5000qwertasdfgzxcvbn");

        nft.transferFrom(user1, user8, 1091999);
        vm.assertEq(nft.balanceOf(user1), 2);
        vm.stopPrank();

        vm.startPrank(user5);
        vm.expectRevert();
        nft.setName{value: priceName}(30032000, "T5000");

        (uint256 index, uint256 tokenId, string memory name) = nft.fullTokenOfOwnerByIndex(user1, 1);
        console.log(index, tokenId, name);
        vm.assertEq(nft.ownerOf(1091999), user8);
        vm.assertEq(nft.tokenByIndex(0), 27091874);
        vm.assertEq(nft.tokenByIndex(1), 1091999);
        vm.assertEq(nft.tokenByIndex(2), 30032000);
        vm.assertEq(nft.balanceOf(user1), 2);
        vm.expectRevert();
        nft.burn(30032000);
        vm.assertEq(nft.balanceOf(user1), 2);
        vm.stopPrank();

        vm.startPrank(user1);
        vm.assertEq(nft.balanceOf(user1), 2);
        nft.burn(30032000);
        vm.assertEq(nft.balanceOf(user1), 1);
        nft.mint{value: price}("30032000", "Nino 2000", "");
        vm.assertEq(nft.balanceOf(user1), 2);
        console.log("totalSupply:", nft.totalSupply());
        vm.stopPrank();

        console.log("balance:", address(nft).balance);
        console.log("mul:    ", nft.totalSupply() * price);
        console.log("owner balance:", owner.balance);
        
        nft.withdrawTo(payable(owner), address(nft).balance);
        console.log("owner after w:", owner.balance);
    }

    function testSvgRenderer_2() public {
        nft.setPrice(0.02 ether, 0.01 ether);
        bytes32[] memory hash = new bytes32[](2);
        hash[0] = keccak256(abi.encodePacked("PROMO__000"));
        hash[1] = keccak256(abi.encodePacked("PROMO__001"));

        nft.setPromocode(hash, 2, 5000);

        console.log("balance", nft.totalSupply(), address(nft).balance);
        console.log("user1", user1.balance);
        vm.prank(user1);
        nft.mint{value: 0.02 ether}("01101990", "12345", "PROMO__000");
        console.log("balance", nft.totalSupply(), address(nft).balance);
        console.log("user1 ", user1.balance);
        vm.prank(user1);
        nft.mint{value: 10 ether}("20202990", "asdfghjklmn", "PROMO__000");
        console.log("balance", nft.totalSupply(), address(nft).balance);
        console.log("user1 ", user1.balance);

        vm.prank(user1);
        nft.mint{value: 10 ether}("30303990", "QWERTYUIOPLKJHGFDSAZ", "PROMO__000");
        console.log("balance", nft.totalSupply(), address(nft).balance);
        console.log("user1 ", user1.balance);

        vm.prank(user1);
        vm.expectRevert();
        nft.mint{value: 10 ether}("30303990", "T3000", "PROMO__000");
        console.log("balance", nft.totalSupply(), address(nft).balance);
        console.log("user1 ", user1.balance);   

        // nft.tokenURI(1101990);
        // nft.tokenURI(20202990);
        // nft.tokenURI(30303990);
    }

    function testSvgRenderer_3() public {
        uint256 price = nft.price();
        nft.mint{value: price}("29082010", "Fly", "");
        (uint256 index, uint256 tokenId, string memory name) = nft.fullTokenOfOwnerByIndex(owner, 0);
        console.log(index, tokenId, name);
        // string memory svg = nft.tokenURI(29082010);
        // console.log(svg);
    }

function testSvgRenderer_4() public {
        string[] memory arr = new string[](5); 
        arr[0] = "Ds#e-A9bZ-6n";
        arr[1] = "cxC5-Qv9u";
        arr[2] = "ePgd-Y59W-a";
        arr[3] = "a#HT-ePm@-P";
        arr[4] = "LuG#-9GnC-sc";
        bytes32[] memory hashes = new bytes32[](5);
        hashes[0] = 0x2d30ead52c63c6ae5b444bfcb4b5da756f0cdef911914332a4750280fd6189db;
        hashes[1] = 0xf7e66075a3388b8f89eb5be8f853fb6c2d2c9c5f6b0273aed468348c874e264b;
        hashes[2] = 0x21b10cfaa8c461cc0c5d7b5113c5219fcf646fccf3316af1de566ae0aa759669;
        hashes[3] = 0xa2983c74b7d4053595c6f05be0a20eab4292b8ca651204c4141ee26c61eeab03;
        hashes[4] = 0x33628563201d1d0bace44d812ea48a50b25077388b7ee4de05fda67274fb6fff;
        
        for(uint i = 0; i < 5; i++) {
            bytes32 hash = keccak256(abi.encodePacked(arr[i]));
            vm.assertEq(hash, hashes[i]);
        }
        
    }
    function onERC721Received(address, address, uint256, bytes calldata) external override pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    fallback() external payable {}
    receive() external payable {}
}