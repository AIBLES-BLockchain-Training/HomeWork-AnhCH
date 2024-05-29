// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDigitalAsset {
    function getDetails() external view returns(string memory);
    function transferOwnership(address newOwner) external ;
}
abstract contract AbstractAsset is IDigitalAsset {
    string internal name;
    address internal owner;
    constructor(string memory _name) {
        name = _name;
        owner = msg.sender;
    }
    function getDetails() public view virtual override returns (string memory) {
        return name;
    }
    function getOwner() public view returns(address){
        return owner;
    }
    function transferOwnership(address newOwner) public virtual override;
}
//part 2: 
 contract ArtAsset is AbstractAsset {
    string public artName;
    string public artistName;

    constructor(string memory _name,  string memory _artName,string memory _artistName) AbstractAsset (_name){
        artName = _artName;
        artistName = _artistName;
    }
    modifier onlyOwner(){
        require(msg.sender == owner, "Only the current owner can transfer ownership");
        _;
    }
    function transferOwnership(address newOwner) public virtual override onlyOwner{
     // require(msg.sender == owner, "Only the current owner can transfer ownership");
        owner = newOwner;
    }
    function transfer_artName( string memory newName) public onlyOwner{
        artName = newName;
    }
 }
    contract MusicAsset is  AbstractAsset {
        string public songName;
        string public musical;
        constructor(string memory _name,string memory _songName,  string memory _musical) AbstractAsset (_name){
       songName = _songName;
       musical = _musical;
    }
    modifier onlyOwner(){
        require(msg.sender == owner, "Only the current owner can transfer ownership");
        _;
    }
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        owner = newOwner;
    }
    function transfer_MusicalName( string memory newMusical) public onlyOwner{
        musical = newMusical;
    }
    }

 contract assetFactory {
 
    address [] public createdAssets;
   // mapping(address => bool ) public newArtAsset;
    function createArtAsset(string memory _name,string memory _artName,string memory _artistName) external {
        ArtAsset newArtAsset = new ArtAsset(_name, _artName, _artistName);
       createdAssets.push(address(newArtAsset));
    }
    function createMusicAsset(string memory _name,string memory _songName,  string memory _musical) external {
        MusicAsset newMusicAsset = new MusicAsset(_name, _songName, _musical);
       createdAssets.push(address(newMusicAsset));
    }

 }



 
