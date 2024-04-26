// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./IBitmapRendererV1.sol";

/// @title Bitmap Renderer V1
/// @author typeof.eth
contract BitmapRendererV1 is IBitmapRendererV1 {
    using Strings for uint256;

    /// @inheritdoc IBitmapRendererV1
    function create8bitBMPData(
        uint8 _width,
        uint8 _height,
        uint256[] memory _palette,
        uint8[] memory _data
    ) public pure returns (bytes memory) {
        if (_data.length != uint256(_width) * uint256(_height)) {
            revert InvalidSize();
        }

        // Calculate the size of the file
        uint32 paletteSize = uint32(_palette.length * 4); // 4 bytes per color
        uint32 rowSize = uint32(4 * _ceilDiv(_width, 4)); // Rows are padded to be multiples of 4 bytes
        uint32 pixelDataSize = rowSize * _height;
        uint32 fileSize = 54 + paletteSize + pixelDataSize; // Headers + palette + pixel data

        // Create a buffer for the entire file
        bytes memory fileBuffer = new bytes(fileSize);

        // Construct BMP and DIB headers
        // BMP File Header
        fileBuffer[0] = 0x42; // 'B'
        fileBuffer[1] = 0x4D; // 'M'

        _storeUint32(fileBuffer, 2, fileSize);
        _storeUint32(fileBuffer, 10, 54 + paletteSize); // Pixel data offset

        // DIB Header
        _storeUint32(fileBuffer, 14, 40); // DIB header size
        _storeUint32(fileBuffer, 18, _width);
        _storeUint32(fileBuffer, 22, _height);

        _storeUint16(fileBuffer, 26, 1); // Planes
        _storeUint16(fileBuffer, 28, 8); // Bits per pixel (8 for 8-bit BMP)

        _storeUint32(fileBuffer, 30, 0); // Compression
        _storeUint32(fileBuffer, 34, pixelDataSize);
        _storeUint32(fileBuffer, 38, 2835); // Horizontal resolution
        _storeUint32(fileBuffer, 42, 2835); // Vertical resolution
        _storeUint32(fileBuffer, 46, uint32(_palette.length)); // Number of colors in palette
        _storeUint32(fileBuffer, 50, uint32(_palette.length)); // Important colors

        // Write palette data
        assembly {
            let bufferDataStart := add(fileBuffer, add(0x20, 54)) // Starting index for color data in fileBuffer
            let paletteDataStart := add(_palette, 0x20) // Pointer to the start of the palette data segment
            let paletteLength := mload(_palette) // Load the length of the palette

            for {
                let i := 0
            } lt(i, paletteLength) {
                i := add(i, 1)
            } {
                let bufferPtr := add(bufferDataStart, mul(i, 4))
                let colors := mload(add(paletteDataStart, mul(i, 0x20)))

                // Store blue
                mstore8(bufferPtr, and(colors, 0xFF))
                // Store green
                mstore8(add(bufferPtr, 1), and(shr(8, colors), 0xFF))
                // Store red
                mstore8(add(bufferPtr, 2), and(shr(16, colors), 0xFF))
                // Alpha channel is always 0
                mstore8(add(bufferPtr, 3), 0)
            }
        }

        // Write the pixel data to the file buffer
        // Note: The BMP format stores pixel data in bottom-up order,
        // so the last row in the pixel data goes first in the file buffer
        assembly {
            let pixelDataStart := add(
                add(fileBuffer, 0x20),
                add(54, paletteSize)
            ) // Start of pixel data

            for {
                let y := 0
            } lt(y, _height) {
                y := add(y, 1)
            } {
                // Get the inverse of the current y value so we can
                // jump to the right place in the data array
                let invertedY := sub(_height, add(y, 1))
                // Where we'll start writing the data into the buffer
                let bufferDataStart := add(pixelDataStart, mul(y, rowSize))

                for {
                    let x := 0
                } lt(x, _width) {
                    x := add(x, 1)
                } {
                    // Location of current pixel to write
                    let pixelDataIndex := add(mul(invertedY, _width), x)
                    mstore8(
                        add(bufferDataStart, x),
                        mload(add(add(_data, 0x20), mul(pixelDataIndex, 0x20)))
                    )
                }

                // Add padding to each row if necessary
                for {
                    let p := _width
                } lt(p, rowSize) {
                    p := add(p, 1)
                } {
                    mstore8(add(bufferDataStart, p), 0)
                }
            }
        }

        return fileBuffer;
    }

    /// @inheritdoc IBitmapRendererV1
    function create24bitBMPData(
        uint8 _width,
        uint8 _height,
        uint256[] memory _data
    ) public pure returns (bytes memory) {
        if (_data.length != uint256(_width) * uint256(_height)) {
            revert InvalidSize();
        }

        // Calculate the size of the file
        uint32 rowSize = uint32(4 * _ceilDiv(_width * 3, 4)); // Rows are padded to be multiples of 4 bytes
        uint32 pixelDataSize = rowSize * _height;
        uint32 fileSize = 54 + pixelDataSize; // Headers + pixel data

        // Create a buffer for the entire file
        bytes memory fileBuffer = new bytes(fileSize);

        // Construct BMP and DIB headers
        // BMP File Header
        fileBuffer[0] = 0x42; // 'B'
        fileBuffer[1] = 0x4D; // 'M'
        _storeUint32(fileBuffer, 2, fileSize);
        _storeUint32(fileBuffer, 10, 54); // Pixel data offset

        // DIB Header
        _storeUint32(fileBuffer, 14, 40); // DIB header size
        _storeUint32(fileBuffer, 18, _width);
        _storeUint32(fileBuffer, 22, _height);
        _storeUint16(fileBuffer, 26, 1); // Planes
        _storeUint16(fileBuffer, 28, 24); // Bits per pixel (24 for 24-bit BMP)
        _storeUint32(fileBuffer, 30, 0); // Compression
        _storeUint32(fileBuffer, 34, pixelDataSize);
        _storeUint32(fileBuffer, 38, 2835); // Horizontal resolution
        _storeUint32(fileBuffer, 42, 2835); // Vertical resolution
        _storeUint32(fileBuffer, 46, 0); // Number of colors in palette
        _storeUint32(fileBuffer, 50, 0); // Important colors

        // Write pixel data in bottom-up order
        uint32 pixelDataStartIndex = 54;
        assembly {
            let dataStart := add(_data, 0x20)
            let bufferStart := add(fileBuffer, 0x20)
            for {
                let y := 0
            } lt(y, _height) {
                y := add(y, 1)
            } {
                // Get the inverse of the current y value so we can
                // jump to the right place in the data array
                let invertedY := sub(_height, add(y, 1))
                for {
                    let x := 0
                } lt(x, _width) {
                    x := add(x, 1)
                } {
                    let dataIndex := add(mul(invertedY, _width), x)
                    let pixelIndex := add(
                        pixelDataStartIndex,
                        add(mul(y, rowSize), mul(x, 3))
                    )
                    let pixelData := mload(add(dataStart, mul(dataIndex, 0x20)))
                    // Blue
                    mstore8(add(bufferStart, pixelIndex), and(pixelData, 0xFF))
                    // Green
                    mstore8(
                        add(bufferStart, add(pixelIndex, 1)),
                        and(shr(8, pixelData), 0xFF)
                    )
                    // Red
                    mstore8(
                        add(bufferStart, add(pixelIndex, 2)),
                        and(shr(16, pixelData), 0xFF)
                    )
                }

                // Add padding to each row
                for {
                    let p := mul(_width, 3)
                } lt(p, rowSize) {
                    p := add(p, 1)
                } {
                    mstore8(
                        add(
                            bufferStart,
                            add(pixelDataStartIndex, add(mul(y, rowSize), p))
                        ),
                        0
                    )
                }
            }
        }

        return fileBuffer;
    }

    /// @inheritdoc IBitmapRendererV1
    function createBase64Encoded8bitBMP(
        uint8 _width,
        uint8 _height,
        uint256[] memory _palette,
        uint8[] memory _data
    ) external pure returns (string memory) {
        bytes memory bmpData = create8bitBMPData(
            _width,
            _height,
            _palette,
            _data
        );
        string memory base64EncodedBmpData = Base64.encode(bmpData);
        return
            string(
                abi.encodePacked("data:image/bmp;base64,", base64EncodedBmpData)
            );
    }

    /// @inheritdoc IBitmapRendererV1
    function createBase64Encoded24bitBMP(
        uint8 _width,
        uint8 _height,
        uint256[] memory _data
    ) external pure returns (string memory) {
        bytes memory bmpData = create24bitBMPData(_width, _height, _data);
        string memory base64EncodedBmpData = Base64.encode(bmpData);
        return
            string(
                abi.encodePacked("data:image/bmp;base64,", base64EncodedBmpData)
            );
    }

    /// @notice Stores a uint32 value in the buffer starting at the specified index
    function _storeUint32(
        bytes memory _buffer,
        uint256 _index,
        uint32 _value
    ) internal pure {
        assembly {
            // Add 0x20 bytes to the start index to account for the length of the bytes array
            let ptr := add(_buffer, add(_index, 0x20))

            // Store each byte of `value` in the buffer one byte at a time
            // Since uint32 is 4 bytes, we do this 4 times shifting 8 bits each time
            mstore8(ptr, and(_value, 0xFF))
            mstore8(add(ptr, 1), and(shr(8, _value), 0xFF))
            mstore8(add(ptr, 2), and(shr(16, _value), 0xFF))
            mstore8(add(ptr, 3), and(shr(24, _value), 0xFF))
        }
    }

    /// @notice Stores a uint16 value in the buffer starting at the specified index
    /// Implementation is the same as _storeUint32 but with 2 bytes instead of 4
    function _storeUint16(
        bytes memory _buffer,
        uint256 _index,
        uint16 _value
    ) internal pure {
        assembly {
            let ptr := add(_buffer, add(_index, 0x20))
            mstore8(ptr, and(_value, 0xFF))
            mstore8(add(ptr, 1), and(shr(8, _value), 0xFF))
        }
    }

    /// @notice Performs division on two uints and rounds up to the nearest whole number
    function _ceilDiv(uint _a, uint _b) internal pure returns (uint) {
        return (_a + _b - 1) / _b;
    }
}
