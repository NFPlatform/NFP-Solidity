# NFP-Solidity



KIP: klaytn Improvement Proposals

KIP7 : 일반적인 토큰임 fungible-token (작품을 사면 nfp토큰을 바로 이걸로 만듬)
KIP17 : nft토큰에 대한 표준 인터페이스 non-fungible-token ()
-> nft 전송, 소유자가 누구인지 누구한테 허락하는지 등이 함수로 적혀 있음

KIP37 : nft토큰이지만 토큰한개당 하나만 발행하는 17토큰과 달리 여러개 발행 가능


### KIP17

### NFT-Market.sol

contract가 NFTSimple과 NFTMARKET 두개가 있다.
자세한 내용은 코드에 주석으로 적혀있다.

#### NFTSimple 컨트랙트에 대한 함수 순서 위주의 설명 

      * mintWithTokenURI함수와 safeTransferFrom함수가 핵심이다. *
      
      * mintWithTokenURI함수로 개인이 nft토큰을 만들고 다른사람에게 보낼때 safeTransferFrom함수를 사용한다.
      
      -> mintWithTokenURI함수를 사용해서 to에게 tokenId와 tokenURI가 있는 토큰을 발행한다 (쉽게 사람 한명이 NFT를 하나 만든다고 생각하면 된다.)
      
      
      -> safeTransferFrom함수는 from(즉 현재 소유자) 이 to (이제 가질 사람) 에게 tokenId를 전송하는것이다.
          (require문법을 써서 from == msg.sender)
      
      
      
      -> tokenOwner함수에 tokenId를 적으면 tokenOwner에서는 tokenId를 소유한 사람의 주소를 확인 할 수 있다. 
      
      -> tokenURIs함수에 tokenId를 적으면 tokenURIs에서는 mintWithTokenURI함수에서 적힌 tokenURI를 확인할 수 있다.
      
      -> ownedToken함수에 nft를 소유한 사람의 주소를 적으면 그 소유자가 소유하고 있는 tokenId가 순서대로 나온다. (배열에 각각의 tokenId를 넣었다.)
      
      
      
      
      
#### NFTMARKET 컨트랙트에 대한 함수 순서 위주의 설명










