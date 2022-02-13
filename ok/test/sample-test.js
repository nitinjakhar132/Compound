const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Compound_Middleware Protocol :", function (accounts) {
    
    let MyCompound, mycompoundproxy, owner;
    const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
    const CDAI = "0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643";
    const CETH = "0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5";
    const ACC = "0x9a7A9D980Ed6239b89232C012E21f4c210F4Bef1";
    const comptrollerAddress = "0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B";
    const priceFeedAddress = "0x922018674c12a7F0D394ebEEf9B58F186CdE13c1";
    beforeEach(async function () {

        MyCompound = await ethers.getContractFactory("Compound");
        [owner, _] = await ethers.getSigners();
        mycompoundproxy = await MyCompound.deploy();
        await mycompoundproxy.deployed();
    });

    describe("", function () {
        it("Should supply, borrow, payback & withdraw Erc20 tokens", async function () {

            const dai = ethers.utils.parseUnits("0.000001", 18);
            const daib = ethers.utils.parseUnits("0.0000001", 18);
            let cTokenAmount = 3000;
            const tokenArtifact = await artifacts.readArtifact("IERC20");
            const token = new ethers.Contract(DAI, tokenArtifact.abi, ethers.provider);
            const tokenWithSigner = token.connect(owner);
            const cTokenArtifact = await artifacts.readArtifact("CErc20");
            const cToken = new ethers.Contract(CDAI, cTokenArtifact.abi, ethers.provider);
            const cTokenWithSigner = cToken.connect(owner);

            await network.provider.send("hardhat_setBalance", [
                ACC,
                ethers.utils.parseEther('10.0').toHexString(),
            ]);

            await network.provider.send("hardhat_setBalance", [
                owner.address,
                ethers.utils.parseEther('10.0').toHexString(),
            ]);

            await hre.network.provider.request({
                method: "hardhat_impersonateAccount",
                params: [ACC],
            });

            const signer = await ethers.getSigner(ACC);

            await token.connect(signer).transfer(owner.address, dai);

            await hre.network.provider.request({
                method: "hardhat_stopImpersonatingAccount",
                params: [ACC],
            });

            await tokenWithSigner.approve(mycompoundproxy.address, dai);
            await mycompoundproxy.Deposit(dai, CDAI, DAI);

            console.log("  Deposited Erc20!")
            await mycompoundproxy.Borrow(DAI, CDAI, 18, 100000, [CDAI]);

            console.log("  Borrowed Erc20!")                                                                                  
            await tokenWithSigner.approve(mycompoundproxy.address, 100000);

            await mycompoundproxy.PayBack(DAI, CDAI, 100000);
            console.log("  Payed Back Erc20!")

            await mycompoundproxy.WithDraw(DAI, CDAI, cTokenAmount);
            console.log("  Withdrawn Erc20!")

        }).timeout(40000000);
    });
});