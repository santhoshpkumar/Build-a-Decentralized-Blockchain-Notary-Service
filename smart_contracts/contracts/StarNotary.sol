pragma solidity ^0.5.0;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

contract StarNotary is ERC721 {
    struct Star { 
        string name; 
        string starStory;
        string ra;
        string dec;
        string mag;
    }

    mapping(uint256 => Star) public _tokenIdToStarInfo; 
    mapping(bytes32 => bool) public _claimedStars;
    mapping(uint256 => uint256) public _starsForSale;

    function createStar(string memory _name, string memory _starStory, string memory _ra, string memory _dec, string memory _mag, uint256 _tokenId) public {
        require(checkIfStarExist(_ra, _dec, _mag) == false, "Star is already created for these coordinates");
        Star memory newStar = Star(_name, _starStory, _ra, _dec, _mag);
        bytes32 newStarHash = keccak256(abi.encodePacked(_ra, _dec, _mag));

        // If start is not created before, save newStar and newStarHash
        if (_claimedStars[newStarHash] != true) {
            _tokenIdToStarInfo[_tokenId] = newStar;
            _claimedStars[newStarHash] = true;	
        }

        // Mint token and send it to star creator address
        _mint(msg.sender, _tokenId);
    }

    function tokenIdToStarInfo(uint _tokenId) public view returns(string memory, string memory, string memory, string memory, string memory) {
        Star memory tempStar = _tokenIdToStarInfo[_tokenId];
        return (tempStar.name, tempStar.starStory, tempStar.ra, tempStar.dec, tempStar.mag);
    }


    function putStarUpForSale(uint256 _tokenId, uint256 _price) public { 
        // Only star owner can call this function
        require(this.ownerOf(_tokenId) == msg.sender);

        // Set star price
        _starsForSale[_tokenId] = _price;
    }

    function buyStar(uint256 _tokenId) public payable { 
        // Verify if the star is for sale
        require(_starsForSale[_tokenId] > 0);
        
        // Verify if the amount is enough
        uint256 starCost = _starsForSale[_tokenId];
        require(msg.value >= starCost);

        // Transfer token and cost
        address payable starOwner = address(uint160(bytes20(this.ownerOf(_tokenId))));
        _removeTokenFrom(starOwner, _tokenId);
        _addTokenTo(msg.sender, _tokenId);
        starOwner.transfer(starCost);

        // If there is more value than the cost, return it to buyer
        if(msg.value > starCost) { 
            msg.sender.transfer(msg.value - starCost);
        }

        // Take the star off the sale list
        delete(_starsForSale[_tokenId]);
    }

    function checkIfStarExist(string memory _ra, string memory _dec, string memory _mag) public view returns (bool) {
        return _claimedStars[keccak256(abi.encodePacked(_ra, _dec, _mag))];
    }
}