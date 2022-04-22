// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//cdimport "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// contract OwnableDelegateProxy {}

// contract ProxyRegistry {
//     mapping(address => OwnableDelegateProxy) public proxies;
// }

contract NFTMarket{
    uint256 private isCountTxTimes = 1;
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => uint256) private price;
    mapping(uint256 => bool) private lock;
    mapping(address => uint256) private moneyWithdraw;
    event CheckReuturnData(address);
    constructor() {}
    function sell(uint256 _tokenId, uint256 _price, ERC721 erc721) public{
        //require(erc721._exists(_tokenId), "ERC721 MetaData: nonexsistent token"); 
        require(erc721.ownerOf(_tokenId) == msg.sender, " your are not this tokenId owner");
        require(lock[_tokenId] == false, "this token is saling right now");
        address isApprovedSuccess = erc721.getApproved(_tokenId);
        //(bool success,bytes memory returnData) = address(erc721).call(abi.encodeWithSignature("getApproved(uint256)", _tokenId));
        emit CheckReuturnData(isApprovedSuccess);
        require(isApprovedSuccess == address(this), "sorry, you have no set approver for your tokenId");
        price[_tokenId] = _price;
        lock[_tokenId] = true;
    }
    function buy(uint256 _tokenId, address _to, ERC721 erc721) public payable {
        require(price[_tokenId] <= msg.value, " your pay fee is not enough");
        require(lock[_tokenId] == true, "this tokenId emporarily not to sell");
        moneyWithdraw[erc721.ownerOf(_tokenId)] = msg.value;
        (bool success,) = address(erc721).call(abi.encodeWithSignature("transferFrom(address,address,uint256)", erc721.ownerOf(_tokenId), _to, _tokenId));
        require(success, "Maybe you are running into some problems");
        lock[_tokenId] = false;
    }
    function changeSalePrice(uint256 _tokenId, uint256 _price, ERC721 erc721) public {
        require(erc721.ownerOf(_tokenId) == msg.sender, "Sorry, you have no ownership");
        require(lock[_tokenId] == true, "your NFT is not saling right now, please make sure your NFT current state");
        price[_tokenId] = _price;
    }
    function cancelSale(uint256 _tokenId, ERC721 erc721) public {
        require(erc721.ownerOf(_tokenId) == msg.sender, "Sorry, you have no this tokenId ownership");
        price[_tokenId] = 0;
        lock[_tokenId] = false;
    }
    function withdraw() public {
        require(moneyWithdraw[msg.sender] != 0, "you have no money to withdraw");
        require(isCountTxTimes == 1, "Get out here , hacker!");
        
        isCountTxTimes = 2;
        payable(msg.sender).transfer(moneyWithdraw[msg.sender]);
        moneyWithdraw[msg.sender] = 0;
        isCountTxTimes = 1;
    }
    function getYourBalance() public view returns(uint256){
        return moneyWithdraw[msg.sender];
    }
    function getTokenPrice(uint256 _tokenId) public view returns(uint256){
        return price[_tokenId];
    }
    function isTokenSalingRightNow(uint256 _tokenId) public view returns(bool){
        return lock[_tokenId];
    }
}