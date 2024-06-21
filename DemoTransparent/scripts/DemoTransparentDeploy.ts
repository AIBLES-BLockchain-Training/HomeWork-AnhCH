import { ethers, upgrades, run } from "hardhat";

async function main() {
//  await run("complie...");
  console.log("Complie contract....");
  console.log("Deploying DemoTransparent...");

  // Định nghĩa các tham số cho hàm khởi tạo
  const constructorArgs: [string, bigint] = [
    "0x57b946761A31423fBA7CC5c3eF42389b2d061e5e",
    100n,
  ];

  // Lấy contract factory
  const DemoTransparent = await ethers.getContractFactory("DemoTransparent");

  // Triển khai proxy Transparent
  const demoTransparent = await upgrades.deployProxy(
    DemoTransparent,
    constructorArgs,
    {
      kind: "transparent",
      initializer: "initialize",
    }
  );

  // Chờ proxy được triển khai
  await demoTransparent.waitForDeployment();

  // Lấy địa chỉ của proxy
  const proxyAddr = await demoTransparent.getAddress();
  console.log("DemoTransparent deployed at: ", proxyAddr);

  console.log("Wait to verify contract");

  // Đợi 60 giây để đảm bảo hợp đồng đã được ghi vào blockchain
  await new Promise((resolve) => {
    setTimeout(resolve, 60 * 1000);
  });

  // Lấy địa chỉ của triển khai hợp đồng
  const implAddr = await upgrades.erc1967.getImplementationAddress(proxyAddr);

  // Xác minh hợp đồng đã triển khai
  await run("verify:verify", {
    address: implAddr,
    constructorArgs: [],
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
