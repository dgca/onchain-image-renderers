// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title SVG Pixel Art Creator V1
 * @author Daniel Cortes (typeof.eth)
 * @notice This Solidity contract is licensed under the MIT License.
 * @dev This contract provides functions for creating SVG pixel art images on-chain.
 */

library SvgPixelArtCreatorV1 {
  using Strings for uint256;

  function createSVG(
    uint256[] memory _design,
    string[] memory _palette,
    uint256 _width,
    uint256 _height,
    uint256 _pixelSize
  ) public pure returns (string memory) {
    uint256 width = _width * _pixelSize;
    uint256 height = _height * _pixelSize;

    string memory startTag = string(
      abi.encodePacked(
        '<svg width="',
        width.toString(),
        '" height="',
        height.toString(),
        '" viewBox="0 0 ',
        width.toString(),
        " ",
        height.toString(),
        '" fill="none" xmlns="http://www.w3.org/2000/svg">'
      )
    );

    string memory defs = "";

    for (uint256 i = 0; i < _palette.length; i++) {
      defs = string(
        abi.encodePacked(
          defs,
          '<rect id="i',
          i.toString(),
          '" width="',
          _pixelSize.toString(),
          '" height="',
          _pixelSize.toString(),
          '" fill="',
          _palette[i],
          '"/>'
        )
      );
    }

    defs = string(abi.encodePacked("<defs>", defs, "</defs>"));

    string memory content = "";

    for (uint256 i = 0; i < _design.length; i++) {
      uint256 xPos = (i % _width) * _pixelSize;
      uint256 yPos = (i / _width) * _pixelSize;

      content = string(
        abi.encodePacked(
          content,
          '<use href="#i',
          _design[i].toString(),
          '" x="',
          xPos.toString(),
          '" y="',
          yPos.toString(),
          '"/>'
        )
      );
    }

    return string(abi.encodePacked(startTag, defs, content, "</svg>"));
  }

  function createBase64EncodedSVG(
    uint256[] memory _design,
    string[] memory _palette,
    uint256 _width,
    uint256 _height,
    uint256 _pixelSize
  ) public pure returns (string memory) {
    return
      string(
        abi.encodePacked(
          "data:image/svg+xml;base64,",
          Base64.encode(
            abi.encodePacked(
              createSVG(_design, _palette, _width, _height, _pixelSize)
            )
          )
        )
      );
  }
}
