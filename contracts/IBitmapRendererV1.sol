// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IBitmapRendererV1
/// @author typeof.eth
interface IBitmapRendererV1 {
  /// @notice Creates the raw bytes for an 8-bit BMP image.
  /// @dev This function requires that the caller provide a palette, which is an array of colors
  /// that will be used to render the image. This means that the image can only contain colors
  /// that are in the palette. The benefit of this is that, assuming the palette is small, the
  /// image data will be much smaller than the 24-bit BMP.
  /// Note that palette colors is defined in [BLUE, GREEN, RED] order, as that is the order that BMP files expect.
  /// Palette color values must be between 0 and 255, inclusive.
  function create8bitBMPData(
    uint8 width,
    uint8 height,
    uint256[] memory palette,
    uint8[] memory data
  ) external pure returns (bytes memory);

  /// @notice Creates the raw bytes for a 24-bit BMP image.
  /// @dev The data passed in must be an array of pixel color data in [BLUE, GREEN, RED]
  /// order, as that is the order that BMP files expect.
  /// Pixel color values must be between 0 and 255, inclusive.
  function create24bitBMPData(
    uint8 width,
    uint8 height,
    uint256[] memory data
  ) external pure returns (bytes memory);

  /// @notice Creates a base64-encoded 8-bit BMP image
  function createBase64Encoded8bitBMP(
    uint8 width,
    uint8 height,
    uint256[] memory palette,
    uint8[] memory data
  ) external pure returns (string memory);

  /// @notice Creates a base64-encoded 24-bit BMP image
  function createBase64Encoded24bitBMP(
    uint8 width,
    uint8 height,
    uint256[] memory data
  ) external pure returns (string memory);
}
