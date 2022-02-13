require("@nomiclabs/hardhat-waffle");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */

/**
 * hardhat Using moralis: https://speedy-nodes-nyc.moralis.io/67512f506bd8b31944b31a12/eth/mainnet
 */
let secret = require("./secret");
module.exports = {
  solidity: "0.8.3",
  networks: {
    hardhat: {
      forking: {
        url : "https://eth-mainnet.alchemyapi.io/v2/nD2QQLNkwZox38QIQvq4-vCjTVRmVwqH",
      }
    }
  }
};
