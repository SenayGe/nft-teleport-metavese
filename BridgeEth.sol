// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// import "@maticnetwork//fx-portal/contracts/blob/main/contracts/tunnel/FxBaseRootTunnel.sol";

import "https://github.com/fx-portal/contracts/blob/main/contracts/examples/erc721-transfer/FxERC721RootTunnel.sol";


interface IL1ERC721 is IERC721{
    
}

contract BridgeEth is FxBaseRootTunnel, IERC721Receiver{

    address _checkpointManager = 0x2890bA17EfE978480615e330ecB65333b880928e; // Goerli testnet
    address _fxRoot = 0x3d1d3E34f7fB6D26245E6640E1c50710eFFf15bA; // Goerli testnet

    mapping (address=>address) L1ToL2Token; // Mapping of origin to target token addresses

    address public counterpartL2Bridge;


    constructor () FxBaseRootTunnel (_checkpointManager, _fxRoot){}


    function deposit(
        address originalToken,
        address owner,
        uint256 tokenId,
        bytes calldata data
    ) external {
        require(rootToChildTokens[rootToken] != address(0x0), "FxMintableERC721RootTunnel: NO_MAPPING_FOUND");

        // transfer from depositor to this contract
        IFxERC721(rootToken).safeTransferFrom(
            msg.sender, // depositor
            address(this), // manager contract
            tokenId,
            data
        );

    function _processMessageFromChild(bytes memory data) internal override {


    }


}