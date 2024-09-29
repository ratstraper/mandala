// SPDX-License-Identifier: Proprietary
pragma solidity 0.8.26;

import {SB} from "./libraries/SB.sol";
import "./libraries/Utils.sol";  

/// @title Class for generating tokenURI
/// @author bepossible
/// @notice Here I generate metadata for the mandala token (v1)
contract SVGRenderer {
    uint256 constant CELL_SIZE = 500;
    uint256 constant R = CELL_SIZE * 16;
    uint256 constant D = R * 2;
    uint256 constant MANDALA_MARGIN = 320;
    uint256 constant CANVAS_SIZE = D + (2 * MANDALA_MARGIN);
    uint256 constant centerX = CANVAS_SIZE / 2;
    uint256 constant centerY = CANVAS_SIZE / 2;
    uint256 constant COS_CELL_SIZE = CELL_SIZE * 5 / 10;
    uint256 constant SIN_CELL_SIZE = CELL_SIZE * 86_602_540_378 / 100_000_000_000;

    function mandala(bytes memory bday, bytes memory name, uint256 reserv) public view returns (string memory) {
        require(bday.length == 8);
        require(name.length <= 20);

        uint256 tokenId = Utils.toUint(bday);
        string memory svg = generate(bday, name);

        SB.StringBuilder memory b = SB.create(12 * 1024);
        SB.writeStr(b, '{"name":"Exclusive Spirit Mandala #');
        SB.writeUint(b, tokenId);
        SB.writeStr(b, '","description":"A unique birthdate mandala that fuses personal energy with digital art","image":"data:image/svg+xml;base64,');
        SB.writeStr(b, Utils.encode(bytes(svg)));
// SB.writeStr(b, svg); 
        // SB.writeStr(b, '","external_url":"');
        // SB.writeStr(b, url);
        SB.writeStr(b, '"}');

// return SB.getString(b);
        return string.concat(
                "data:application/json;base64,",
                Utils.encode(bytes(SB.getString(b)))
            );
    }

    function generate(bytes memory bday, bytes memory name) internal view returns(string memory) {
        bytes memory str = "00000000000000000";
        string[10] memory paths = ["<path fill='#F00' d='",
                                    "<path fill='#F00' d='",
                                    "<path fill='#23E' d='", 
                                    "<path fill='#080' d='",
                                    "<path fill='#ff6' d='",
                                    "<path fill='#09F' d='",
                                    "<path fill='#0EE' d='",
                                    "<path fill='#ffb0ba' d='",
                                    "<path fill='#f93' d='",
                                    "<path fill='#9400D3' d='"];
        
        SB.StringBuilder memory b = SB.create(12 * 1024);
        SB.StringBuilder[] memory trng = new SB.StringBuilder[](10);
        for(uint256 a; a < 10; ++a) {
            trng[a] = SB.create(2 * 1024);
            SB.writeStr(trng[a], paths[a]);
            if(a < 8) {
                str[a] = str[15 - a] = bytes1(uint8(bday[a]) - 48);
            }
        }
        SB.writeStr(b, "<svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' style='background-color:#000' viewBox='0 0 16640 16640'>"
        "<style>text{font-family:monospace;}</style>"
        "<filter id='a'>"
        "<feTurbulence type='turbulence' baseFrequency='0' numOctaves='2' result='turbulence'>"
        "<animate attributeName='baseFrequency' values='.0005;.0002;.0005' dur='2s' repeatCount='indefinite' repeatDur='3s'/>"
        "</feTurbulence>"
        "<feDisplacementMap in2='turbulence' in='SourceGraphic' scale='50' xChannelSelector='R' yChannelSelector='G'/>"
        "</filter>"

        "<filter id='b'><feDropShadow dx='2' dy='4' stdDeviation='2'/></filter>"

        "<defs><symbol id='c'>"
        );

        uint256 x = centerX;
        uint256 y = centerY; 
        uint256 str_len = 16;
        for (uint256 a; a < 16; ++a) {
            str_len--;
            for (uint256 c; c <= str_len; ++c) {
                uint8 n = uint8(str[c]);
                uint256 cx = x + CELL_SIZE * (str_len-c);
                uint256 cy = y + SIN_CELL_SIZE * c;
                SB.concat(trng[n], oneTriangle(cx, cy));
                if(c > 0) {
                    n = n + uint8(str[c - 1]);
                    str[c-1] = bytes1(n / 10 + n % 10);
                }
                x = x + COS_CELL_SIZE;
            }
            x = centerX;
            y = centerY;
        }

        for(uint256 a; a < 10; ++a) {
            SB.concat(b, trng[a]);
            SB.writeStr(b, "'/>");
        }

        SB.writeStr(b, "</symbol></defs>"
        "<g style='filter:url(#b)'>"
        "<g style='filter:url(#a)'>"
        "<use xlink:href='#c' transform='rotate(30 8320 8320)'/>"
        "<use xlink:href='#c' transform='rotate(30 8320 8320)'><animateTransform attributeName='transform' dur='.4s' to='90 8320 8320' type='rotate' fill='freeze'/></use>"
        "<use xlink:href='#c' transform='rotate(30 8320 8320)'><animateTransform attributeName='transform' dur='.5s' to='150 8320 8320' type='rotate' fill='freeze'/></use>"
        "<use xlink:href='#c' transform='rotate(30 8320 8320)'><animateTransform attributeName='transform' dur='.6s' to='210 8320 8320' type='rotate' fill='freeze'/></use>"
        "<use xlink:href='#c' transform='rotate(30 8320 8320)'><animateTransform attributeName='transform' dur='.7s' to='270 8320 8320' type='rotate' fill='freeze'/></use>"
        "<use xlink:href='#c' transform='rotate(30 8320 8320)'><animateTransform attributeName='transform' dur='.8s' to='330 8320 8320' type='rotate' fill='freeze'/></use>"
        "</g></g>");
        uint256 len = name.length;
        if(len > 15) {
            SB.writeStr(b, "<text x='15710' y='13540' font-size='500' text-anchor='end' fill='none' stroke='#fff' stroke-width='10' transform='rotate(330,15710,13540)'>");
        } else if(len > 10) {
            SB.writeStr(b, "<text x='15710' y='13740' font-size='600' text-anchor='end' fill='none' stroke='#fff' stroke-width='10' transform='rotate(330,15710,13740)'>");
        } else {
            SB.writeStr(b, "<text x='15710' y='14040' font-size='800' text-anchor='end' fill='none' stroke='#fff' stroke-width='10' transform='rotate(330,15710,14040)'>");
        }
        SB.writeStr(b, string(name));
        SB.writeStr(b, "<animate attributeName='stroke' begin='30s' values='#fff;#000' dur='1s' fill='freeze'/></text></svg>");

        return SB.getString(b);
    }

    function oneTriangle(uint256 x, uint256 y) internal view returns(SB.StringBuilder memory b) {
        b = SB.create(2);
        SB.writeStr(b, "M");
        SB.writeUint(b, x);
        SB.writeStr(b, " ");
        SB.writeUint(b, y);
        SB.writeStr(b, "h500l250 433h-500z");
    }
}