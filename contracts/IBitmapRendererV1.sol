// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IBitmapRendererV1
/// @author typeof.eth
interface IBitmapRendererV1 {
    error InvalidSize();

    /// @notice Creates the raw bytes for an 8-bit BMP image.
    /// @dev This function requires that the caller provide a palette, which is an array of colors
    /// that will be used to render the image. This means that the image can only contain colors
    /// that are in the palette. The benefit of this is that, assuming the palette is small, the
    /// image data will be much smaller than the 24-bit BMP.
    /// @param _width The width of the image.
    /// @param _height The height of the image.
    /// @param _palette An array of colors that will be used to render the image.
    /// @param _data An array of pixel values that represent index of the color in the palette. E.g. 0xFF0000 for red.
    /// @return The raw bytes of the 8-bit BMP image.
    function create8bitBMPData(
        uint8 _width,
        uint8 _height,
        uint256[] memory _palette,
        uint8[] memory _data
    ) external pure returns (bytes memory);

    /// @notice Creates the raw bytes for a 24-bit BMP image.
    /// @param _width The width of the image.
    /// @param _height The height of the image.
    /// @param _data An array of pixel values that represent the hex color of the pixel.
    /// @return The raw bytes of the 24-bit BMP image.
    function create24bitBMPData(
        uint8 _width,
        uint8 _height,
        uint256[] memory _data
    ) external pure returns (bytes memory);

    /// @notice Creates a base64-encoded 8-bit BMP image
    /// @param _width The width of the image.
    /// @param _height The height of the image.
    /// @param _palette An array of colors that will be used to render the image.
    /// @param _data An array of pixel values that represent index of the color in the palette. E.g. 0xFF0000 for red.
    /// @return A base64-encoded 8-bit BMP image.
    function createBase64Encoded8bitBMP(
        uint8 _width,
        uint8 _height,
        uint256[] memory _palette,
        uint8[] memory _data
    ) external pure returns (string memory);

    /// @notice Creates a base64-encoded 24-bit BMP image
    /// @param _width The width of the image.
    /// @param _height The height of the image.
    /// @param _data An array of pixel values that represent the hex color of the pixel.
    /// @return A base64-encoded 24-bit BMP image.
    function createBase64Encoded24bitBMP(
        uint8 _width,
        uint8 _height,
        uint256[] memory _data
    ) external pure returns (string memory);
}
