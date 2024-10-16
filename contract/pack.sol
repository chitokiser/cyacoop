
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

interface Ihutbank {
    function depoup(address _user, uint _depo) external;
    function depodown(address _user, uint _depo) external;
    function getprice() external view returns (uint256);
    function getlevel(address user) external view returns (uint);
    function g9(address user) external view returns (uint); // 각 depo현황
    function getagent(address user) external view returns (address);
    function getmento(address user) external view returns (address);
    function expup(address _user, uint _exp) external;
}

contract cyatoken_trade { //제품
    Icya cya;
    Ihutbank hutbank;
    address public admin; 
    address public taxbank;
    uint256 public pid; 
    uint256 public bid; //바이어 아이디
    uint256 public tax; // 매출

  
    mapping(address => uint8) public staff;
    mapping(uint256 => buyer)public bs;
    mapping(address => uint256)public mydepo;
    mapping(uint256 => Meta) public metainfo; // id별 계좌정보
   
   

      
    constructor(address _cya, address _taxbank, address _hutbank) {
        cya = Icya(_cya);
        hutbank = Ihutbank(_hutbank);
        admin = msg.sender;
        staff[msg.sender] = 5;
        taxbank = _taxbank;
    }

    struct Meta {
        string name; // 물건이름
        string detail; // 물건 정보 상세페이지
        string img; // 물건 사진
        uint256 left; // 재고
        uint256 payrate; //적립금
        uint256 price; // 가격
    }
   
     struct buyer {
        uint256 oder; // 주문수량
        uint256 pay; // 결제금액
        uint8 dv ; // 배송상태  1배송준비 2배송중 3배송완료 4환불
        uint256 pid;
        address owner; // 구매 어카운트
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

  
    
        function detailup(uint256 _mid,string memory _detail) public onlyStaff(5) {   
        metainfo[_mid].detail = _detail;
    } 

        function imagesup(uint256 _mid,string memory _img) public onlyStaff(5) {   
        metainfo[_mid].img = _img;
    } 
     



        function priceup(uint256 _mid,uint256 _price) public onlyStaff(5) {   
        metainfo[_mid].price = _price ;
    } 

         function leftup(uint256 _mid,uint256 _left) public onlyStaff(5) {   
        metainfo[_mid].left = _left ;
    } 

        function dvup(uint256 _bid,uint8 _dv) public onlyStaff(5) {   //배송상태 업그레이드
          bs[_bid].dv = _dv;
    } 


    function taxbankup(address _taxbank) public onlyStaff(5) {   
        taxbank = _taxbank;
    } 



    function cyatransfer(uint _num) public onlyStaff(5) {   
        cya.transfer(taxbank,_num);
    } 

    
    function newMeta(string memory _name,string memory _detail, string memory _img, uint256 _price,uint256 _left,uint256 _rate) public onlyStaff(5) {
      
        Meta storage meta = metainfo[pid];
        meta.name = _name;
        meta.detail = _detail;
        meta.img = _img;
        meta.left = _left;
        meta.payrate = _rate;
        meta.price = _price *1e18; //cya기준 제품가격
        pid += 1 ;
    }

  

    function buy(uint _pid,uint _num) public {  //1일 기준
        uint pay = metainfo[_pid].price * _num;
        require(metainfo[_pid].left >= _num, "Not for sale");
        require(hutbank.getlevel(msg.sender) >= 1, "No membership level");
        require(g2(msg.sender) >= pay, "cya not enough");  
        hutbank.expup(msg.sender, pay / 1e16);
        cya.approve(msg.sender, pay); 
        uint256 allowance = cya.allowance(msg.sender, address(this));
        require(allowance >= pay, "Check the token allowance");
        cya.transferFrom(msg.sender, address(this), pay); 
        address mymento =  hutbank.getmento(msg.sender);
        mydepo[mymento] += pay * metainfo[_pid].payrate /100;
        buyer storage bs = bs[bid];
        bs.oder = _num;
        bs.pid = _pid;
        bs.owner = msg.sender;
        bs.pay = pay;
        bs.dv = 1;
        metainfo[_pid].left -= _num;  //재고량
        bid +=1;
    }


    
     function refund(uint _bid) public onlyStaff(5) {  //환불
        uint pay = bs[_bid].pay;
        metainfo[bs[_bid].pid].left +=  bs[_bid].oder;
        bs[_bid].dv = 4;
    }


     function depowithdraw() public {  //수당 포인트 전환
          uint pay = mydepo[msg.sender];
          address mymento = hutbank.getmento(msg.sender);
          require(pay >= 1e18, "No allowance");
          mydepo[msg.sender] = 0;
          hutbank.depoup(msg.sender,pay);
          mydepo[mymento] += pay/2;
          

    }

    

    function g1() public view virtual returns (uint256) {  
        return cya.balanceOf(address(this));
    }

    function g2(address user) public view virtual returns (uint256) {  
        return cya.balanceOf(user);
    }


}

