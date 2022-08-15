async function main() {
  console.log('0')
  const [artist, collector1, collector2, collector3] = await ethers.getSigners()
  console.log('1')

  TerminallyOnlineFactory = await ethers.getContractFactory('TerminallyOnline', artist)
  TerminallyOnline = await TerminallyOnlineFactory.deploy()
  await TerminallyOnline.deployed()

  MultisigFactory = await ethers.getContractFactory('Multisig', artist)
  Multisig = await MultisigFactory.deploy(TerminallyOnline.address)
  await Multisig.deployed()

  TokenURIFactory = await ethers.getContractFactory('TokenURI', artist)
  TokenURI = await TokenURIFactory.deploy(TerminallyOnline.address)
  await TokenURI.deployed()

  await TerminallyOnline.connect(artist).setTokenURIContract(TokenURI.address)
  await TerminallyOnline.connect(artist).setMultisigContract(Multisig.address)


  await TerminallyOnline.connect(artist).mint(collector1.address, 0)
  await TerminallyOnline.connect(artist).mint(collector1.address, 1)
  await TerminallyOnline.connect(artist).mint(collector1.address, 2)
  await TerminallyOnline.connect(artist).mint(collector1.address, 3)

  await TerminallyOnline.connect(artist).mint(collector2.address, 4)
  await TerminallyOnline.connect(artist).mint(collector2.address, 5)
  await TerminallyOnline.connect(artist).mint(collector2.address, 6)
  await TerminallyOnline.connect(artist).mint(collector2.address, 7)

  await TerminallyOnline.connect(artist).mint(collector3.address, 8)
  await TerminallyOnline.connect(artist).mint(collector3.address, 9)
  await TerminallyOnline.connect(artist).mint(collector3.address, 10)
  await TerminallyOnline.connect(artist).mint(collector3.address, 11)


  console.log(`TerminallyOnline:`, TerminallyOnline.address)
  console.log(`Multisig:`, Multisig.address)
  console.log(`TokenURI:`, TokenURI.address)
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });