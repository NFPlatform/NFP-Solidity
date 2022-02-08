// Klaytn IDE uses solidity 0.4.24, 0.5.6 versions.
pragma solidity >= 0.4.24 <= 0.5.6;

contract NFTSimple {
    
    string public name = "klayLion";
    string public synbol = "KL";

    mapping(uint256 => address) public tokenOwner;
    mapping (uint256 => string) public tokenURIs;

    bytes4 private constant _KIP17_RECEIVED = 0x6745782b;
    //onKIP17Received bytes value;

    mapping(address => uint256[]) private _ownedTokens;

    function mintWithTokenURI(address to, uint256 tokenId, string memory tokenURI)public returns(bool) {
        tokenOwner[tokenId] = to;
        tokenURIs[tokenId] = tokenURI;
        _ownedTokens[to].push(tokenId);
        return true;
    }
    function safeTransferFrom(address from, address to, uint256 tokenId,bytes memory _data) public {
        require(from == msg.sender, "from != msg.sender");
        require(from == tokenOwner[tokenId], "you are not the owner");
        
        _removeTokenFromList(from, tokenId);
        _ownedTokens[to].push(tokenId);

        tokenOwner[tokenId] = to;

        //만약에 받는 쪽이 실행할 코드가 있는 스컨이면 코드를 실행할 것
        require(
            _checkOnKIP17Received(from,to,tokenId, _data), "KIP17: transfer to non KIP17Receiver implemeter"
        );
        
    }
    function _checkOnKIP17Received(address from, address to, uint256 tokenId, bytes memory _data) internal returns (bool) {
       
        
        bool success;
        bytes memory returndata;
         //스컨이 아니면 걍 리턴
        if(!isContract(to)){
            return true;
        }

        //스컨이면 그 주소에 가서 실행을 하라 
        //_KIP17received 솔리디티에서 지들이 알아먹을수 있게 16진수로 바꾼거
        // 실행할때 저렇게 쓰면  onKIP17Received 함수를 실행함
        (success, returndata) = to.call(
        // 성공결과랑 리턴값있음 받아와라
            abi.encodeWithSelector(
                _KIP17_RECEIVED,
                msg.sender,
                from,
                tokenId,
                _data
            )
        );
        if(
            //리턴 있고 _KIPRECEIVE면 잘한거니까 true리턴하기
            returndata.length != 0 &&
            abi.decode(returndata, (bytes4)) == _KIP17_RECEIVED
        ){
            return true;
        }
        return false;

    }

    function isContract(address account) internal view returns (bool){
        uint256 size;
        assembly { size := extcodesize(account)}
        return size>0 ;
    }

    function _removeTokenFromList(address from, uint256 tokenId) private{
        uint256 lastTokenIndex = _ownedTokens[from].length -1;

        for(uint256 i =0; i<_ownedTokens[from].length; i++){
            if(tokenId == _ownedTokens[from][i]){
                _ownedTokens[from][i] = _ownedTokens[from][lastTokenIndex];
                _ownedTokens[from][lastTokenIndex] = tokenId;
            }
        }
        _ownedTokens[from].length--;
    }

    function ownedTokens(address owner) public view returns (uint256[] memory) {
        return _ownedTokens[owner];
    }

    function setTokenUri(uint256 id, string memory uri) public {
        tokenURIs[id] = uri;
    }
}

contract NFTMarket {
    //판매자를 기억하기
    mapping(uint256 => address) public seller;


    function buyNFT(uint256 tokenId, address NFTAddress) public  payable returns (bool) {
        //구매한사람한테 0.01클레이보내기
        address payable receiver = address(uint160(seller[tokenId]));

        // Send 0.01klay receiver
        receiver.transfer(10**16); //10**18 = 1klay 1=> Peb 

        //buynft를 실행한 사람이 보내주는거
        // 그래서 그 사람이 돈을 0.01을 더 들고 있어야함

        Practice(NFTAddress).safeTransferFrom(address(this), msg.sender, tokenId, '0x00');
        //Practice(NFTAdress)는 진짜 Practice의 주소를 뜻함

        return true;

    }
    //market이 토큰을 받았을때 (판매대에 올라갔을때) 판매자가 누구인지 기록
    function onKIP17Received(address operator, address from, uint256 tokenId, bytes memory data) public returns(bytes4) {
        seller[tokenId] = from;
        
        return bytes4(keccak256("onKIP17Received(address,address,uint256,bytes)"));
        // 이거 구현했을때 이런 글자를 리턴해라 0x6745782b
    } 
 } 
