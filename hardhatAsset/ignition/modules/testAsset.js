const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
module.exports = buildModule("digitalAssetModule", (m) => {
    const digitalContract  = m.contract("DigitalAsset Contracts", []);
    const details = m.contract("Details",[]);
    const trans = m.contract("Ownership transfer",[]);   
    const asset = m.contract("Asset Factory",[]);
    
    return { digitalContract, details, trans , asset};
  });
  