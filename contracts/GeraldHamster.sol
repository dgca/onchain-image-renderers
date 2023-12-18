// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./BitmapPixelArtCreatorV1.sol";

// ~ * ~ <3 Gerald Hamster <3 ~ * ~
// 22222222222222222222222200222222
// 22222222222222222222222000002222
// 22222222222222222222000000000222
// 20022222222222222222222222222222
// 00002222111221111112211112222222
// 00000221677116667771166771222220
// 00000021667116666671166671222000
// 00000221576666666666675671220000
// 22222221556666666666655671222222
// 22222222166666666666677771222222
// 22222221661066666106671112222222
// 22222216661160066116677771222222
// 22222216661100000116667771222222
// 22222166600007000006667777122222
// 22222160000011100000066777122222
// 22222130000001000000033377712222
// 22221333000000000000333337771222
// 22221000001100001100000333771222
// 22221000000510015000000003771222
// 22221000055510015550000003771222
// 22221000011140041110000003371222
// 22221000044400004440000003371222
// 22221300000000000000000034441222
// 22221533000000000000003344451222
// 22222155300000000000334444512222
// 66776611530011111003444455176677
// 66774455153144554134111111554677
// 77665544511455445511554455445766
// 77667544554455445544554455447766
// 66776675445544554455445544776677
// 66776677667766776677667766776677
// 77667766776677667766776677667766

contract GeraldHamster is ERC721 {
  address owner;
  uint8[3][] palette;
  uint8[] pixelData;
  BitmapPixelArtCreatorV1 bmpRenderer;

  uint256 private _nextTokenId;

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

  function safeMint() public {
    uint256 tokenId = _nextTokenId++;
    _safeMint(msg.sender, tokenId);
  }

  function tokenURI(
    uint256 _tokenId
  ) public view override(ERC721) returns (string memory) {
    require(_nextTokenId > _tokenId, "ERC721: invalid token ID");
    string memory bmpImage = bmpRenderer.createBase64Encoded8bitBMP(
      32,
      32,
      palette,
      pixelData
    );
    string memory json = string(
      abi.encodePacked(
        '{"name": "Gerald Hamster #',
        Strings.toString(_tokenId),
        '",'
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
