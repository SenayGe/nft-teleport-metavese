// SPDX-License-Identifier: MIT
pragma solidity >=0.6.9 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

// solhint-disable-next-line compiler-version



contract L1EthERC721 is ERC721, ERC721URIStorage, Ownable {
    
    constructor()
        ERC721("MVRSToken", "MVRST")
    {}

    event DigitalTwinNFTMinted(uint256 indexed _tokenId, address _owner, string _tokenURI);

    uint256 public tokenCount = 0;
    address public bridgeContract;
     // tokenId => token owner
    mapping(uint256 => address) internal tokenIdToOwner;

    event BridgeContractRegistered (address tokenOwner, address bridgeContract);

    // function mint(address to) public onlyOwner {
    //     _safeMint(to, tokenId);
    //     tokenId ++;
    // }

    function mintNFT (address _to, string calldata _metadata ) external {
        
        // require {
        //     accessControls.hasMinterRole(_msgSender()),
        //     "DeviceNFT.mint: Sender must have minter role"
        // }
        tokenCount++;
        uint256 tokenId = tokenCount;

        _safeMint(_to, tokenId);
        _setTokenURI(tokenId, _metadata);
        tokenIdToOwner[tokenId] = _to;

        emit DigitalTwinNFTMinted (tokenId, _to, _metadata);
        
    }

    // function transferToken (address _from, address _to, )

   

    function approveBridgeContract (address _bridgeContract) public {

        bridgeContract = _bridgeContract;
        _setApprovalForAll(msg.sender, bridgeContract, true);
        emit BridgeContractRegistered(msg.sender, _bridgeContract);
}


    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
}


