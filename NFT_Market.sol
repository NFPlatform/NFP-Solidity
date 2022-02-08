// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.24 <=0.5.6;


contract NFTSimple {
    string public name = "KlayLion";
    
    // 2. 보통 컨트랙트에 많이 있는 것 symbol
    string public symbol = "KL";

    // 3. 토큰 소유주 알 수 있게 하는 것
    mapping(uint256 => address) public tokenOwner; 
    mapping(uint256 => string) public tokenURIs; // object자료형 uri = 글자다 = 통합자원식별자

    // 6. 소유한 토큰 리스트
    mapping(address => uint256[]) private _ownedTokens;

    // 11. nft market에서 가져왔던 상수값, onIKIP17Received
    bytes4 private constant _KIP17_RECEIVED = 0x6745782b;

    // 1. 블록체인 발행할때
    // 발행(일련번호, 글자, 소유자) 
    // mint(tokenId, uri, owner)
    // 전송(누가, 누구에게, 무엇을)
    // tranferFrom(from, to, tokenId)

    // 4. 토큰발행함수(누구에게 발행할지, 토큰 ID, 토큰에 적을 글자 URI)
    function mintWithTokenURI(address to, uint256 tokenId, string memory tokenURI) public returns (bool) {
        // to에게 tokenId(일련번호)를 발행하겠다.
        // 적힐 글자는 tokenURI
        // tokenOwner[tokenId] = msg.sender;
        tokenOwner[tokenId] = to;
        tokenURIs[tokenId] = tokenURI;

        // 8. 누가 들고 있는지 알려면 발행할 때 배열에 넣어줘야한다.
        _ownedTokens[to].push(tokenId);

        return true;
    }

    // 5. 전송하는 개념은 주인이 바뀌는 것, 보통 safe란 표현을 많이 쓴다.
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        // 아무나 접근해서 내 토큰을 보낼 수 있다. 내가 토큰의 소유주일 때만 가능해야한다.
        require(from == msg.sender, "from != msg.sender");
        require(from == tokenOwner[tokenId], "you are not the owner of the token");

        // 9-4. 원래 가지고 있던 애한테 뺏고
        _removeTokenFromList(from, tokenId);
        // 10. 줄 애한테 넣어준다.
        _ownedTokens[to].push(tokenId);

        tokenOwner[tokenId] = to;      

        // 12. 전송했을 때 만약 받는 쪽이 실행할 코드가 있는 스마트 컨트랙트면 코드를 실행할 것
        require(
            _checkOnKIP17Received(from, to, tokenId, _data), "KIP17: transfer to non KIP17Receiver implementer"
        );  
    }

    // 13. 내부에서 호출할 수 있는 함수, 12에서 받아와서 실행할 코드가 있는지 살펴본다.
    function _checkOnKIP17Received(address from, address to, uint256 tokenId, bytes memory _data) internal returns (bool) {
        bool success;
        bytes memory returndata;

        // 13-1. 보낼 사람이 스마트 컨트랙트냐 아니냐? 판단하자
        if(!isContract(to)) {
            return true;
        }

        // 13-2. 코드가 있을 것 같다면 실행해준다.
        // 스마트 컨트랙트면 그 코드를 실행해주세요.
        // 컴퓨터 솔리디티가 밑에있던 kecca를 16진수로 바꿔놓았고, 이렇게 하면 알아서 밑에 있는 애를 실행한다.
        // 거기에 함수로 아래 파라미터 4개를 받아온다.
        // (성공결과, 리턴 값이 있으면 returndata에 보내주고 아래로 내려간다.)
        (success, returndata) = to.call(
            abi.encodeWithSelector(
                _KIP17_RECEIVED,
                msg.sender,
                from,
                tokenId,
                _data
            )
        );

        // 13-3. 리턴 값이 0이 아니면 == 리턴 값이 있다 && 그 코드가 kip17이면
        // 잘했으면 return true
        if(
            returndata.length != 0 &&
            abi.decode(returndata, (bytes4)) == _KIP17_RECEIVED
        ) {
            return true;
        }
        return false;
    }

    // 14. 스마트 컨트랙트냐 아니냐 판단하는 함수다
    // 이걸 어떻게 판단하겠냐? 그 주소에 코드가 있으면 컨트랙트고 없으면 일반 주소다.
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // 이건 클레이튼에 있는 건데, existcode 즉, 코드가 존재하냐?
        // 코드가 있으면 size가 0보다 큰 게 나올 거다. 코드가 있으면 return true
        assembly { size := extcodesize(account)}
        return size > 0;
    }

    // 9. 토큰 소유주로부터 토큰을 없애는 함수
    function _removeTokenFromList(address from, uint256 tokenId) private {
        // 9-1. [10, 15, 19, 20] -> 19번 없애고 싶어요.
        // 9-2. [10, 15, 20, 19] 19를 찾아서 20번하고 자리를 바꾼다.
        // 9-3. [10, 15, 20] 그리고 길이를 1개줄여서 없앤다. 
        uint256 lastTokenIndex = _ownedTokens[from].length - 1;

        for(uint256 i = 0; i < _ownedTokens[from].length; i++) {
            if(tokenId == _ownedTokens[from][i]) {
                _ownedTokens[from][i] = _ownedTokens[from][lastTokenIndex];
                _ownedTokens[from][lastTokenIndex] = tokenId;
                break;
            }
        }
        _ownedTokens[from].length--;
    }

    function setTokenUri(uint256 id, string memory uri) public {
        tokenURIs[id] = uri;
    }

    // 7. 소유주가 가지고 있는 토큰 리스트, 배열같이 복잡하면 memory
    function ownedTokens(address owner) public view returns (uint256[] memory) {
        return _ownedTokens[owner];
    }
}

// 두 컨트랙트 연동할 때 
// 첫번째, 인터페이스, 다른 컨트랙트가 어떤 기능들을 가지고 있는지 알아야 한다.
// 두번째, 스마트 컨트랙트 주소를 알아야 한다.

contract NFTMarket {
    // 2. 누가 nft마켓에 보냈는지, 판매자를 기억하고 있어야 한다.
    mapping(uint256 => address) public seller;

    // 스마트 컨트랙트도 토큰을 소유할 수 있다.
    // 클레이 담는 함수도 payable
    function buyNFT(uint256 tokenId, address NFTAddress) public payable returns (bool) {

        // 3. 토큰 판 사람, 받을 사람은 이 주소이다 = 약간의 변환과정을 통해서 돈을 받을 수 있게(payable)을 붙여야 코드 상에서 클레이를 보내줄 수 있다.
        address payable receiver = address(uint160(seller[tokenId]));

        // 4. 구매한 사람한테 0.01 KLAY 전송
        // 10 ** 18 PEB = 1KLAY
        // 10 ** 16 PEB = 0.01KLAY
        // 코드 실행한 사람이 0.01 KLAY + 수수료까지 지갑에 들고 있어야 함수를 실행할 수 있게 된다.
        receiver.transfer(10 ** 16);

        // 1. 토큰 ID, NFT스마트컨트랙트 주소 // + 데이터 없으니 0x00
        NFTSimple(NFTAddress).safeTransferFrom(address(this), msg.sender ,tokenId, '0x00');
        // 1-1. 구매한 사람(== 함수 실행한 사람 == msg.sender)에게 마켓에 있던 토큰을 보내겠다.
        return true;
    }

    // 5. MARKET이 토큰을 받았을 때(판매대에 올라갔을 때), 판매자가 누구인지 기록해야 한다.
    function onKIP17Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4) {

        // 5-1. 토큰을 받았을 때 실행 되어야 하니
        seller[tokenId] = from;

        // 여기다 적는 건 굉장히 중요한데, 헷갈릴 분들은 잘 찾아보면 KIP17컨트랙트에서 KIP17_RECEIVED = 0x6745782b여기서 가져와라
        // 스마트컨트랙트가 토큰 박았을 때, 실행되는 게 있다고 말했는데, 그 친구가 나 실행 안해도 되는데? 라고 할 수 있다.
        // 실행하려는 애들은, 서로 암호문을 정해서? 수신호를 정해서? 너 이거 구현했으면 이러이러한 글자를 리턴해라. 문자를 리턴해라 하는 거다.
        // 그래서 bytes4해서 하면 0x6745782b를 리턴
        return bytes4(keccak256("onKIP17Received(address,address,uint256,bytes)"));
    }

}

// kip 17 백서
// approve는 다른 사람이 내 토큰을 남에게 줄 수 있게 해준다.

// IKIP17TokenReceiver
// 개인이 아닌 스마트 컨트랙트에게 토큰을 주기도 했었다
// 너가 만약 토큰을 받으면 이런 기능을 실행해줘를 할 수 있다.
// 이 스마트 컨트랙트가 nft, 토큰을 받았을 때 이러이러한 기능을 받을 수 있게 한다.
