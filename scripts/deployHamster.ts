import hre from "hardhat";

async function main() {
  const geraldHamster = await hre.viem.deployContract("GeraldHamster", [
    "0x52d12c26f1cc5d54033f6b7030b2b4b83ab74023",
  ]);
  console.log(`GeraldHamster deployed to ${geraldHamster.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
