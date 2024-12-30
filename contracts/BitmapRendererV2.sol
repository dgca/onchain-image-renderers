// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BitmapRendererV2 {
    function create8bitBMPData(
        uint8 _width,
        uint8 _height,
        uint24[] memory _palette,
        uint8[] memory _data
    ) public pure returns (bytes memory) {
        // Calculate the size of the file
        uint32 paletteSize; // 4 bytes per color
        uint32 rowSize; // Rows are padded to be multiples of 4 bytes
        uint32 pixelDataSize;
        uint32 fileSize; // Headers + palette + pixel data

        assembly {
            paletteSize := mul(mload(_palette), 4)
            rowSize := mul(4, div(add(_width, sub(4, 1)), 4))
            pixelDataSize := mul(rowSize, _height)
            fileSize := add(54, add(paletteSize, pixelDataSize))
        }

        bytes memory fileBuffer = new bytes(fileSize);

        // Construct BMP and DIB headers

        // BMP File Header
        fileBuffer[0] = 0x42; // 'B'
        fileBuffer[1] = 0x4D; // 'M'

        assembly {
            function storeUint32(_buffer, _index, _value) {
                // Add 0x20 bytes to the start index to account for the length of the bytes array
                let ptr := add(_buffer, add(_index, 0x20))

                // Store each byte of `value` in the buffer one byte at a time
                // Since uint32 is 4 bytes, we do this 4 times shifting 8 bits each time
                mstore8(ptr, and(_value, 0xFF))
                mstore8(add(ptr, 1), and(shr(8, _value), 0xFF))
                mstore8(add(ptr, 2), and(shr(16, _value), 0xFF))
                mstore8(add(ptr, 3), and(shr(24, _value), 0xFF))
            }

            function storeUint16(_buffer, _index, _value) {
                // Add 0x20 bytes to the start index to account for the length of the bytes array
                let ptr := add(_buffer, add(_index, 0x20))

                // Store each byte of `value` in the buffer one byte at a time
                // Since uint32 is 4 bytes, we do this 4 times shifting 8 bits each time
                mstore8(ptr, and(_value, 0xFF))
                mstore8(add(ptr, 1), and(shr(8, _value), 0xFF))
            }

            storeUint32(fileBuffer, 2, fileSize)
            storeUint32(fileBuffer, 10, add(54, paletteSize)) // Pixel data offset

            // DIB Header
            storeUint32(fileBuffer, 14, 40) // DIB header size
            storeUint32(fileBuffer, 18, _width)
            storeUint32(fileBuffer, 22, _height)

            storeUint16(fileBuffer, 26, 1) // Planes
            storeUint16(fileBuffer, 28, 8) // Bits per pixel (8 for 8-bit BMP)

            storeUint32(fileBuffer, 30, 0) // Compression
            storeUint32(fileBuffer, 34, pixelDataSize)
            storeUint32(fileBuffer, 38, 2835) // Horizontal resolution
            storeUint32(fileBuffer, 42, 2835) // Vertical resolution
            storeUint32(fileBuffer, 46, mload(_palette)) // Number of colors in palette
            storeUint32(fileBuffer, 50, mload(_palette)) // Important colors
        }

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
                let nextBufferDataStart := add(pixelDataStart, mul(y, rowSize))

                for {
                    let x := 0
                } lt(x, _width) {
                    x := add(x, 1)
                } {
                    // Location of current pixel to write
                    let pixelDataIndex := add(mul(invertedY, _width), x)
                    mstore8(
                        add(nextBufferDataStart, x),
                        mload(add(add(_data, 0x20), mul(pixelDataIndex, 0x20)))
                    )
                }

                // Add padding to each row if necessary
                for {
                    let p := _width
                } lt(p, rowSize) {
                    p := add(p, 1)
                } {
                    mstore8(add(nextBufferDataStart, p), 0)
                }
            }
        }

        return fileBuffer;
    }
}
