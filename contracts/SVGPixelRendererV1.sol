// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./ISVGPixelRendererV1.sol";

/// @title SVG Pixel Art Renderer V1
/// @author typeof.eth
contract SVGPixelRendererV1 is ISVGPixelRendererV1 {
    using Strings for uint256;

    /// @inheritdoc ISVGPixelRendererV1
    function createSVGString(
        uint256[] memory _design,
        string[] memory _palette,
        uint256 _width,
        uint256 _height,
        uint256 _pixelSize
    ) public pure returns (string memory) {
        return
            string(
                _createSVGData(_design, _palette, _width, _height, _pixelSize)
            );
    }

    /// @inheritdoc ISVGPixelRendererV1
    function createBase64EncodedSVG(
        uint256[] memory _design,
        string[] memory _palette,
        uint256 _width,
        uint256 _height,
        uint256 _pixelSize
    ) public pure returns (string memory) {
        return
            string.concat(
                "data:image/svg+xml;base64,",
                Base64.encode(
                    _createSVGData(
                        _design,
                        _palette,
                        _width,
                        _height,
                        _pixelSize
                    )
                )
            );
    }

    function _createSVGData(
        uint256[] memory _design,
        string[] memory _palette,
        uint256 _width,
        uint256 _height,
        uint256 _pixelSize
    ) internal pure returns (bytes memory) {
        bytes memory styles = abi.encodePacked("rect{height:1px;width:1px;}");

        for (uint256 i = 0; i < _palette.length; i++) {
            styles = abi.encodePacked(
                styles,
                ".f",
                i.toString(),
                "{fill:",
                _palette[i],
                "}"
            );
        }

        uint256 xPosCounter = 0;
        uint256 yPosCounter = 0;
        string[] memory xPosValues = new string[](_width);
        string[] memory yPosValues = new string[](_height);

        bytes memory content;

        for (uint256 i = 0; i < _design.length; i++) {
            if (xPosCounter <= i % _width) {
                xPosValues[i % _width] = (i % _width).toString();
            }
            if (yPosCounter <= i / _width) {
                yPosValues[i / _width] = (i / _width).toString();
            }
            content = abi.encodePacked(
                content,
                '<rect class="f',
                (_design[i]).toString(),
                '" x="',
                xPosValues[i % _width],
                '" y="',
                yPosValues[i / _width],
                '"/>'
            );
        }

        return
            abi.encodePacked(
                '<svg width="',
                (_width * _pixelSize).toString(),
                '" height="',
                (_height * _pixelSize).toString(),
                '" viewBox="0 0 ',
                _width.toString(),
                " ",
                _height.toString(),
                '" xmlns="http://www.w3.org/2000/svg">',
                "<style>",
                styles,
                "</style>",
                content,
                "</svg>"
            );
    }
}
