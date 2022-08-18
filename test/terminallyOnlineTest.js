const { expect } = require('chai')
const { ethers, waffle } = require('hardhat')
const { expectRevert } = require('@openzeppelin/test-helpers')




const num = n => Number(ethers.utils.formatEther(n))
const b64Clean = raw => raw.replace(/data.*,/, '')
const b64Decode = raw => Buffer.from(b64Clean(raw), 'base64').toString()
const getJsonURI = rawURI => JSON.stringify(JSON.parse(b64Decode(rawURI)), null, 4)

const encodeWithSignature = (functionName, argTypes, params) => {
  const iface = new ethers.utils.Interface([`function ${functionName}(${argTypes.join(',')})`])
  return iface.encodeFunctionData(functionName, params)
}

const emptyEncoded = () => {
  const iface = new ethers.utils.Interface([])
  return iface.encodeFunctionData('')
}

describe('TerminallyOnline', () => {
  const provider = waffle.provider
  let artist, collector1, collector2, collector3
  let projectEventCalldata
  let TerminallyOnline, Multisig, TerminallyOnlineFactory, TokenURI, MultisigFactory, TokenURIFactory
  let sixVotes

  beforeEach(async () => {
    // await network.provider.send("hardhat_reset", [
    //   {
    //     forking: {
    //       jsonRpcUrl: config.networks.hardhat.forking.url,
    //       blockNumber: config.networks.hardhat.forking.blockNumber,
    //     },
    //   },
    // ])

    const signers = await ethers.getSigners()

    artist = signers[0]
    collector1 = signers[1]
    collector2 = signers[2]
    collector3 = signers[3]

    TerminallyOnlineFactory = await ethers.getContractFactory('TerminallyOnline', artist)
    TerminallyOnline = await TerminallyOnlineFactory.deploy()
    await TerminallyOnline.deployed()

    MultisigFactory = await ethers.getContractFactory('Multisig')
    Multisig = await MultisigFactory.attach(
      await TerminallyOnline.connect(artist).multisig()
    )

    TokenURIFactory = await ethers.getContractFactory('TokenURI')
    TokenURI = await TokenURIFactory.attach(
      await TerminallyOnline.connect(artist).tokenURIContract()
    )

    await TerminallyOnline.connect(artist).transferFrom(artist.address, collector1.address, 0)
    await TerminallyOnline.connect(artist).transferFrom(artist.address, collector1.address, 1)
    await TerminallyOnline.connect(artist).transferFrom(artist.address, collector1.address, 2)
    await TerminallyOnline.connect(artist).transferFrom(artist.address, collector1.address, 3)

    await TerminallyOnline.connect(artist).transferFrom(artist.address, collector2.address, 4)
    await TerminallyOnline.connect(artist).transferFrom(artist.address, collector2.address, 5)
    await TerminallyOnline.connect(artist).transferFrom(artist.address, collector2.address, 6)
    await TerminallyOnline.connect(artist).transferFrom(artist.address, collector2.address, 7)

    await TerminallyOnline.connect(artist).transferFrom(artist.address, collector3.address, 8)
    await TerminallyOnline.connect(artist).transferFrom(artist.address, collector3.address, 9)
    await TerminallyOnline.connect(artist).transferFrom(artist.address, collector3.address, 10)
    await TerminallyOnline.connect(artist).transferFrom(artist.address, collector3.address, 11)

    projectEventCalldata = encodeWithSignature('emitProjectEvent', ['string', 'string'], ['event', 'content'])
    sixVotes = proposalId => Promise.all([
      Multisig.connect(collector1).castVote(proposalId, 1, true),
      Multisig.connect(collector1).castVote(proposalId, 2, true),
      Multisig.connect(collector1).castVote(proposalId, 3, true),
      Multisig.connect(collector2).castVote(proposalId, 4, true),
      Multisig.connect(collector2).castVote(proposalId, 5, true),
      Multisig.connect(collector2).castVote(proposalId, 6, true),
    ])
  })


  describe('voting', () => {
    it('propose/hashProposal should work', async () => {
      await Multisig.connect(collector1).propose(0, TerminallyOnline.address, 0, projectEventCalldata)
      const proposalId = await Multisig.connect(collector2).hashProposal(TerminallyOnline.address, 0, projectEventCalldata)

      const proposal = await Multisig.connect(collector1).proposals(proposalId)

      expect(proposal.executed).to.equal(false)
      expect(proposal.totalVotes.toNumber()).to.equal(1)
      expect(proposal.maxVotes.toNumber()).to.equal(12)
    })

    it('execute should not work before votes are cast', async () => {
      await Multisig.connect(collector1).propose(0, TerminallyOnline.address, 0, projectEventCalldata)
      const proposalId = await Multisig.connect(collector2).hashProposal(TerminallyOnline.address, 0, projectEventCalldata)

      let proposal = await Multisig.connect(collector1).proposals(proposalId)

      await expectRevert(
        Multisig.connect(collector1).execute(TerminallyOnline.address, 0, projectEventCalldata),
        'Insufficient votes to execute proposal'
      )

      proposal = await Multisig.connect(collector1).proposals(proposalId)

      expect(proposal.executed).to.equal(false)
    })


    it('castVote should work', async () => {
      await Multisig.connect(collector1).propose(0, TerminallyOnline.address, 0, projectEventCalldata)
      const proposalId = await Multisig.connect(collector2).hashProposal(TerminallyOnline.address, 0, projectEventCalldata)

      let proposal = await Multisig.connect(collector1).proposals(proposalId)

      await Multisig.connect(collector2).castVote(proposalId, 4, true)
      proposal = await Multisig.connect(collector1).proposals(proposalId)

      expect(proposal.executed).to.equal(false)
      expect(proposal.totalVotes.toNumber()).to.equal(2)
    })

    it('castVote allow unvoting, but not double voting', async () => {
      await Multisig.connect(collector1).propose(0, TerminallyOnline.address, 0, projectEventCalldata)
      const proposalId = await Multisig.connect(collector2).hashProposal(TerminallyOnline.address, 0, projectEventCalldata)

      let proposal = await Multisig.connect(collector1).proposals(proposalId)

      await Multisig.connect(collector2).castVote(proposalId, 4, true)
      proposal = await Multisig.connect(collector1).proposals(proposalId)

      await Multisig.connect(collector2).castVote(proposalId, 4, true)
      proposal = await Multisig.connect(collector1).proposals(proposalId)
      expect(proposal.totalVotes.toNumber()).to.equal(2)

      await Multisig.connect(collector2).castVote(proposalId, 4, false)
      proposal = await Multisig.connect(collector1).proposals(proposalId)
      expect(proposal.totalVotes.toNumber()).to.equal(1)

      await Multisig.connect(collector2).castVote(proposalId, 4, false)
      proposal = await Multisig.connect(collector1).proposals(proposalId)
      expect(proposal.totalVotes.toNumber()).to.equal(1)

      await Multisig.connect(collector2).castVote(proposalId, 4, true)
      proposal = await Multisig.connect(collector1).proposals(proposalId)
      expect(proposal.totalVotes.toNumber()).to.equal(2)

      await Multisig.connect(collector2).castVote(proposalId, 4, true)
      proposal = await Multisig.connect(collector1).proposals(proposalId)
      expect(proposal.totalVotes.toNumber()).to.equal(2)

      await Multisig.connect(collector3).castVote(proposalId, 11, false)
      proposal = await Multisig.connect(collector1).proposals(proposalId)
      expect(proposal.totalVotes.toNumber()).to.equal(2)
    })

    it('execute should work', async () => {
      await Multisig.connect(collector1).propose(0, TerminallyOnline.address, 0, projectEventCalldata)
      const proposalId = await Multisig.connect(collector2).hashProposal(TerminallyOnline.address, 0, projectEventCalldata)

      const proposal = await Multisig.connect(collector1).proposals(proposalId)

      await sixVotes(proposalId)
      const preVoteEvents = await TerminallyOnline.queryFilter({
        address: TerminallyOnline.address,
        topics: []
      })

      await Multisig.connect(collector1).execute(TerminallyOnline.address, 0, projectEventCalldata)

      const postVoteEvents = await TerminallyOnline.queryFilter({
        address: TerminallyOnline.address,
        topics: []
      })

      expect(postVoteEvents.length).to.equal(preVoteEvents.length + 1)
      expect(postVoteEvents[postVoteEvents.length-1].event).to.equal('ProjectEvent')
    })

    it('execute should not work multiple times', async () => {
      await Multisig.connect(collector1).propose(0, TerminallyOnline.address, 0, projectEventCalldata)
      const proposalId = await Multisig.connect(collector2).hashProposal(TerminallyOnline.address, 0, projectEventCalldata)

      const proposal = await Multisig.connect(collector1).proposals(proposalId)

      await sixVotes(proposalId)

      await Multisig.connect(collector1).execute(TerminallyOnline.address, 0, projectEventCalldata)

      await expectRevert(
        Multisig.connect(collector1).execute(TerminallyOnline.address, 0, projectEventCalldata),
        'Proposal has already been executed'
      )
    })
  })

  describe('admin', () => {

    it('setting admin should work', async () => {
      const collector1AdminCalldata = encodeWithSignature('setAdmin', ['address'], [collector1.address])

      await Multisig.connect(collector1).propose(0, Multisig.address, 0, collector1AdminCalldata)
      const proposalId = await Multisig.connect(collector1).hashProposal(Multisig.address, 0, collector1AdminCalldata)

      await sixVotes(proposalId)

      await Multisig.connect(collector1).execute(Multisig.address, 0, collector1AdminCalldata)

      const startingContractBalance = num(await provider.getBalance(Multisig.address))
      const startingAdminBalance = num(await provider.getBalance(collector1.address))

      await artist.sendTransaction({
        to: Multisig.address,
        value: ethers.utils.parseEther("1.0"),
      })
      const afterTransferContractBalance = num(await provider.getBalance(Multisig.address))

      await Multisig.connect(collector1).adminExecute(
        collector1.address,
        ethers.utils.parseEther("1.0"),
        '0x'
      )

      const endingContractBalance = num(await provider.getBalance(Multisig.address))
      const endingAdminBalance = num(await provider.getBalance(collector1.address))

      expect(startingContractBalance).to.equal(0)
      expect(afterTransferContractBalance).to.equal(1)
      expect(endingContractBalance).to.equal(0)

      expect(endingAdminBalance).to.be.closeTo(startingAdminBalance + 1, 0.001)


      await expectRevert(
        Multisig.connect(artist).setAdmin(artist.address),
        'Caller must equal this contract'
      )
    })
  })

  describe('new multisig', () => {
    it('should reset the multisig address', async () => {
      await expectRevert(
        TerminallyOnline.connect(artist).setMultisigContract(artist.address),
        'Caller is not the multisig address'
      )

      const resetMultisig = encodeWithSignature('setMultisigContract', ['address'], [artist.address])

      await Multisig.connect(collector1).propose(0, TerminallyOnline.address, 0, resetMultisig)
      const proposalId = await Multisig.connect(collector1).hashProposal(TerminallyOnline.address, 0, resetMultisig)

      await sixVotes(proposalId)

      await Multisig.connect(collector1).execute(TerminallyOnline.address, 0, resetMultisig)

      expect(await TerminallyOnline.connect(artist).multisig()).to.equal(artist.address)
    })
  })

  describe('uri', () => {
    it('resetting tokenURI contract should work', async () => {
      const updateURIContract = encodeWithSignature('setTokenURIContract', ['address'], [artist.address])

      await Multisig.connect(collector1).propose(0, TerminallyOnline.address, 0, updateURIContract)
      const proposalId = await Multisig.connect(collector1).hashProposal(TerminallyOnline.address, 0, updateURIContract)

      await sixVotes(proposalId)

      await Multisig.connect(collector1).execute(TerminallyOnline.address, 0, updateURIContract)

      expect(await TerminallyOnline.connect(artist).tokenURIContract()).to.equal(artist.address)

      await expectRevert(
        TerminallyOnline.connect(artist).setTokenURIContract(artist.address),
        'Caller is not the multisig address'
      )
    })

    it('updating tokenURI externalURL should work', async () => {
      const updateExternalUrl = encodeWithSignature('updateExternalUrl', ['string'], ['terminallyonline.eth.limo'])


      await Multisig.connect(collector1).propose(0, TokenURI.address, 0, updateExternalUrl)
      const proposalId = await Multisig.connect(collector1).hashProposal(TokenURI.address, 0, updateExternalUrl)

      await sixVotes(proposalId)

      await Multisig.connect(collector1).execute(TokenURI.address, 0, updateExternalUrl)

      expect(await TokenURI.connect(artist).externalUrl()).to.equal('terminallyonline.eth.limo')

      await expectRevert(
        TokenURI.connect(collector1).updateExternalUrl('www.blah.com'),
        'Caller is not the URI owner'
      )

      for (let i=0; i<12; i++) {
        console.log(getJsonURI(await TerminallyOnline.connect(artist).tokenURI(i)))
      }
    })
  })

})