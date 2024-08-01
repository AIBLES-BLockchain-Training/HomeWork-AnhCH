// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract DEX {
    struct User {
        string userId;
        string username;
        string password;
        string walletAddress;
    }

    struct Trade {
        string tradeId;
        address seller;
        address buyer;
        string cryptoType;
        uint256 amount;
        uint256 price;
        string status;
    }

    struct WithdrawalRequest {
        string requestId;
        address user;
        string cryptoType;
        uint256 amount;
        string status;
    }

    struct Transaction {
        string transactionId;
        address from;
        address to;
        string cryptoType;
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => User) public users;
    mapping(string => Trade) public trades;
    mapping(string => WithdrawalRequest) public withdrawalRequests;
    mapping(address => mapping(string => uint256)) public balances;
    mapping(string => Transaction) public transactions;

    event UserRegistered(string userId, address walletAddress);
    event TradeCreated(string tradeId, address seller, address buyer, string cryptoType, uint256 amount, uint256 price);
    event TradeCompleted(string tradeId, address seller, address buyer, string cryptoType, uint256 amount, uint256 price);
    event WithdrawalRequested(string requestId, address user, string cryptoType, uint256 amount);
    event WithdrawalApproved(string requestId, address user, string cryptoType, uint256 amount);
    event CoinBought(address buyer, string cryptoType, uint256 amount, uint256 price);
    event CoinSold(address seller, string cryptoType, uint256 amount, uint256 price);
    event BalanceChecked(address user, string cryptoType, uint256 balance);
    event TransactionCreated(string transactionId, address from, address to, string cryptoType, uint256 amount, uint256 timestamp);

    modifier onlyUser() {
        require(bytes(users[msg.sender].userId).length != 0, "User not registered.");
        _;
    }

    function registerUser(string memory userId, string memory username, string memory password, string memory walletAddress) public {
        require(bytes(users[msg.sender].userId).length == 0, "User already registered.");
        
        // Kiểm tra tham số trước khi gán
        require(bytes(userId).length != 0, "User ID cannot be empty.");
        require(bytes(username).length != 0, "Username cannot be empty.");
        require(bytes(password).length != 0, "Password cannot be empty.");
        require(bytes(walletAddress).length != 0, "Wallet address cannot be empty.");
        
        users[msg.sender] = User(userId, username, password, walletAddress);
        
        // Kiểm tra lại các biến trước khi phát sự kiện
        require(bytes(users[msg.sender].userId).length != 0, "User ID is invalid.");
        require(bytes(users[msg.sender].walletAddress).length != 0, "Wallet address is invalid.");
        
        emit UserRegistered(userId, msg.sender);
    }

    function createTrade(string memory tradeId, string memory cryptoType, uint256 amount, uint256 price) public onlyUser {
        Trade storage newTrade = trades[tradeId];
        newTrade.tradeId = tradeId;
        newTrade.seller = msg.sender;
        newTrade.cryptoType = cryptoType;
        newTrade.amount = amount;
        newTrade.price = price;
        newTrade.status = "Pending";
        emit TradeCreated(tradeId, msg.sender, address(0), cryptoType, amount, price);
    }

    function executeTrade(string memory tradeId) public onlyUser {
        Trade storage trade = trades[tradeId];
        require(trade.buyer == address(0), "Trade already executed.");
        trade.buyer = msg.sender;
        trade.status = "Completed";
        balances[trade.seller][trade.cryptoType] -= trade.amount;
        balances[trade.buyer][trade.cryptoType] += trade.amount;
        emit TradeCompleted(tradeId, trade.seller, trade.buyer, trade.cryptoType, trade.amount, trade.price);
    }

    function requestWithdrawal(string memory requestId, string memory cryptoType, uint256 amount) public onlyUser {
        WithdrawalRequest storage newRequest = withdrawalRequests[requestId];
        newRequest.requestId = requestId;
        newRequest.user = msg.sender;
        newRequest.cryptoType = cryptoType;
        newRequest.amount = amount;
        newRequest.status = "Pending";
        emit WithdrawalRequested(requestId, msg.sender, cryptoType, amount);
    }

    function approveWithdrawal(string memory requestId) public onlyUser {
        WithdrawalRequest storage request = withdrawalRequests[requestId];
        require(keccak256(bytes(request.status)) == keccak256(bytes("Pending")), "Request not pending.");
        request.status = "Approved";
        balances[request.user][request.cryptoType] -= request.amount;
        emit WithdrawalApproved(requestId, request.user, request.cryptoType, request.amount);
    }

    function getTrade(string memory tradeId) public view returns (address, address, string memory, uint256, uint256, string memory) {
        Trade storage trade = trades[tradeId];
        return (trade.seller, trade.buyer, trade.cryptoType, trade.amount, trade.price, trade.status);
    }

    function getWithdrawalRequest(string memory requestId) public view returns (address, string memory, uint256, string memory) {
        WithdrawalRequest storage request = withdrawalRequests[requestId];
        return (request.user, request.cryptoType, request.amount, request.status);
    }

    function isUserRegistered(address walletAddress) public view returns (bool) {
        return bytes(users[walletAddress].userId).length != 0;
    }

    function checkBalance(address user, string memory cryptoType) public view returns (uint256) {
    return balances[user][cryptoType];
}
    function emitBalanceChecked(address user, string memory cryptoType) public {
    uint256 balance = balances[user][cryptoType];
    emit BalanceChecked(user, cryptoType, balance);
}


    function buyCoin(string memory cryptoType, uint256 amount) public payable onlyUser {
        require(msg.value == amount, "Incorrect ETH amount sent.");
        balances[msg.sender][cryptoType] += amount;
        emit CoinBought(msg.sender, cryptoType, amount, msg.value);
    }

    function sellCoin(string memory cryptoType, uint256 amount) public onlyUser {
        require(balances[msg.sender][cryptoType] >= amount, "Insufficient balance.");
        balances[msg.sender][cryptoType] -= amount;
        payable(msg.sender).transfer(amount);
        emit CoinSold(msg.sender, cryptoType, amount, amount);
    }

    function createTransaction(string memory transactionId, address to, string memory cryptoType, uint256 amount) public onlyUser {
        require(balances[msg.sender][cryptoType] >= amount, "Insufficient balance.");
        balances[msg.sender][cryptoType] -= amount;
        balances[to][cryptoType] += amount;
        transactions[transactionId] = Transaction(transactionId, msg.sender, to, cryptoType, amount, block.timestamp);
        emit TransactionCreated(transactionId, msg.sender, to, cryptoType, amount, block.timestamp);
    }

    function getTransaction(string memory transactionId) public view returns (address, address, string memory, uint256, uint256) {
        Transaction storage transaction = transactions[transactionId];
        return (transaction.from, transaction.to, transaction.cryptoType, transaction.amount, transaction.timestamp);
    }
}
