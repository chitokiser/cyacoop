let hutaddr = {  
    hutito: "0x68bE39Dbcf950b36B061Fd5a50CCAD9d08D07299" //hutito

  };

  let hutabi = {
  
    hutito: [
   
 
       "function g1() public view virtual returns(uint256)",
       "function g2() public view virtual returns(uint256)",
       "function g4() public view virtual returns(uint256) ",
       "function rate() public view virtual returns(uint256) ", //토큰할인율
       "function memberjoin(address _mento) public ",
       "function offering(uint _num) public",
       "function withdraw()public",
       "function getMenty(address user) public view returns (address[] memory)",
       "function myinfo(address user) public view virtual returns(address,uint256,bool) "
      ],
      
 

  };

  let itotopSync = async () => {

    let provider = new ethers.providers.JsonRpcProvider('https://opbnb-mainnet-rpc.bnbchain.org');
    let meta5Contract = new ethers.Contract(hutaddr.hutito, hutabi.hutito, provider);
  
    

    let icya = await meta5Contract.g1();  
    let ihut = await meta5Contract.g2();
    let irate = await meta5Contract.rate();
    let iprice = await meta5Contract.g4();
   
    document.getElementById("Cyabalito").innerHTML= (icya/1e18).toFixed(2);   
    document.getElementById("Hutbalito").innerHTML= (ihut);   
    document.getElementById("Hutrate").innerHTML= (100-irate);   
    document.getElementById("Hprice").innerHTML= (iprice/1e18).toFixed(4);   
    }
   

 // 호출 코드
 itotopSync();
  



 let Hutmemberjoin  = async () => {
   
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

  let meta5Contract = new ethers.Contract(hutaddr.hutito, hutabi.hutito, signer);
  try {
    await meta5Contract.memberjoin(document.getElementById('hutmento').value);
  } catch(e) {
    alert(e.data.message.replace('execution reverted: ',''))
  }

};

let Hutoper  = async () => {
   
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

  let meta5Contract = new ethers.Contract(hutaddr.hutito, hutabi.hutito, signer);
  try {
    await meta5Contract.offering(document.getElementById('hutAmount').value);
  } catch(e) {
    alert(e.data.message.replace('execution reverted: ',''))
  }

};

let HutLogin = async () => {
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
  let meta5Contract = new ethers.Contract(hutaddr.hutito, hutabi.hutito, signer);

  let my = await meta5Contract.myinfo(await signer.getAddress());
  let imento =  (await my[0]);
  let idepo =  (await my[1]);
  let icerti =  (await my[2]);
  document.getElementById("Mymento").innerHTML = (imento);
  document.getElementById("Myfee").innerHTML = (idepo/2e18).toFixed(2);
  document.getElementById("Mentobool").innerHTML =  (icerti);
 
};





let Withdraw = async () => {
   
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

  let meta5Contract = new ethers.Contract(hutaddr.hutito, hutabi.hutito, signer);
  try {
    await meta5Contract.withdraw(); 
  } catch(e) {
    alert(e.data.message.replace('execution reverted: ',''))
  }

};


document.addEventListener("DOMContentLoaded", function() {
  let Getmymenty = async () => {
      try {
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

          console.log("Signer obtained:", signer);

          let meta5Contract = new ethers.Contract(hutaddr.hutito, hutabi.hutito, signer);

          // 사용자의 주소를 가져옵니다.
          let userAddress = await signer.getAddress();
          console.log("User Address:", userAddress);
          
          // getMenty 함수를 호출합니다.
          let menties = await meta5Contract.getMenty(userAddress); 
          console.log("Menties obtained:", menties);
          
          // 결과를 DOM에 표시합니다.
          let mentiesList = document.getElementById("Mymenty");
          mentiesList.innerHTML = ""; // 기존 내용을 지웁니다

          menties.forEach((item) => {
              let listItem = document.createElement("li");
              listItem.textContent = item;
              mentiesList.appendChild(listItem);
          });
      } catch(e) {
          console.error(e);
          alert(e.message ? e.message : 'An unknown error occurred');
      }
  };

  // 버튼 클릭 이벤트 핸들러 추가
  document.getElementById("getMentyButton").addEventListener("click", Getmymenty);
});