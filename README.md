# NFP-Solidity

작가가 그림 등록하려고 할때 호출하는 함수 순서

  1. 작가가 자신만의 nft 즉 그림을 만든다
  2. 그림을 사이트에 올린다
  3. 사이트에 올라온 nft를 다른 사람이 산다 


  KIP17Token에서 우리가 사용할 것들만 간단히 빼서 만든게 NFT-Market.sol 안에 있는 NFTSimple contract이다.  <br/><br/><br/>
 
---

1. NFT-Market.sol에서 NFTSimple contract를 실행한다.
  
  mintWithTokenURI 함수를 사용해서 to에게 tokenId와 tokenURI가 있는 토큰을 발행한다 <br/>
  (쉽게 사람 한명이 NFT를 하나 만든다고 생각하면 된다.)<br/><br/>
  
  
  safeTransferFrom 함수는 from(즉 현재 소유자) 이 to (이제 가질 사람) 에게 tokenId를 전송하는것이다. <br/>
            
            
            
  to (스마트컨트랙트 즉 우리 nfp사이트에 올리는 경우) -> <br/>
           to에 NFTMARKET 컨트랙트의 주소를 적어서 보내주면 된다. 그럼 사이트에 등록됨 <br/>
            NFTMARKET안에 seller를 확인해보면 우리 사이트에 올린 사람의 주소가 나온다 (즉 실제로 판매하는 사람의 주소를 우리사이트에서 확인가능<br/><br/>
            
            
2.  NFTMARKET안에 buyNFT함수를 통해서 구매자에게 판매할수 있다. -> 여기서는 tokenId와 NFTSimple contract주소를 적어줘야한다.<br/><br/>

   
       -> 즉 소유자가 우리 사이트에서 이 그림을 사는 사람에게 감 <br/>
       -> 여기서는 사는 사람은 수수료를 내야함 (0.001클레이정도) (payable이 적혀있는 함수는 실제 돈이 왔다갔다하는 함수) <br/>
       -> 개인주소가 달라지면 NFTSimple contract주소를 불러낸것도 개인이기 때문에 그 주소가 연동되서 거기로 감 <br/><br/>
   
---

### NFT-Market.sol <br/><br/>

contract가 NFTSimple과 NFTMARKET 두개가 있다. <br/><br/>
문법에 대한 자세한 내용은 코드에 주석으로 적혀있다. <br/><br/>

#### NFTSimple 컨트랙트에 대한 함수 실행 순서 위주의 설명 

NFTsimple로 하나의 nft를 만든다 그리고 전송을 할수가 있다

NFTMARKET으로는 우리가 만든 사이트에서 실제 nft를 사고팔때 작동하는 스마트 컨트랙트이다. <br/><br/><br/>



   ** mintWithTokenURI함수와 safeTransferFrom함수가 핵심이다. **
      
  ** mintWithTokenURI함수로 개인이 nft토큰을 만들고 다른사람에게 보낼때 safeTransferFrom함수를 사용한다. 
      
   mintWithTokenURI함수를 사용해서 to에게 tokenId와 tokenURI가 있는 토큰을 발행한다 (쉽게 사람 한명이 NFT를 하나 만든다고 생각하면 된다.)
     
   safeTransferFrom함수는 from(즉 현재 소유자) 이 to (이제 가질 사람) 에게 tokenId를 전송하는것이다.
          (require문법을 써서 from == msg.sender) 
            
      
  -> tokenOwner함수에 tokenId를 적으면 tokenOwner에서는 tokenId를 소유한 사람의 주소를 확인 할 수 있다. 
      
  -> tokenURIs함수에 tokenId를 적으면 tokenURIs에서는 mintWithTokenURI함수에서 적힌 tokenURI를 확인할 수 있다.
      
  -> ownedToken함수에 nft를 소유한 사람의 주소를 적으면 그 소유자가 소유하고 있는 tokenId가 순서대로 나온다. (배열에 각각의 tokenId를 넣었다.)      












