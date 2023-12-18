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

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
