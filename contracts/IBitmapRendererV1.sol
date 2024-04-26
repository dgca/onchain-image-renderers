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
  /// Note that palette colors is should be provided as hex numbers representing their RRGGBB value
  /// such as 0xFF0000 for red, 0x00FF00 for green, and so on.
  function create8bitBMPData(
    uint8 width,
    uint8 height,
    uint256[] memory palette,
    uint8[] memory data
  ) external pure returns (bytes memory);

  /// @notice Creates the raw bytes for a 24-bit BMP image.
  /// @dev Pixel color values should be provided as hex numbers representing
  /// their RRGGBB value such as 0xFF0000 for red, 0x00FF00 for green, and so on.
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
