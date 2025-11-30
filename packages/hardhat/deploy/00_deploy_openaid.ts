import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, ethers, getNamedAccounts } = hre;
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  console.log("Deployer:", deployer);

  // Deploy DonationToken
  const donationToken = await deploy("DonationToken", {
    from: deployer,
    args: ["DonationToken", "DHT", deployer],
    log: true,
  });

  // Deploy InKindNFT
  const inKindNFT = await deploy("InKindNFT", {
    from: deployer,
    args: [deployer],
    log: true,
  });

  // Deploy OpenAidCore
  const openAidCore = await deploy("OpenAidCore", {
    from: deployer,
    args: [
      donationToken.address,
      inKindNFT.address,
      deployer
    ],
    log: true,
  });

  console.log("Contracts deployed:");
  console.log("DonationToken:", donationToken.address);
  console.log("InKindNFT:", inKindNFT.address);
  console.log("OpenAidCore:", openAidCore.address);
};

export default func;
func.tags = ["OpenAid"];
