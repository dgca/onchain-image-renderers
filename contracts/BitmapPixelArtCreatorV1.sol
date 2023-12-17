// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/// @title Bitmap Pixel Art Creator V1
/// @author Daniel Cortes (typeof.eth)
/// @notice This contract provides functions for creating 8-bit and 24-bit BMP pixel art images on-chain.
contract BitmapPixelArtCreatorV1 {
  using Strings for uint256;

  /// @notice Creates a base64-encoded 8-bit BMP image
  function createBase64Encoded8bitBMP(
    uint8 width,
    uint8 height,
    uint8[3][] memory palette,
    uint8[] memory data
  ) external pure returns (string memory) {
    bytes memory bmpData = create8bitBMPData(width, height, palette, data);
    string memory base64EncodedBmpData = Base64.encode(bmpData);
    return
      string(abi.encodePacked("data:image/bmp;base64,", base64EncodedBmpData));
  }

  /// @notice Creates a base64-encoded 24-bit BMP image
  function createBase64Encoded24bitBMP(
    uint8 width,
    uint8 height,
    uint8[3][] memory data
  ) external pure returns (string memory) {
    bytes memory bmpData = create24bitBMPData(width, height, data);
    string memory base64EncodedBmpData = Base64.encode(bmpData);
    return
      string(abi.encodePacked("data:image/bmp;base64,", base64EncodedBmpData));
  }

  /// @notice Creates the raw bytes for an 8-bit BMP image. This function requires that the caller
  /// provide a palette, which is an array of colors that will be used to render the image. This means
  /// that the image can only contain colors that are in the palette. The benefit of this is that, assuming
  /// the palette is small, the image data will be much smaller than the 24-bit BMP. Note that palette colors
  /// is defined in [BLUE, GREEN, RED] order, as that is the order that BMP files expect. Palette color values
  /// range from 0 to 255.
  function create8bitBMPData(
    uint8 width,
    uint8 height,
    uint8[3][] memory palette,
    uint8[] memory data
  ) public pure returns (bytes memory) {
    require(
      data.length == uint256(width) * uint256(height),
      "Data size does not match dimensions"
    );

    // Calculate the size of the file
    uint32 paletteSize = uint32(palette.length * 4); // 4 bytes per color
    uint32 rowSize = uint32(4 * _ceilDiv(width, 4)); // Rows are padded to be multiples of 4 bytes
    uint32 pixelDataSize = rowSize * height;
    uint32 fileSize = 54 + paletteSize + pixelDataSize; // Headers + palette + pixel data

    // Create a buffer for the entire file
    bytes memory bmpFile = new bytes(fileSize);

    // Construct BMP and DIB headers
    // BMP File Header
    bmpFile[0] = 0x42; // 'B'
    bmpFile[1] = 0x4D; // 'M'
    _storeUint32(bmpFile, 2, fileSize);
    _storeUint32(bmpFile, 10, 54 + paletteSize); // Pixel data offset

    // DIB Header
    _storeUint32(bmpFile, 14, 40); // DIB header size
    _storeUint32(bmpFile, 18, width);
    _storeUint32(bmpFile, 22, height);
    _storeUint16(bmpFile, 26, 1); // Planes
    _storeUint16(bmpFile, 28, 8); // Bits per pixel (8 for 8-bit BMP)
    _storeUint32(bmpFile, 30, 0); // Compression
    _storeUint32(bmpFile, 34, pixelDataSize);
    _storeUint32(bmpFile, 38, 2835); // Horizontal resolution
    _storeUint32(bmpFile, 42, 2835); // Vertical resolution
    _storeUint32(bmpFile, 46, uint32(palette.length)); // Number of colors in palette
    _storeUint32(bmpFile, 50, uint32(palette.length)); // Important colors

    // Write palette data
    for (uint32 i = 0; i < palette.length; i++) {
      uint32 paletteIndex = 54 + i * 4;
      bmpFile[paletteIndex] = bytes1(palette[i][0]); // Blue
      bmpFile[paletteIndex + 1] = bytes1(palette[i][1]); // Green
      bmpFile[paletteIndex + 2] = bytes1(palette[i][2]); // Red
      bmpFile[paletteIndex + 3] = 0x00; // Alpha (unused)
    }

    // Write pixel data in bottom-up order
    uint32 pixelDataStartIndex = 54 + paletteSize;
    for (uint32 y = 0; y < height; y++) {
      uint32 reversedY = height - 1 - y; // Reverse the row order
      for (uint32 x = 0; x < width; x++) {
        uint32 dataIndex = reversedY * width + x;
        uint32 pixelIndex = pixelDataStartIndex + y * rowSize + x;
        bmpFile[pixelIndex] = bytes1(data[dataIndex]);
      }
      // Add padding to each row
      for (uint32 p = width; p < rowSize; p++) {
        bmpFile[pixelDataStartIndex + y * rowSize + p] = 0;
      }
    }

    return bmpFile;
  }

  /// @notice Creates the raw bytes for a 24-bit BMP image. The data passed in must be an array of
  /// pixel color data in [BLUE, GREEN, RED] order, as that is the order that BMP files expect.
  /// Pixel color values range from 0 to 255.
  function create24bitBMPData(
    uint8 width,
    uint8 height,
    uint8[3][] memory data
  ) public pure returns (bytes memory) {
    require(
      data.length == uint256(width) * uint256(height),
      "Data size does not match dimensions"
    );

    // Calculate the size of the file
    uint32 rowSize = uint32(4 * _ceilDiv(width * 3, 4)); // Rows are padded to be multiples of 4 bytes
    uint32 pixelDataSize = rowSize * height;
    uint32 fileSize = 54 + pixelDataSize; // Headers + pixel data

    // Create a buffer for the entire file
    bytes memory bmpFile = new bytes(fileSize);

    // Construct BMP and DIB headers
    // BMP File Header
    bmpFile[0] = 0x42; // 'B'
    bmpFile[1] = 0x4D; // 'M'
    _storeUint32(bmpFile, 2, fileSize);
    _storeUint32(bmpFile, 10, 54); // Pixel data offset

    // DIB Header
    _storeUint32(bmpFile, 14, 40); // DIB header size
    _storeUint32(bmpFile, 18, width);
    _storeUint32(bmpFile, 22, height);
    _storeUint16(bmpFile, 26, 1); // Planes
    _storeUint16(bmpFile, 28, 24); // Bits per pixel (24 for 24-bit BMP)
    _storeUint32(bmpFile, 30, 0); // Compression
    _storeUint32(bmpFile, 34, pixelDataSize);
    _storeUint32(bmpFile, 38, 2835); // Horizontal resolution
    _storeUint32(bmpFile, 42, 2835); // Vertical resolution
    _storeUint32(bmpFile, 46, 0); // Number of colors in palette
    _storeUint32(bmpFile, 50, 0); // Important colors

    // Write pixel data in bottom-up order
    uint32 pixelDataStartIndex = 54;
    for (uint32 y = 0; y < height; y++) {
      uint32 reversedY = height - 1 - y; // Reverse the row order
      for (uint32 x = 0; x < width; x++) {
        uint32 dataIndex = reversedY * width + x;
        uint32 pixelIndex = pixelDataStartIndex + y * rowSize + x * 3;
        bmpFile[pixelIndex] = bytes1(data[dataIndex][0]); // Blue
        bmpFile[pixelIndex + 1] = bytes1(data[dataIndex][1]); // Green
        bmpFile[pixelIndex + 2] = bytes1(data[dataIndex][2]); // Red
      }
      // Add padding to each row
      for (uint32 p = width * 3; p < rowSize; p++) {
        bmpFile[pixelDataStartIndex + y * rowSize + p] = 0;
      }
    }

    return bmpFile;
  }

  function _storeUint32(
    bytes memory buffer,
    uint256 offset,
    uint32 value
  ) internal pure {
    for (uint i = 0; i < 4; i++) {
      buffer[offset + i] = bytes1(uint8(value / (2 ** (8 * i))));
    }
  }

  function _storeUint16(
    bytes memory buffer,
    uint256 offset,
    uint16 value
  ) internal pure {
    for (uint i = 0; i < 2; i++) {
      buffer[offset + i] = bytes1(uint8(value / (2 ** (8 * i))));
    }
  }

  function _ceilDiv(uint a, uint b) internal pure returns (uint) {
    return (a + b - 1) / b;
  }

  // Below are example functions that show how to use this contract
  // ===============================================================

  /// @notice Returns an example palette that is used by the example functions below
  function _getTestPalette() internal pure returns(uint8[3][] memory) {
    uint8[3][] memory palette = new uint8[3][](8);
    palette[0] = [255, 0, 0]; // Blue
    palette[1] = [0, 255, 0]; // Green
    palette[2] = [0, 0, 255]; // Red
    palette[3] = [255, 255, 0]; // Yellow
    palette[4] = [0, 255, 255]; // Cyan
    palette[5] = [255, 255, 255]; // White
    palette[6] = [0, 0, 0]; // Black
    palette[7] = [128, 128, 128]; // Gray
    return palette;
  }

  /// @notice Creates an example 8-bit BMP image
  function getExampleBase64Encoded8bitBMP()
    external
    pure
    returns (string memory)
  {
    uint8[3][] memory palette = _getTestPalette();
    uint8 width = 20;
    uint8 height = 20;
    uint256 size = uint256(width) * uint256(height);

    // The 8-bit BMP uses a palette, so we can just create an array of indices
    // into the palette and use that as the pixel data.
    uint8[] memory pixelData = new uint8[](size);
    for (uint32 i = 0; i < size; i++) {
      pixelData[i] = uint8(i % palette.length);
    }

    // Call the function to create the 8-bit bmp. Unlike the 24-bit bmp, we
    // must pass the palette as an argument.
    bytes memory bmpData = create8bitBMPData(width, height, palette, pixelData);

    return
      string(
        abi.encodePacked("data:image/bmp;base64,", Base64.encode(bmpData))
      );
  }

  /// @notice Creates an example 24-bit BMP image
  function getExampleBase64Encoded24bitBMP()
    external
    pure
    returns (string memory)
  {
    uint8[3][] memory palette = _getTestPalette();
    uint8 width = 20;
    uint8 height = 20;
    uint256 size = uint256(width) * uint256(height);

    // Because the 24-bit BMP does not use a palette, we extract the color value
    // from the palette and use that as the pixel data.
    uint8[3][] memory pixelData = new uint8[3][](size);
    for (uint32 i = 0; i < size; i++) {
      pixelData[i] = palette[i % palette.length];
    }

    bytes memory bmpData = create24bitBMPData(width, height, pixelData);
    return
      string(
        abi.encodePacked("data:image/bmp;base64,", Base64.encode(bmpData))
      );
  }
}
