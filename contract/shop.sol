
// SPDX-License-Identifier: MIT  
// ver1.2
pragma solidity >=0.7.0 <0.9.0;

interface Icya {
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool); 
}

interface Icut {
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool); 
}

interface Icutbank {
    function depoup(address _user, uint _depo) external;
    function depodown(address _user, uint _depo) external;
    function getprice() external view returns (uint256);
    function getlevel(address user) external view returns (uint);
    function g8(address user) external view returns(uint); //유저별 cut 현황
    function g9(address user) external view returns (uint); // 각 depo현황
    function getagent(address user) external view returns (address);
    function getmento(address user) external view returns (address);
    function expup(address _user, uint _exp) external;
}

contract shop { //시아 숍 구매하면 CUT제공
    Icya cya;
    Icut cut;
    Icutbank cutbank;

    address public admin; 
    address public taxbank;
    uint256 public pid; 
    uint256 public bid; //구매자수
    uint256 public tax; // 매출
    uint8 public basic; //기본 배송량
 
  
    mapping(address => uint8) public staff;
    mapping(address => uint256) public mynum;
    mapping(uint256 => buyer)public bs;  //조합원별 꾸러미 상태추적
    mapping(uint256 => Meta) public metainfo; // 제품id별 추적
   
   

      
    constructor(address _cya, address _taxbank, address _cutbank) {
        cya = Icya(_cya);
        cutbank = Icutbank(_cutbank);
        admin = msg.sender;
        staff[msg.sender] = 5;
        taxbank = _taxbank;  
        basic = 12;
    }

    struct Meta {
        string name; // 물건이름
        string detail; // 물건설명
        string img; // 물건 사진
        uint256 left; // 재고
        uint256 payrate; //수당 적립금 비율
        uint256 cutreward;  //CUT제공 개수
        uint256 price; // 가격
    }
   
     struct buyer {
        uint256 pay; // 결제금액
        uint256 pid;  //구매한 제품id
        address owner; // 구매 어카운트
        string buyername; // 구매자 이름
        string phone; // 전화번호
        string house; // 배송받을 주소
        uint256 time; //꾸러미 구매날짜
    }

  


    modifier onlyAdmin() {
        require(msg.sender == admin, "Caller is not admin");
        _;
    }

    modifier onlyStaff(uint level) {
        require(staff[msg.sender] >= level, "Insufficient staff level");
        _;
    }

    function staffup(address _staff, uint8 _level) public onlyStaff(5) {   
        staff[_staff] = _level;
    } 

   

     function nameup(uint256 _mid,string memory _name) public onlyStaff(5) {   
        metainfo[_mid].name = _name;
    } 
  

    
     function cutrewardup(uint256 _mid,uint256 _cutreward) public onlyStaff(5) {   
        metainfo[_mid].cutreward = _cutreward;
    } 

  
    
        function detailup(uint256 _bid,string memory _detail) public onlyStaff(5) {   
        metainfo[_bid].detail = _detail;
    } 

        function imagesup(uint256 _bid,string memory _img) public onlyStaff(5) {   
        metainfo[_bid].img = _img;
    } 
     



        function priceup(uint256 _bid,uint256 _price) public onlyStaff(5) {   
        metainfo[_bid].price = _price ;
    } 

         function leftup(uint256 _mid,uint256 _left) public onlyStaff(5) {   
        metainfo[_mid].left = _left ;
    } 

        function basicup(uint8 _basic) public onlyStaff(5) {   //베이직 업
          basic = _basic;
    } 


    function taxbankup(address _taxbank) public onlyStaff(5) {   
        taxbank = _taxbank;
    } 



    function buyernameup(string memory _name) public  {  
        uint256 mybid = mynum[msg.sender];
    require( bs[mybid].owner == msg.sender, "Not a package member");

        bs[mybid].buyername = _name;
    } 

   
    function buyerphoneup(string memory _phone) public  {  
        uint256 mybid = mynum[msg.sender];
    require( bs[mybid].owner == msg.sender, "Not a package member");

        bs[mybid].phone = _phone;
    } 
    
     
    function buyerhouseup(string memory _house) public  {  
        uint256 mybid = mynum[msg.sender];
    require( bs[mybid].owner == msg.sender, "Not a package member");

        bs[mybid].house = _house;
    } 

    function cyatransfer(uint _num) public onlyStaff(5) {   
        cya.transfer(taxbank,_num);
    } 

    
    function newMeta(string memory _name,string memory _detail, string memory _img, uint256 _price,uint256 _left,uint256 _rate,uint256 _cutreward) public onlyStaff(5) {
      
        Meta storage meta = metainfo[pid];
        meta.name = _name;
        meta.detail = _detail;
        meta.img = _img;  
        meta.left = _left;
        meta.payrate = _rate;
        meta.cutreward = _cutreward;
        meta.price = _price *1e18; //cya기준 제품가격
        pid += 1 ;
    }

  

    function buy(uint _pid,uint num,string memory name,string memory house,string memory phone) public {  //꾸러미 12회
        uint pay = metainfo[_pid].price*num;
        require(metainfo[_pid].left >= num, "Not for sale");
        require(cutbank.getlevel(msg.sender) >= 1, "No member");
        require(g2(msg.sender) >= pay, "cya not enough");
        require( mynum[msg.sender]==0, "Not a package member");
        cya.approve(msg.sender, pay); 
        uint256 allowance = cya.allowance(msg.sender, address(this));
        require(allowance >= pay, "Check the token allowance");
        cya.transferFrom(msg.sender, address(this), pay); 
        address mymento =  cutbank.getmento(msg.sender);
        cutbank.depoup(mymento,pay * metainfo[_pid].payrate /100);
        cut.transfer(msg.sender,num* metainfo[_pid].cutreward);
        mynum[msg.sender] = bid;
        buyer storage bs = bs[bid];
        bs.pid = _pid;
        bs.owner = msg.sender;
        bs.pay = pay;
        bs.buyername = name;
        bs.house = house;
        bs.phone = phone;
        bs.time = block.timestamp; //구매날짜
        metainfo[_pid].left -= 1;  //재고량
        bid += 1;
        
    }


    function g1() public view virtual returns (uint256) {  
        return cya.balanceOf(address(this));
    }

    function g2(address user) public view virtual returns (uint256) {  
        return cya.balanceOf(user);
    }

    function g3(address user) public view virtual returns (uint256) {  //유저별 cut보유현황 꾸러미 등록전
        return cutbank.g8(user);
    }
   

         function g4(uint _bid) public view virtual returns (address) {  //구매자 주소
  return bs[_bid].owner;
}



}