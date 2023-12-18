// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./BitmapPixelArtCreatorV1.sol";

contract GeraldHamster is ERC721 {
  address owner;
  uint8[3][] palette;
  uint8[] pixelData;
  BitmapPixelArtCreatorV1 bmpRenderer;

  constructor(address _bmpRenderer) ERC721("GeraldHamster", "GHAM") {
    owner = msg.sender;
    bmpRenderer = BitmapPixelArtCreatorV1(_bmpRenderer);
  }

  function setPalette(uint8[3][] memory _palette) public {
    _onlyOwner();
    _beforeInit();
    palette = _palette;
  }

  function setPixelData(uint8[] memory _pixelData) public {
    _onlyOwner();
    _beforeInit();
    pixelData = _pixelData;
  }

  function mint() public {
    _onlyOwner();
    _safeMint(msg.sender, 1);
  }

  function tokenURI(
    uint256 tokenId
  ) public view override(ERC721) returns (string memory) {
    require(tokenId == 1, "ERC721: invalid token ID");
    string memory bmpImage = bmpRenderer.createBase64Encoded8bitBMP(
      32,
      32,
      palette,
      pixelData
    );
    string memory json = string(
      abi.encodePacked(
        '{"name": "Gerald Hamster",',
        '"description": "A cute hamster whose 8-bit BMP data lives on-chain.", "image": "',
        bmpImage,
        '"}'
      )
    );

    return json;
  }

  function _beforeInit() internal view {
    require(
      palette.length == 0 || pixelData.length == 0,
      "Gerald can no longer be modified."
    );
  }

  function _onlyOwner() internal view {
    require(msg.sender == owner, "Only owner can call this function.");
  }
}
