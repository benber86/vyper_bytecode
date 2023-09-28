// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SolidityStocks {
    
    // Financial events the contract logs
    event Transfer(address indexed sender, address indexed receiver, uint256 value);
    event Buy(address indexed buyer, uint256 buyOrder);
    event Sell(address indexed seller, uint256 sellOrder);
    event Pay(address indexed vendor, uint256 amount);

    // Initiate the variables for the company and its own shares.
    address public company;
    uint256 public totalShares;
    uint256 public price;

    // Store a ledger of stockholder holdings.
    mapping(address => uint256) public holdings;

    // Set up the company.
    constructor(address _company, uint256 _totalShares, uint256 initialPrice) {
        assert(_totalShares > 0);
        assert(initialPrice > 0);

        company = _company;
        totalShares = _totalShares;
        price = initialPrice;

        // The company holds all the shares at first, but can sell them all.
        holdings[company] = _totalShares;
    }

    // Public function to allow external access to _stockAvailable
    function stockAvailable() external view returns (uint256) {
        return holdings[company];
    }

    // Give some value to the company and get stock in return.
    function buyStock() external payable {
        // Note: full amount is given to company (no fractional shares),
        // so be sure to send exact amount to buy shares
        uint256 buyOrder = msg.value / price;

        // Check that there are enough shares to buy.
        assert(holdings[company] >= buyOrder);

        // Take the shares off the market and give them to the stockholder.
        holdings[company] -= buyOrder;
        holdings[msg.sender] += buyOrder;

        // Log the buy event.
        emit Buy(msg.sender, buyOrder);
    }

    // Public function to allow external access to _getHolding
    function getHolding(address _stockholder) external view returns (uint256) {
        return holdings[_stockholder];
    }

    // Give stock back to the company and get money back as ETH.
    function sellStock(uint256 sellOrder) external {
        assert(sellOrder > 0);
        // You can only sell as much stock as you own.
        assert(holdings[msg.sender] >= sellOrder);
        // Check that the company can pay you.
        assert(address(this).balance >= (sellOrder * price));

        // Sell the stock, send the proceeds to the user
        // and put the stock back on the market.
        holdings[msg.sender] -= sellOrder;
        holdings[company] += sellOrder;
        payable(msg.sender).transfer(sellOrder * price);

        // Log the sell event.
        emit Sell(msg.sender, sellOrder);
    }

    // Transfer stock from one stockholder to another. 
    function transferStock(address receiver, uint256 transferOrder) external {
        assert(transferOrder > 0);
        // Similarly, you can only trade as much stock as you own.
        assert(holdings[msg.sender] >= transferOrder);

        // Debit the sender's stock and add to the receiver's address.
        holdings[msg.sender] -= transferOrder;
        holdings[receiver] += transferOrder;

        // Log the transfer event.
        emit Transfer(msg.sender, receiver, transferOrder);
    }

    // Allow the company to pay someone for services rendered.
    function payBill(address vendor, uint256 amount) external {
        // Only the company can pay people.
        assert(msg.sender == company);
        // Also, it can pay only if there's enough to pay them with.
        assert(address(this).balance >= amount);

        // Pay the bill!
        payable(vendor).transfer(amount);

        // Log the payment event.
        emit Pay(vendor, amount);
    }

    // Public function to allow external access to _debt
    function debt() public view returns (uint256) {
        return totalShares - holdings[company] * price;
    }

    // Return the cash holdings minus the debt of the company.
    function worth() external view returns (uint256) {
        return address(this).balance - debt();
    }
}
