import hre from "hardhat";

async function main() {
  const bitmapRenderer = await hre.viem.deployContract("BitmapRenderer");
  console.log(
    `BitmapRenderer deployed to ${bitmapRenderer.address}`
  );

  const svgRenderer = await hre.viem.deployContract("SvgRenderer");
  console.log(
    `SvgRenderer deployed to ${svgRenderer.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
