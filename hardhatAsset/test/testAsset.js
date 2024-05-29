const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
 // const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
  const { expect } = require("chai");
  const {ethers} = require("hardhat");

describe("DigitalAsset Contracts", function () {

  async function setup() {

   const [owner, addr1, addr2, newOwner] = await ethers.getSigners();
   
 const   ArtAsset = await ethers.getContractFactory("ArtAsset");
  const  MusicAsset = await ethers.getContractFactory("MusicAsset");
  const  AssetFactory = await ethers.getContractFactory("assetFactory");

    // Deploy contracts
  const  artAsset = await ArtAsset.deploy("Asset1", "Mona Lisa", "Leonardo da Vinci");
 
  const  musicAsset = await MusicAsset.deploy("Asset2", "Song Name", "Composer");
 
  const  assetFactory = await AssetFactory.deploy();
  return {owner, addr1, addr2, artAsset, musicAsset,assetFactory, newOwner  };
  };

 
    it("Should set the right owner for ArtAsset", async function () {
      const{artAsset,owner} = await loadFixture(setup);
      expect(await artAsset.getOwner()).to.equal(owner.address);
    });

    it("Should set the right owner for MusicAsset", async function () {
     const{musicAsset, owner} = await loadFixture(setup);
      expect(await musicAsset.getOwner()).to.equal(owner.address);
    });


  describe("Details", function () {
    it("Should return correct details for ArtAsset", async function () {
     const {artAsset} = await loadFixture(setup);
      expect(await artAsset.getDetails()).to.equal("Asset1");
    });

    it("Should return correct details for MusicAsset", async function () {
      const { musicAsset} = await loadFixture(setup);
      
      expect(await musicAsset.getDetails()).to.equal("Asset2");
    });
  });

  describe("Ownership transfer", function () {
    
    it("Should transfer ownership of ArtAsset", async function () {
      const{artAsset,addr1}= await loadFixture(setup);
      await artAsset.transferOwnership(addr1.address);
      expect(await artAsset.getOwner()).to.equal(addr1.address);
    });

    it("Should transfer ownership of MusicAsset", async function () {
      const{musicAsset,addr1}= await loadFixture(setup);
      await musicAsset.transferOwnership(addr1.address);
      expect(await musicAsset.getOwner()).to.equal(addr1.address);
    });

    it("Should prevent non-owner from transferring ownership of ArtAsset", async function () {
    const{artAsset,addr1,addr2} = await loadFixture(setup);
      await expect(
        artAsset.connect(addr1).transferOwnership(addr2.address)
      ).to.be.revertedWith("Only the current owner can transfer ownership");
    });

    it("Should prevent non-owner from transferring ownership of MusicAsset", async function () {
      const{musicAsset,addr1,addr2} = await loadFixture(setup);
    
      await expect(
        musicAsset.connect(addr1).transferOwnership(addr2.address)
      ).to.be.revertedWith("Only the current owner can transfer ownership");
    });
  });

  describe("Asset-specific changes", function () {
    it("Should allow only owner to change artName in ArtAsset", async function () {
     const {artAsset,addr1}= await loadFixture(setup);
      await artAsset.transfer_artName ("New Art Name");
      expect(await artAsset.artName()).to.equal("New Art Name");

      await expect(
        artAsset.connect(addr1).transfer_artName("Another Art Name")
      ).to.be.revertedWith("Only the current owner can transfer ownership");
    });

    it("Should allow only owner to change musical in MusicAsset", async function () {
      const {musicAsset,addr1}= await loadFixture(setup);
    
      await musicAsset.transfer_MusicalName("New Musical");
      expect(await musicAsset.musical()).to.equal("New Musical");

      await expect(
        musicAsset.connect(addr1).transfer_MusicalName("Another Musical")
      ).to.be.revertedWith("Only the current owner can transfer ownership");
    });
  });

  describe("Asset Factory", function () {
   it("Should create a new ArtAsset", async function () {
     const{assetFactory}= await loadFixture(setup);
  
     await assetFactory.createArtAsset("FactoryAsset", "Starry Night", "Van Gogh");
      const createdAssetsAddress = await assetFactory.createdAssets(0);
      const newArtAsset = await ethers.getContractAt("ArtAsset",createdAssetsAddress);

      expect(await newArtAsset.artName()).to.equal("Starry Night");
      expect(await newArtAsset.artistName()).to.equal("Van Gogh");
    });

    it("Should create a new MusicAsset", async function () {
    const {assetFactory}= await loadFixture(setup);
     
    await assetFactory.createMusicAsset("FactoryAsset", "Symphony No. 9", "Beethoven");
      const createdAssetsAddress = await assetFactory.createdAssets(0);
      const newMusicAsset = await ethers.getContractAt("MusicAsset",createdAssetsAddress);

      expect(await newMusicAsset.songName()).to.equal("Symphony No. 9");
      expect(await newMusicAsset.musical()).to.equal("Beethoven");
    });
  });
  
});
