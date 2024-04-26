import hre from "hardhat";

async function main() {
  const bitmapRendererV1 = await hre.viem.deployContract(
    "BitmapRendererV1",
  );
  console.log(
    `BitmapRendererV1 deployed to ${bitmapRendererV1.address}`,
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
