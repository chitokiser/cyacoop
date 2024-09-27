 
      const cA = {
        cyadexAddr: "0x3900609f4b3C635ae1cFC84F4f86eF7166c6139e",
        cyamemAddr: "0x3Fa37ba88e8741Bf681b911DB5C0F9d6DF99046f",   
        mutbankAddr:"0x04F30f139260e36BF8A857e05e4863a94731f2ff",  //NEW CUTBANK
        erc20: "0xFA7A4b67adCBe60B4EFed598FA1AC1f79becf748"
      };
      const cB = {
        cyadex: [
          "function getprice() public view returns(uint256)",
          "function balance() public view returns(uint256)",
          "function cyabalances() public view returns(uint256)",
          "function buy() payable public",
          "function sell(uint256 num) public"
        ],
        cyamem: [
          "function sum() public view returns(uint256)",
          "function catbal() public view returns(uint256)"
        ],

        mutbank: [
        "function memberjoin(address _mento) public ",
        ],
        erc20: [
          "function approve(address spender, uint256 amount) external returns (bool)",
          "function allowance(address owner, address spender) external view returns (uint256)"
        ]
      };

      const topData= async () => {
        

         // BNB Price
const responseBinanceTicker = await axios.get('https://api.binance.com/api/v3/ticker/price?symbol=BNBUSDT');
const bnbPrice = parseFloat(responseBinanceTicker.data.price);
document.getElementById("bPrice").innerHTML=bnbPrice.toFixed(4);
document.getElementById("cPrice2").innerHTML=(1/bnbPrice).toFixed(4);


        // ethers setup
        let provider = new ethers.providers.JsonRpcProvider('https://opbnb-rpc.publicnode.com');
        let cyadexContract = new ethers.Contract(cA.cyadexAddr,cB.cyadex, provider); 
        let dexBal = await cyadexContract.balance();
        document.getElementById("Tvl").innerHTML=  parseFloat(dexBal/1e18).toFixed(4); 
          
      };
   
      const addTokenCya = async () => {
        await window.ethereum.request({
          method: 'wallet_watchAsset',
          params: {
            type: 'ERC20',
            options: {
              address: "0xFA7A4b67adCBe60B4EFed598FA1AC1f79becf748",
              symbol: "CYA",
              decimals: 18, 
              // image: tokenImage,
            },
          },
        });
      }

   
      const addTokenHut = async () => {
        await window.ethereum.request({ 
          method: 'wallet_watchAsset',
          params: {
            type: 'ERC20',
            options: {
              address: "0x9df9aa67b106063B5b8A6160EE5bBF45f58E8759",  //new cut
              symbol: "CUT",
              decimals: 0, 
              // image: tokenImage,
            },
          },
        });
      }
   
      const addTokenCrut = async () => {
        await window.ethereum.request({ 
          method: 'wallet_watchAsset',
          params: {
            type: 'ERC20',
            options: {
              address: "0x73f7982c99c76b4Fe4D587D607dA32259D2bfAf4",  //cRut
              symbol: "CRUT",
              decimals: 0, 
              // image: tokenImage,
            },
          },
        });
      }


 topData();
      


 let Tmemberjoin = async () => {
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

  let meta5Contract = new ethers.Contract(cA.mutbankAddr,cB.mutbank,signer);

  try {   
    await meta5Contract.memberjoin(document.getElementById('Maddress').value);
  } catch(e) {
    alert(e.data.message.replace('execution reverted: ',''))
  }
};



   