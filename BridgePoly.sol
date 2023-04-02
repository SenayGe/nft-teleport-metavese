// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "https://github.com/fx-portal/contracts/blob/main/contracts/tunnel/FxBaseChildTunnel.sol";

interface IL2ERC721 is IERC721{
    function mintWrappedNFT (address _to, uint256 tokenId, string calldata tokenURI) external;
    function burnWrappedNFT (uint256 tokenId) external;
    // function ownerOf(uint256 tokenId);

}

contract BridgePoly is FxBaseChildTunnel, IERC721Receiver{

    address _fxChild = 0xCf73231F28B7331BBe3124B907840A94851f9f11; // Mumbai testnet

    bytes32 public constant DEPOSIT = keccak256("DEPOSIT");
    bytes32 public constant MAP_TOKEN = keccak256("MAP_TOKEN");

    address public counterpartL1Bridge;

    mapping (address=>address) L2ToL1Token; // Mapping of origin to target token addresses

    event DepositFinalized (address indexed tokenAddress, address indexed depositor, address indexed userL2, uint256 tokenId, string tokenURI);
    event TokenMapped (address indexed originalToken, address indexed destinationToken);

    constructor () FxBaseChildTunnel (_fxChild){}




    function registerTokenMapping (address _originalToken, address _destinationToken) public{

        require (L2ToL1Token[_originalToken] == address(0x0), "BridgeEth: TOKEN_ALREADY_MAPPED");

        L2ToL1Token[_originalToken] = _destinationToken;

        // MAP_TOKEN is message identifier
        bytes memory message = abi.encode(MAP_TOKEN, abi.encode(_originalToken, _destinationToken));
        _sendMessageToRoot(message);
        
    }

    function retrieveTokenMapping (address _destinationToken) public view returns (address L2Token, address L1Token){
        L2Token = _destinationToken;
        L1Token = L2ToL1Token[_destinationToken];
        return (L2Token,L1Token );
    }

    // overriding function to make it private
    function setFxRootTunnel(address _L1Bridge) external override virtual {
        require(fxRootTunnel == address(0x0), "FxBaseChildTunnel: ROOT_TUNNEL_ALREADY_SET");
        fxRootTunnel = _L1Bridge;
        counterpartL1Bridge = _L1Bridge;
    }

    /*
    @notice processes message sent from L1 bridge contract when a wrapped -
        nft is burned on L2
    */
 function _processMessageFromRoot(
        uint256, /* stateId */
        address sender,
        bytes memory data
    ) internal override validateSender(sender) {

        // decode incoming data
        (bytes32 messageType, bytes memory syncData) = abi.decode(data, (bytes32, bytes));

        if (messageType == DEPOSIT) {
            _syncDeposit(syncData);
        } else if (messageType == MAP_TOKEN) {
            _mapToken(syncData);
        } else {
            revert("FxERC721ChildTunnel: INVALID_SYNC_TYPE");
        }
    }
    


    /*
    @notice finalize deposit/bridge message
    */
    function _syncDeposit(bytes memory syncData) internal {
        (address originalToken, address depositor, address to, uint256 tokenId, string memory tokenURI) = abi.decode(
            syncData,
            (address, address, address, uint256, string)
        );
        address L2Token = L2ToL1Token[originalToken];

        // mint counterpart NFT and set metadata URI
        IL2ERC721 L2NFT = IL2ERC721(L2Token);
        L2NFT.mintWrappedNFT(to, tokenId, tokenURI);

        emit DepositFinalized(L2Token, depositor, to, tokenId, tokenURI);
    }


      function _mapToken(bytes memory syncData) internal returns (address) {
        (address originalToken, address destinationToken ) = abi.decode(syncData, (address, address));
        L2ToL1Token[destinationToken] = originalToken;
        emit TokenMapped(originalToken, destinationToken);
      }


     /*
    * @notice withdraw an NFT by burning L2 (wrapped) NFT
    */ 
    function withdraw(
        address destinationToken, // wrapped (L2) token contract address 
        // address receiver, // release original NFT to a different address than current owner
        uint256 tokenId
 
    ) public {
        // Check token mapping  
        require (
            destinationToken != address (0x0) && L2ToL1Token[destinationToken] != address (0x0), 
            "BridgePoly: NO_MAPPED_TOKEN"
        );


        IL2ERC721 L2TokenContract = IL2ERC721(destinationToken);

        require (msg.sender == L2TokenContract.ownerOf(tokenId));
     

        // burn wrapped nft
        L2TokenContract.burnWrappedNFT(tokenId);

        // send message to L1 regarding token burn
        address _originalToken = L2ToL1Token[destinationToken];
        address _receiver = msg.sender;
        _sendMessageToRoot(abi.encode(_originalToken, destinationToken, _receiver, tokenId));
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