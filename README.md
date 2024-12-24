# Onchain Image Renderers

This project is a collection of Solidity contracts that allow users to generate art on-chain.

## BitmapRendererV1

`BitmapRendererV1` allows callers to generate bitmap images onchain. Images can be generated in two formats: 8-bit and 24-bit. The 8-bit images are generated using a palette and an array of indices, while the 24-bit images are generated using an array of RGB values.

Generally, the 8-bit images are more gas efficient than the 24-bit images, but the 24-bit images provide more flexibility in terms of color selection.

Both 8-bit and 24-bit images can be generated as raw bitmap data or as base64 encoded strings. The function signature for generating base64 encoded images is the same as the function signature for generating raw bitmap data, with the only difference being the return type.

### Addresses

- [Base Mainnet](https://basescan.org/address/0x4256dee61336fcf9325934fcee207bd08d3b5809): `0x4256dee61336fcf9325934fcee207bd08d3b5809`
- [Base Sepolia](https://sepolia.basescan.org/address/0x4256dee61336fcf9325934fcee207bd08d3b5809): `0x4256dee61336fcf9325934fcee207bd08d3b5809`
- [Ink Mainnet](https://explorer.inkonchain.com/address/0xe0413ff96366c1c6c6222892e82cabb867f50d44): `0xe0413ff96366c1c6c6222892e82cabb867f50d44`

### 8-bit image creation

- `create8bitBMPData(...) external pure returns (bytes memory)`
- `createBase64Encoded8bitBMP(...) pure returns (string memory)`

Note: Both functions take the same arguments. For the sake of simplicity, we'll only look at the `create8bitBMPData` function below.

```sol
function create8bitBMPData(
    uint8 width,
    uint8 height,
    uint256[] memory palette,
    uint8[] memory data
) external pure returns (bytes memory);
```

In order to generate an 8-bit image, the caller must provide the width and height of the image, a palette of colors, and an array of numbers that indicate the index of the color to use for that pixel.

The palette is colors to be used in the image, represented as an array of `uint256`. Each `uint256` should represent an RGB color value in hex format. E.g. pure red would be 0xFF0000, pure green would be 0x00FF00, and pure blue would be 0x0000FF.

The data array is an array of numbers where each number represents the index of the color in the palette to use for that pixel. Pixels are written top left to bottom right.

For example, to generate a 3 by 3 image where the colors are as follows:

```
red,green,blue
white,black,white
blue,green,red
```

The caller would do the following:

```sol
bytes memory result = IBitmapRendererV1(contractAddress).create8bitBMPData(
    3,
    3,
    [
        0xFF0000, // 0: red
        0x00FF00, // 1: green
        0x0000FF, // 2: blue
        0xFFFFFF, // 3: white
        0x000000  // 4: black
    ],
    [
        0, 1, 2,
        3, 4, 3,
        2, 1, 0
    ]
);
```

### 24-bit image creation

- `create24bitBMPData(...) external pure returns (bytes memory)`
- `createBase64Encoded24bitBMP(...) pure returns (string memory)`

Note: Both functions take the same arguments. For the sake of simplicity, we'll only look at the `create24bitBMPData` function below.

```sol
function create24bitBMPData(
    uint8 width,
    uint8 height,
    uint8[] memory data
) external pure returns (bytes memory);
```

In order to generate a 24-bit image, the caller must provide the width and height of the image, and an array of RGB values.

The data array is an array of numbers where each number represents the RGB value of the pixel. Pixels are written top left to bottom right.

For example, to generate a 3 by 3 image where the colors are as follows:

```
red,green,blue
white,black,white
blue,green,red
```

The caller would do the following:

```sol
bytes memory result = IBitmapRendererV1(contractAddress).create24bitBMPData(
    3,
    3,
    [
        0xFF0000, 0x00FF00, 0x0000FF,
        0xFFFFFF, 0x000000, 0xFFFFFF,
        0x0000FF, 0x00FF00, 0xFF0000
    ]
);
```

## SVGRendererV1

...todo...
