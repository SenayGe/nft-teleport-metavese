// SPDX-License-Identifier: MIT
pragma solidity >=0.6.9 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";




contract L2PolyERC721 is ERC721, ERC721URIStorage, Ownable {
    
    constructor()
        ERC721("MTVRSToken", "MTVRST")
    {}

    event counterpartNFTMinted(uint256 indexed _tokenId, address _owner, string _tokenURI);

    uint256 public tokenCount = 0;
    address public bridgeContract;
     // tokenId => token owner
    mapping(uint256 => address) internal tokenIdToOwner;
    mapping (uint256 => address) public delegatedUsers;

    event BridgeContractRegistered (address tokenOwner, address bridgeContract);
    event NFTdelegatedToUser (uint256 tokenId, address user);
    // function mint(address to) public onlyOwner {
    //     _safeMint(to, tokenId);
    //     tokenId ++;
    // }

    modifier onlyBridge{
        require (msg.sender == bridgeContract);
        _;
    }

    function mintWrappedNFT (address _to, uint256 _tokenId, string calldata _metadata ) external onlyBridge{
        
        // require {
        //     accessControls.hasMinterRole(_msgSender()),
        //     "DeviceNFT.mint: Sender must have minter role"
        // }

        _safeMint(_to, _tokenId);
        _setTokenURI(_tokenId, _metadata);
        tokenIdToOwner[_tokenId] = _to;

        emit counterpartNFTMinted (_tokenId, _to, _metadata);
        
    }

    function delegateNFT (uint256  _tokenId, address _to) public{
        require (msg.sender == ownerOf(_tokenId), "L2NFT: only token owner can delegate NFT");
        require (delegatedUsers[_tokenId] == address (0x0), "LSNFT: NFT already delegated");

        delegatedUsers[_tokenId] = _to;
        emit NFTdelegatedToUser (_tokenId, _to);

    }

     function removeDelegation (uint256  _tokenId, address _to) public{
        require (msg.sender == ownerOf(_tokenId), "L2NFT: only token owner can remove delegation");
        require (delegatedUsers[_tokenId] != address (0x0), "L2NFT: NFT not delegated");

        delegatedUsers[_tokenId] = address(0x0);

    }
    // function transferToken (address _from, address _to, )

    function burnWrappedNFT (uint256 _tokenId) external onlyBridge{
        _burn (_tokenId);
    }
   

    function approveBridgeContract (address _bridgeContract) public {

        bridgeContract = _bridgeContract;
        _setApprovalForAll(msg.sender, bridgeContract, true);
        emit BridgeContractRegistered(msg.sender, _bridgeContract);
}



    function tokenURI(uint256 _tokenId)
        public
        view
        override(ERC721, ERC721URIStorage// SPDX-License-Identifier: MIT
pragma solidity >=0.6.9 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";




contract L2PolyERC721 is ERC721, ERC721URIStorage, Ownable {
    
    constructor()
        ERC721("MTVRSToken", "MTVRST")
    {}

    event counterpartNFTMinted(uint256 indexed _tokenId, address _owner, string _tokenURI);

    uint256 public tokenCount = 0;
    address public bridgeContract;
     // tokenId => token owner
    mapping(uint256 => address) internal tokenIdToOwner;
    mapping (uint256 => address) public delegatedUsers;

    event BridgeContractRegistered (address tokenOwner, address bridgeContract);
    event NFTdelegatedToUser (uint256 tokenId, address user);
    // function mint(address to) public onlyOwner {
    //     _safeMint(to, tokenId);
    //     tokenId ++;
    // }

    modifier onlyBridge{
        require (msg.sender == bridgeContract);
        _;
    }

    function mintWrappedNFT (address _to, uint256 _tokenId, string calldata _metadata ) external onlyBridge{
        
        // require {
        //     accessControls.hasMinterRole(_msgSender()),
        //     "DeviceNFT.mint: Sender must have minter role"
        // }

        _safeMint(_to, _tokenId);
        _setTokenURI(_tokenId, _metadata);
        tokenIdToOwner[_tokenId] = _to;

        emit counterpartNFTMinted (_tokenId, _to, _metadata);
        
    }

    function delegateNFT (uint256  _tokenId, address _to) public{
        require (msg.sender == ownerOf(_tokenId), "L2NFT: only token owner can delegate NFT");
        require (delegatedUsers[_tokenId] == address (0x0), "LSNFT: NFT already delegated");

        delegatedUsers[_tokenId] = _to;
        emit NFTdelegatedToUser (_tokenId, _to);

    }

     function removeDelegation (uint256  _tokenId, address _to) public{
        require (msg.sender == ownerOf(_tokenId), "L2NFT: only token owner can remove delegation");
        require (delegatedUsers[_tokenId] != address (0x0), "L2NFT: NFT not delegated");

        delegatedUsers[_tokenId] = address(0x0);

    }
    // function transferToken (address _from, address _to, )

    function burnWrappedNFT (uint256 _tokenId) external onlyBridge{
        _burn (_tokenId);
    }
   

    function approveBridgeContract (address _bridgeContract) public {

        bridgeContract = _bridgeContract;
        _setApprovalForAll(msg.sender, bridgeContract, true);
        emit BridgeContractRegistered(msg.sender, _bridgeContract);
}



    function tokenURI(uint256 _tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(_tokenId);
    }

    function _burn(uint256 _tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(_tokenId);
    }
}


)
        returns (string memory)
    {
        return super.tokenURI(_tokenId);
    }

    function _burn(uint256 _tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(_tokenId);
    }
}


