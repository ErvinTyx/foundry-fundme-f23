-include .env


build:; forge build

deploy-sepolia:
	forge script script/Deploy.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --broadcast --private-key $(PRIVATE_KEY) --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv