async function main() {

  const [deployer] = await ethers.getSigners();
  const StakingToken = await ethers.getContractFactory("StakingToken");

  const name = "Staking Token";
  const symbol = "STK";
  const decimals = 18;
  const initialSupply = ethers.utils.parseEther("10");

  const stakingtoken = await StakingToken.deploy(name, symbol, decimals, initialSupply);

  console.log("StakingToken Address: ", stakingtoken.address);
  console.log("Admin : ", deployer.address);
}

main().then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });

//  C.A = 0x5558692f58056c9a168b60b1f7Dc60ef1A28465b

// Admin = 0x3816BA21dCC9dfD3C714fFDB987163695408653F
