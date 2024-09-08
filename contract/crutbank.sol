// SPDX-License-Identifier: MIT  
// ver1.0
pragma solidity >=0.7.0 <0.9.0;

interface Icya {     
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface Icrut {     
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
  function getdepot(address user)external view returns(uint256);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function g1()external view returns(uint256);
}


interface Icutbank {
    function depoup(address _user, uint _depo) external;
    function depodown(address _user, uint _depo) external;
    function getprice() external view returns (uint256);
    function getlevel(address user) external view returns (uint);
    function g9(address user) external view returns (uint); // 각 depo현황
    function getmento(address user) external view returns (address);
    function expup(address _user, uint _exp) external;
}

contract crutbank {
  Icya cya;
  Icrut crut;   //크럿토큰 
  Icutbank cutbank;
  uint256 public totaltax; // 누적 세금
  uint256 public tax;  // 세금
  uint8 public act;  //배당 가능여부    1=매수가능 2=배당 가능 3=매도가능
  uint256 public allow;
  address public gover; // 시아거버넌스
   address public cbank; // cutbank에 세금 일부 이체
  address public admin;
  uint256 public sold;  // cut 유통 수량
  uint8 public commission; // 기본값 20
  uint256 public fix;  // 토큰 가격 안정화를 위한 허수 초기값 1e6
 
  uint256[] public chart; // 가격 챠트 구현을 위한 배열 저장
  uint256 public price;  
 
  mapping (address => uint) public staff;
  mapping (address => uint) public allowt; // 배당 시간 
  event getdepo(uint amount);
     
  constructor(address _cya, address _crut,address _cutbank,address _gover) {
    fix = 1e16; //부동산 신탁이 추가되면   
    cya = Icya(_cya);
    cutbank = Icutbank(_cutbank);
    crut = Icrut(_crut);
    gover = _gover;  // 거버넌스
    cbank = _cutbank;
    price = 1e16;
    sold = 1000;
    act =3 ;   //1배당가능 2토큰매수가능 3토큰매도가능
    admin = msg.sender;
    staff[msg.sender] = 10;
    commission = 20;
  }
    



  function actup(uint8 _num) public {  
    require(admin == msg.sender, "no admin"); 
    act = _num;
  }
  function staffup(address _staff, uint8 num) public {  
    require(admin == msg.sender, "no admin"); 
    staff[_staff] = num;
  }   

  function taxout() public {
  if(tax >= 1e20){  
  cya.transfer(gover,g1()*40/100);
  cya.transfer(cbank,g1()*10/100);
  tax = 0;
  }
  }   
  

  function goverup(address _gover) public {  
    require(admin == msg.sender, "no admin");
    gover = _gover;   // 초기값은  시아거버넌스에 줄 것
  }

    function cbankup(address _cbank) public {  
    require(admin == msg.sender, "no admin");
    cbank = _cbank;   // 초기값은  cutbank에 줄 것
  }

  function buycrut(uint _num) public returns(bool) {  
    uint pay = _num * price;
    require(act >= 1, "Not for sale");  
    require(g3() >= _num, "Crut sold out");  
    require(1 <= _num, "1 or more");
    require(1 <= cutbank.getlevel(msg.sender), "no member");
    require(cya.balanceOf(msg.sender) >= pay, "no cya"); 
    cya.approve(msg.sender, pay); 
    uint256 allowance = cya.allowance(msg.sender, address(this));
    require(allowance >= pay, "Check the token allowance");
    cya.transferFrom(msg.sender, address(this), pay);  
    crut.transfer(msg.sender, _num);
    cutbank.expup(msg.sender,_num/10) ;
    cutbank.depoup( cutbank.getmento(msg.sender),pay * commission / 100); 
    allowt[msg.sender] = block.timestamp;
    priceup();
    tax += pay * 50 / 100;
    return true;     
    }

function assetadd(uint _fix) public{
    require(staff[msg.sender] >= 5, "no staff");  //자산의 가치를 추가하면 자동으로 나눠짐
    fix = _fix*1e18/1000000000;
}

function sellcrut(uint num) public returns(bool) {      
    uint256 pay = num * price;  
    require(act >= 3, "Can't sell"); 
    require(1 <= num, "1 or more");
    require(6 <= cutbank.getlevel(msg.sender), "Level 6 or higher"); 
    require(g8(msg.sender) >= num, "no crut");
    require(g1() >= pay, "no cya");
    crut.approve(msg.sender, num);
    uint256 allowance = crut.allowance(msg.sender, address(this));
    require(allowance >= num, "Check the allowance");
    crut.transferFrom(msg.sender, address(this), num); 
    cya.transfer(msg.sender, pay);
    priceup();
    return true;
}


function allowcation() public returns(bool) {   // depo 증가
    require(act >= 2, "No dividend");  
    require(cutbank.getlevel(msg.sender) >= 1, "no member");  
     require(g8(msg.sender) >= 5000, "No crut");  
    require(allowt[msg.sender] + 7 days < block.timestamp, "not time"); // 주 1회
    require(crut.getdepot(msg.sender) + 7 days < block.timestamp, "crut not time"); // 주 1회
    allowt[msg.sender] = block.timestamp;
    uint256 pay = getpay(msg.sender); 
    cutbank.expup(msg.sender,5000);
    cya.transfer(msg.sender,pay);
    emit getdepo(pay);
    return true;
}
  


function fixup(uint256 _fix) public {  // 부동산 추가 되면 가격 상승
    require(admin == msg.sender, "no admin");
    fix = _fix;  
}  


function commissionup(uint8 _commission) public {  // 수동올려보내기
    require(admin == msg.sender, "no admin");
    commission = _commission;  
}  

function priceup() public {
    sold = g11();
    allow = g1() / (sold); 
    price = allow + fix;
    chart.push(price);   
}


function g1() public view virtual returns(uint256) {  
    return cya.balanceOf(address(this));
}


function g2() public view virtual returns(uint256) {  
    return cya.balanceOf(msg.sender);
}
function g3() public view returns(uint) { // cut 잔고 확인
    return crut.balanceOf(address(this));
}  

  function g4() public view virtual returns(uint){  
  return chart.length;
  }
    function g5(uint _num) public view virtual returns(uint256){  
  return chart[_num];
  }
function g6() public view virtual returns(uint256){  
  return crut.balanceOf(address(this));
  }
function g8(address user) public view returns(uint) {  // 유저 crut 잔고 확인
    return crut.balanceOf(user);
}  

function g10() public view virtual returns(uint256) {  
    return crut.g1();  
}

function g11() public view virtual returns(uint256) {  
    return g10() - g3();  // vet 총발행량 - 계약이 가지고 있는 crut
}
  
function g12(address user) public view virtual returns(uint256) {  
    return cutbank.getlevel(user);  // vet 총발행량 - 계약이 가지고 있는 met
}  

function getpay(address user) public view returns (uint256) { // next dividend
    return g8(user) * allow * g12(user)/ 2000;
}
  
function gettime() public view returns (uint256) {  
    return (allowt[msg.sender] + 604800) - block.timestamp;
}

function getprice() public view returns (uint256) {  
    return price;
}


function deposit() external payable {}

 function withdrawbnb(uint256 amount) external {
        require(msg.sender == admin, "Only admin can withdraw");  // 관리자만 인출 가능
        require(address(this).balance >= amount, "Insufficient balance in contract");

        // 송금하기
        payable(msg.sender).transfer(amount);
    }
}
