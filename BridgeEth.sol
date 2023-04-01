// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;




// import "https://github.com/fx-portal/contracts/blob/main/contracts/examples/erc721-transfer/FxERC721RootTunnel.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "https://github.com/fx-portal/contracts/blob/main/contracts/tunnel/FxBaseRootTunnel.sol";

interface IL1ERC721 is ERC721URIStorage{
    function mint (address _to, string calldata _metadata ) external;
    function transferToken (address _from, address _to, uint256 _tokenId) external;
    
}

contract BridgeEth is FxBaseRootTunnel, IERC721Receiver{

    address _checkpointManager = 0x2890bA17EfE978480615e330ecB65333b880928e; // Goerli testnet
    address _fxRoot = 0x3d1d3E34f7fB6D26245E6640E1c50710eFFf15bA; // Goerli testnet

    bytes32 public constant DEPOSIT = keccak256("DEPOSIT");
    bytes32 public constant MAP_TOKEN = keccak256("MAP_TOKEN");

    address public counterpartL2Bridge;

    mapping (address=>address) L1ToL2Token; // Mapping of origin to target token addresses

    event NFTDeposited (address indexed tokenAddress, address indexed depositor, address indexed userL2, uint256 tokenId);
    event TokenMapped (address indexed originalToken, address indexed destinationToken);

    constructor () FxBaseRootTunnel (_checkpointManager, _fxRoot){}




    function registerTokenMapping (address _originalToken, address _destinationToken) public{

        require (L1ToL2Token[_originalToken] == address(0x0), "BridgeEth: TOKEN_ALREADY_MAPPED");

        L1ToL2Token[_originalToken] = _destinationToken;

        // MAP_TOKEN is message identifier
        bytes memory message = abi.encode(MAP_TOKEN, abi.encode(_originalToken, _destinationToken));
        _sendMessageToChild(message);

    }

      function setFxChildTunnel(address _fxChildTunnel) private override {
        require(fxChildTunnel == address(0x0), "FxBaseRootTunnel: CHILD_TUNNEL_ALREADY_SET");
        fxChildTunnel = _fxChildTunnel;
    }

    function registerL2Bridge (address L2Bridge) public {
        setFxChildTunnel(L2Bridge);
        counterpartL2Bridge = L2Bridge;
    }

    /*
    * @notice deposit an NFT by transfering it to bridge contract -
        to enable porting to L2
    * @param user is the owner-to-be address on L2, could be the 
        same as the original owner or different
    * @param data is extra data parameter which is used to send the -
        token URI to L2
    */ 
    function deposit(
        address originalToken,  
        address user, 
        uint256 tokenId
    ) external {
        require(L1ToL2Token[originalToken] != address(0x0), "BridgeEth: NO_MAPPING_OF_L2_TOKEN_FOUND");

        // transfer from depositor to this contract
        IL1ERC721(originalToken).transferToken(
            msg.sender, // depositor
            address(this), // bridge contract
            tokenId
        );

        string memory _tokenURI = IL1ERC721(originalToken).tokenURI(tokenId);
        bytes memory bridgeMessage = abi.encode(DEPOSIT, abi.encode(originalToken, msg.sender, user, tokenId, _tokenURI));
        _sendMessageToChild(bridgeMessage);
        emit NFTDeposited(originalToken, msg.sender, user, tokenId);

    }
    
    /*
    @notice processes withdraw message sent from L2 bridge contract when a wrapped -
        nft is burned on L2
    */
    function _processWithdrawMessage(bytes memory data) internal override {
        (address L1TokenAddress, address L2TokenAddress, address to, uint256 tokenId) = abi.decode(
            data,
            (address, address, address, uint256)
        );
        // validate mapping for root to child
        require(L1ToL2Token[L1TokenAddress] == L2TokenAddress, "BridgeEth: INVALID_MAPPING_ON_EXIT");

        // transfer token from bridge contract back to original owner
        IL1ERC721(L1TokenAddress).safeTransferFrom(address(this), to, tokenId);
        // emit FxWithdrawERC721(rootToken, L2Token, to, tokenId);
    }


    function onERC721Received(
        address, /* operator */
        address, /* from */
        uint256, /* tokenId */
        bytes calldata /* data */
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }


}