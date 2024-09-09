 
 let contractAddress = {
    cyafarmAddr: "0x72266de00526a606802c108048638924354214ca", //cyafarm  
  }; 
   let contractAbi = {
  
    cyafarm: [
      "function seeding() public",
      "function choice(uint8 winnum) public",
      "function charge(uint256 _mypay)public",
      "function withdraw( )public",
      "function pllength( ) public view returns(uint)",
      "function getpl(uint num) public view returns(uint)",
      "function port(uint num) public view returns(uint,uint,uint,address)",
      "function getpay(address user) public view returns(uint)",
      "function mentopay(address user) public view returns(uint)",
      "function getvalue(uint num) public view returns(uint)",
      "function getmyfarm(uint num) public view returns(uint) ",
      "function getmygain() public view returns(uint) ",
      "function tax( ) public view returns(uint)", 
      "function mytiket(address user) public view returns(uint)", 
      "function rate( ) public view returns(uint)",
      "function remain( ) public view returns(uint256)",
      "function price( ) public view returns(uint256)",
      "function g1() public view virtual returns(uint256)",
      "event farmnum(uint winnum)"
    ]
  
  };
  
  
  const topDataSync = async () => {
    // ethers setup
    const provider = new ethers.providers.JsonRpcProvider('https://opbnb-mainnet-rpc.bnbchain.org');
    const cyafarmContract = new ethers.Contract(contractAddress.cyafarmAddr,contractAbi.cyafarm,provider);
    const fprice = await cyafarmContract.price();
    const fsum = await cyafarmContract.remain();
    const irate = await cyafarmContract.rate();
    const ipl = await cyafarmContract.pllength();
    const ibal = await cyafarmContract.g1();

    //계약잔고
    document.getElementById("Fprice").innerHTML = (fprice/1e18);
    document.getElementById("Farmtotal").innerHTML = (fsum);
    document.getElementById("Rate").innerHTML = (irate/1e18);
    document.getElementById("Pl").innerHTML = (ipl);
    document.getElementById("Cyabal").innerHTML = (ibal/1e18);
    
    
    const nftIds = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,15];
  
  const updateFarmCard = async (nftId) => {
      const depoInfo = await cyafarmContract.port(nftId);
      const valueInfo = await cyafarmContract.getvalue(nftId);
      const ownerInfo = depoInfo[3]; // 소유자 정보 추가 
      const card = document.createElement("div");
      card.className = "card";
      
      const cardBody = document.createElement("div");
      cardBody.className = "card-body";
      
      const cardTitle = document.createElement("h6");
      cardTitle.className = "card-title";
      cardTitle.textContent = `예치슬롯 ${nftId}`;
      
      const depoText = document.createElement("p");
      depoText.className = "card-text";
      depoText.textContent = `최초예치금 : ${depoInfo[0]/1e18}CYA`;
      
      const deponText = document.createElement("p");
      deponText.className = "card-text";
      deponText.textContent = `예치순서 : ${depoInfo[1]} 번째`;
      
      
      const valueText = document.createElement("p");
      valueText.className = "card-text";
      valueText.textContent = `예치금현재가치 : ${valueInfo/1e18} CYA`;
      
      // 소유자 정보를 추가
      const ownerText = document.createElement("p");
      ownerText.className = "card-text";
      ownerText.textContent = `예금주 : ${ownerInfo}`;
      
      cardBody.appendChild(cardTitle);
      cardBody.appendChild(depoText);
      cardBody.appendChild(deponText);
      cardBody.appendChild(valueText);
      // 카드 하단에 소유자 정보를 추가
      cardBody.appendChild(ownerText);  
      card.appendChild(cardBody);
      
      // 카드를 farmCards div에 추가
      const farmCards = document.getElementById("farmCards");
      farmCards.appendChild(card);
  };
  
  // 위에서 정의한 함수를 사용하여 농장 카드 업데이트
  for (const nftId of nftIds) {
      updateFarmCard(nftId);
  }
  
  cyafarmContract.on('farmnum', (winnum) => {
      console.log('구매한농장ID:', winnum);
      document.getElementById('eventData').innerText = `예치한 슬롯 번호: ${winnum}`;
  });
  
          
         };
       
  
         topDataSync();

  
         let MemberLogin = async () => {
          let userProvider = new ethers.providers.Web3Provider(window.ethereum, "any");
          await window.ethereum.request({
            method: "wallet_addEthereumChain",
            params: [{
                chainId: "0xCC",
                rpcUrls: ["https://opbnb-mainnet-rpc.bnbchain.org"],
                chainName: "opBNB",
                nativeCurrency: {
                    name: "BNB",
                    symbol: "BNB",
                    decimals: 18
                },
                blockExplorerUrls: ["https://opbnbscan.com"]
            }]
          });
          await userProvider.send("eth_requestAccounts", []);
          
          let signer = userProvider.getSigner();
          let cyafarmContract = new ethers.Contract(contractAddress.cyafarmAddr, contractAbi.cyafarm, signer);
        
          let mygain = await cyafarmContract.getpay(await signer.getAddress());
          let imytiket = await cyafarmContract.mytiket(await signer.getAddress());
      
          document.getElementById("Farmgain").innerHTML = parseInt(mygain/1e18).toFixed(2); //순이익 총액
          document.getElementById("LevelBar").style.width = `${imytiket/10*100}%`; 
        };
        
  
  
  
  
  
  let Buyfarm = async () => {
    let userProvider = new ethers.providers.Web3Provider(window.ethereum, "any");
    await window.ethereum.request({
      method: "wallet_addEthereumChain",
      params: [{
          chainId: "0xCC",
          rpcUrls: ["https://opbnb-mainnet-rpc.bnbchain.org"],
          chainName: "opBNB",
          nativeCurrency: {
              name: "BNB",
              symbol: "BNB",
              decimals: 18
          },
          blockExplorerUrls: ["https://opbnbscan.com"]
      }]
    });
    await userProvider.send("eth_requestAccounts", []);
    let signer = userProvider.getSigner();
    let cyafarmContract = new ethers.Contract(contractAddress.cyafarmAddr, contractAbi.cyafarm, signer)
  
    try {
      await cyafarmContract.seeding();
    } catch(e) {
      alert(e.message.replace('execution reverted: ',''));
    }
  
  }
  

  let Choice = async () => {
    let userProvider = new ethers.providers.Web3Provider(window.ethereum, "any");
    await window.ethereum.request({
      method: "wallet_addEthereumChain",
      params: [{
          chainId: "0xCC",
          rpcUrls: ["https://opbnb-mainnet-rpc.bnbchain.org"],
          chainName: "opBNB",
          nativeCurrency: {
              name: "BNB",
              symbol: "BNB",
              decimals: 18
          },
          blockExplorerUrls: ["https://opbnbscan.com"]
      }]
    });
    await userProvider.send("eth_requestAccounts", []);
    let signer = userProvider.getSigner();
    let cyafarmContract = new ethers.Contract(contractAddress.cyafarmAddr, contractAbi.cyafarm, signer)
    const mid = document.getElementById('Mid').value;
    try {
      await cyafarmContract.choice(mid);
    } catch(e) {
      alert(e.message.replace('execution reverted: ',''));
    }
  
  }
  

  
  let Charge= async () => {
    let userProvider = new ethers.providers.Web3Provider(window.ethereum, "any");
    await window.ethereum.request({
      method: "wallet_addEthereumChain",
      params: [{
          chainId: "0xCC",
          rpcUrls: ["https://opbnb-mainnet-rpc.bnbchain.org"],
          chainName: "opBNB",
          nativeCurrency: {
              name: "BNB",
              symbol: "BNB",
              decimals: 18
          },
          blockExplorerUrls: ["https://opbnbscan.com"]
      }]
    });
    await userProvider.send("eth_requestAccounts", []);
    let signer = userProvider.getSigner();
    let cyafarmContract = new ethers.Contract(contractAddress.cyafarmAddr, contractAbi.cyafarm, signer)
    const iamount = document.getElementById('Amount').value;
    try {
      await cyafarmContract.charge(iamount);
    } catch(e) {
      alert(e.message.replace('execution reverted: ',''));
    }
  
  }
  

  