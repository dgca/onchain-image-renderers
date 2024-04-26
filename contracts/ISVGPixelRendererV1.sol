// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISVGPixelRendererV1 {
    /// @notice This function creates an SVG string based on the provided design, palette, width, height, and pixel size.
    /// @param _design An array of integers representing the design of the pixel art.
    /// @param _palette An array of strings representing the color palette for the pixel art.
    /// @param _width The width of the pixel art.
    /// @param _height The height of the pixel art.
    /// @param _pixelSize The size of each pixel in the pixel art.
    /// @return An SVG string of the pixel art.
    function createSVGString(
        uint256[] calldata _design,
        string[] calldata _palette,
        uint256 _width,
        uint256 _height,
        uint256 _pixelSize
    ) external pure returns (string memory);

    /// @notice This function creates a base64 encoded SVG string based on the provided design, palette, width, height, and pixel size.
    /// @param _design An array of integers representing the design of the pixel art.
    /// @param _palette An array of strings representing the color palette for the pixel art.
    /// @param _width The width of the pixel art.
    /// @param _height The height of the pixel art.
    /// @param _pixelSize The size of each pixel in the pixel art.
    /// @return A base64 encoded SVG string of the pixel art.
    function createBase64EncodedSVG(
        uint256[] calldata _design,
        string[] calldata _palette,
        uint256 _width,
        uint256 _height,
        uint256 _pixelSize
    ) external pure returns (string memory);
}
