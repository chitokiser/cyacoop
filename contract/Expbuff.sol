// SPDX-License-Identifier: MIT  
// ver1.1
pragma solidity >=0.7.0 <0.9.0;


interface Icut {      
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function g1() external view returns(uint256);
  function getdepot(address user) external view returns(uint256);
}


 interface Icutbank{      //컷뱅크

    function expup(address _user,uint _exp) external;
    function getlevel(address user) external view returns (uint);
  }  


contract expbuff {   //cut 5000개 이상 보유하고 있으면 경험치 20000버프 제공

  Icut cut;
  Icutbank cutbank;
  address admin;
  uint256 public stock; // cut보유량
 
  mapping (address => bool) public buffcheck; // exp버프 받았는지 여부
 
 
 
  constructor(address _cut, address _cutbank) {
  
    cut = Icut(_cut);
    cutbank = Icutbank(_cutbank);
    stock = 5000;
    admin = msg.sender;
    
  }
    
 
  



  function expbuffing() public {  
    require(cut.balanceOf(msg.sender) >= 5000, "Cut is not enough"); 
    require(cutbank.getlevel(msg.sender)>= 1, "Must be level 1 or higher"); 
    require(buffcheck[msg.sender] == false, "Already got the buff"); 
    cutbank.expup(msg.sender,20000);
    buffcheck[msg.sender] = true;
  }

  
 function stockup(uint _stock) public {  
    require(admin == msg.sender, "no admin"); 
    stock = _stock;
  }


function g1(address user) public view returns(uint) { // cut 잔고 확인
    return cut.balanceOf(user);
}  

function g3() public view returns(uint) { // cut 잔고 확인
    return cut.balanceOf(address(this));
}  
function getlevel(address user) public view returns(uint) { // cut 잔고 확인
    return cutbank.getlevel(user);
}  


function deposit() external payable {}
}
