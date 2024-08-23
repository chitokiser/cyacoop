let contractAddress = {
  cutbank: "0x04F30f139260e36BF8A857e05e4863a94731f2ff",  //new cutbank

  };
  let contractAbi = {
   

   
    cutbank: [
      "function g1() public view virtual returns(uint256)",
      "function g6() public view virtual returns(uint256)",
      "function g7() public view virtual returns(uint256)",
      "function g8(address user) public view virtual returns(uint256)",
      "function g9(address user) public view returns(uint)",
      "function g10() public view virtual returns(uint256)",
      "function allow() public view returns(uint256)",
      "function sum() public view returns(uint256)",
      "function allowt(address user) public view returns(uint256)",
      "function g11() public view virtual returns(uint256)",
      "function getprice() public view returns (uint256)",
      "function gettime() external view returns (uint256)",
      "function withdraw() public ",
      "function buysut(uint _num) public returns(bool)",
      "function sellsut(uint num)public returns(bool)",
      "function getpay(address user) public view returns (uint256)",
      "function allowcation() public returns(bool) ",
      "function getlevel(address user) public view returns(uint) ",
      "function getmento(address user) public view returns(address) ",
      "function memberjoin(address _mento) public ",
      "function myinfo(address user) public view returns(uint256,uint256,uint256,address,uint256)",
      "function levelup() public",
      "function getmymenty(address user) public view returns (address[] memory)"

    ]


  };

  let provider;
  let contract;


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
    let cyamemContract = new ethers.Contract(contractAddress.cutbank, contractAbi.cutbank, signer);
    let my = await cyamemContract.myinfo(await signer.getAddress());
     let mybonus =  (await my[1]);
     let mylev =  (await my[2]);
     let mymento =  (await my[3]);
     let myexp =  (await my[4]);
   
    
    let levelexp = (2**mylev)*10000;

    document.getElementById("Mymento").innerHTML = (mymento);
    document.getElementById("Mylev").innerHTML = (mylev);
    document.getElementById("Mylev2").innerHTML = (mylev);
    document.getElementById("Exp").innerHTML =  (myexp);
    document.getElementById("Expneeded").innerHTML = (levelexp);
    document.getElementById("Mypoint").innerHTML =  (mybonus/1e18).toFixed(4);
    document.getElementById("LevelBar").style.width = `${myexp/levelexp*100}%`; // CHECK:: 소수점으로 나오는 것 같아 *100 했습니다. 


  };

  let Levelup = async () => {
   
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
    let cyamemContract = new ethers.Contract(contractAddress.cutbank, contractAbi.cutbank, signer);
    
    try {
      await cyamemContract.levelup(); 
    } catch(e) {
      alert(e.data.message.replace('execution reverted: ',''))
    }
  
};




let Bonuswithdraw = async () => {
   
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

  let cyamemContract = new ethers.Contract(contractAddress.cutbank, contractAbi.cutbank, signer);
  
  try {
    await cyamemContract. withdraw(); 
    //await cyabankContract.buycut(document.getElementById('buyAmount').value);
  } catch(e) {
    alert(e.data.message.replace('execution reverted: ',''))
  }

};


// 페이지 로드 후 계약 초기화
window.onload = async () => {
  if (window.ethereum) {
    provider = new ethers.providers.Web3Provider(window.ethereum);
    await provider.send("eth_requestAccounts", []);
    const signer = provider.getSigner();
    contract = new ethers.Contract(contractAddress.cutbank, contractAbi.cutbank, signer);
  } else {
    alert('Ethereum 공급자가 없습니다. MetaMask를 설치해주세요.');
  }
};

// 주소 배열을 가져와서 HTML에 표시하는 함수
const fetchAddresses = async () => {
  try {
    const signer = provider.getSigner();
    const userAddress = await signer.getAddress();
    console.log("Calling getmymenty with address:", userAddress);

    const addresses = await contract.getmymenty(userAddress);
    console.log("Addresses returned:", addresses);

    // HTML 업데이트
    const addressList = document.getElementById('addressList');
    addressList.innerHTML = ''; // 이전 결과 삭제
    addresses.forEach(address => {
      const listItem = document.createElement('li');
      listItem.textContent = address;
      addressList.appendChild(listItem);
    });
  } catch (error) {
    console.error('주소를 가져오는 중 오류가 발생했습니다:', error);
    alert('주소를 가져오는 중 오류가 발생했습니다. 콘솔에서 확인해 주세요.');
  }
};

// 버튼 클릭 시 주소 가져오기
document.getElementById('fetchAddresses').addEventListener('click', fetchAddresses);