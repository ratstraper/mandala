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
        string memory svg = nft.tokenURI(29082010);
        console.log(svg);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external override pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    fallback() external payable {}
    receive() external payable {}
}