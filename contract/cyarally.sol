// SPDX-License-Identifier: MIT  
//ver1.2
pragma solidity >=0.7.0 <0.9.0;

  
  interface Icya{
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool); 
  }
  

  interface Icut{
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool); 
  }


    interface Icutbank{      // 컷뱅크
     function depoup(address _user, uint _depo) external;
    function depodown(address _user, uint _depo) external;
    function getprice() external view returns (uint256);
    function getlevel(address user) external view returns (uint);
    function g9(address user) external view returns (uint);  // 각 depo현황
    function getagent(address user) external view returns (address);
    function getmento(address user) external view returns (address);
    function expup(address _user,uint _exp) external;
  
  }  
    
 
contract cyarally {   
  
  Icya cya;
  Icut cut;
  Icutbank cutbank;
  address public admin; 
  address public cbank; 
  uint256 public mid;  
  uint256 public fee; //계좌등록비용
 
  

  mapping(address => uint8)public staff;
  mapping(address => uint8)public myfee; //기본값
  mapping(uint256 => meta)public metainfo;  

      
      
   constructor(address _cya,address _cut, address _cutbank) {
    cya = Icya(_cya);
    cut = Icut(_cut);
    cutbank = Icutbank(_cutbank);
    cbank = _cutbank;
    admin = msg.sender;
    staff[msg.sender] = 5;
    fee = 30*1e18; //최초 30cya
}



    struct meta{
    uint256 time; //가입날짜 
    uint256 cutreward; //보상처리결과
    uint256 mid;  
    string invest; // 관람자비번
    uint256 metanum;  //가입계좌 번호
    uint256 init;  //최초가격
    address owner;  //가입자
    uint8 act;  // 0트레이딩중,1보상신청,2보상완료 3보상금액 찾아감
    }
   

    function staffup(address _staff,uint8 _level )public {   
    require(staff[msg.sender] >= 5,"no staff");
    staff[_staff] = _level;
    } 




function registration(uint256 _metanum,string memory  _invest)public {   //랠리 참여 데모계좌등록
    uint pay = (myfee[msg.sender]+1)*fee ; //최초값이 0이기 때문에 +1   
    require(cya.balanceOf(msg.sender) >= pay,"no cya");    
    require(cut.balanceOf(msg.sender) >= 5000,"no member"); 
    cya.approve(msg.sender, pay); 
    uint256 allowance = cya.allowance(msg.sender, address(this));
    require(allowance >= pay, "Check the token allowance");
    cya.transferFrom(msg.sender, address(this), pay);  
    address _mento =  cutbank.getmento(msg.sender);
    cutbank.depoup(_mento,pay*20/100);  //멘토 수당
    metainfo[mid].time = block.timestamp;
    metainfo[mid].mid = mid;
    metainfo[mid].metanum = _metanum;
    metainfo[mid].init = 3000*1e18;
    metainfo[mid].invest = _invest;   //관람자 비번
    metainfo[mid].owner = msg.sender;
    myfee[msg.sender] += 1;  //다음계좌등록시 등록비 증가
    mid += 1;
 
} 


function exit(uint256 _mid)public {   //보상신청
    
    require( metainfo[_mid].owner == msg.sender,"no owner");   
    require( metainfo[_mid].act == 0,"Processing or Processing Completed");   
  
    metainfo[_mid].act = 1; //보상신청 상태
   
} 


function audit(uint256 _mid,uint256 _cutreward)public {   //보상검증
    
    require(staff[msg.sender] >= 5,"no staff");   
   
    metainfo[_mid].cutreward = _cutreward; // cut 소수점 없음
    metainfo[_mid].act = 2; //처리완료

} 

function reaudit(uint256 _mid,uint256 _cutreward)public {   //보상검증
    
    require(staff[msg.sender] >= 5,"no staff");   
   
    metainfo[_mid].cutreward = _cutreward; //보상신청 상태 
    metainfo[_mid].act = 2; //처리완료
} 



function  withdrw(uint256 _mid)public {   //인출
    uint pay = metainfo[_mid].cutreward;
    require( metainfo[_mid].owner == msg.sender,"no owner");   
    require( metainfo[_mid].act == 2,"Processing");  
    require(cut.balanceOf(address(this)) >= pay,"no cut"); 

    metainfo[_mid].act = 3; //인출완료
    cut.transfer(msg.sender,pay);
    cya.transfer(cbank,g1());
} 
    
    function feeup(uint8 _fee) public {  //기본값 30e18
      require(staff[msg.sender] >= 5,"no staff");
      fee = _fee*1e18;
    }
    
  
 
  
  function g1() public view virtual returns(uint256){  
  return cya.balanceOf(address(this));
  }

  function g2(address user) public view virtual returns(uint256){  
  return cya.balanceOf(user);
  }
    function g3() public view virtual returns(uint256){  
  return cut.balanceOf(address(this));
  }

 function g4(address user) public view virtual returns(uint256){  
  return cut.balanceOf(user);
  }
}




  
    