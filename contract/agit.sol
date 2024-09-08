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

interface Icrut {
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
    function g9(address user) external view returns (uint); // 각 depo현황
    function getmento(address user) external view returns (address);
    function expup(address _user, uint _exp) external;
}


contract agit { 
    Icrut crut;
    Icya cya;
    Icutbank cutbank;

    address public admin; 
    address public taxbank;
    uint256 public mid;  
    uint256 public time; 
    uint256 public tax; // 매출
    uint8 public commission; //커미션
  
    mapping(address => uint8) public staff;
    mapping(uint256 => Meta) public metainfo; // id별 계좌정보
   
   

      
    constructor(address _crut,address _cya,address _cutbank,address _crutbank) {
        crut = Icrut(_crut);
        cya = Icya(_cya);
        cutbank = Icutbank(_cutbank);

        admin = msg.sender;
        staff[msg.sender] = 5;
        taxbank = _crutbank;
        time = 365 days;
        commission = 20;
    }

    struct Meta {  //아지트
        string name; // 물건이름
        string location; // 물건 위치 주소
        string detail; // 물건 정보 상세페이지
        string img; // 물건 사진
        uint256 depo; // crut기준 임대 보증금
        uint256 wdepo; // crut인출금액
        uint8 trade; // 거래가능성 4:해지신청 3: 임대가능, 2: 사용중, 1: 거래가능 0:준비중
        address user; // crut을 이 계약에 지불하면 즉시 임대성사
        address owner; //실제오너
        uint256 price; //매매가격 cya는 crut뱅크로 이체됨
        uint256 start; //임대 시작시간
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

      function timeup(uint _time) public onlyStaff(5) {   //초단위로 입력
        time = _time;
    } 


     function nameup(uint256 _mid,string memory _name) public onlyStaff(5) {   
        metainfo[_mid].name = _name;
    } 

  
       function locationup(uint256 _mid,string memory _location) public onlyStaff(5) {   
        metainfo[_mid].location = _location;
    } 
    
        function detailup(uint256 _mid,string memory _detail) public onlyStaff(5) {   
        metainfo[_mid].detail = _detail;
    } 

        function imagesup(uint256 _mid,string memory _img) public onlyStaff(5) {   
        metainfo[_mid].img = _img;
    } 
     

     
          function startup(uint256 _mid) public onlyStaff(5) {   
        metainfo[_mid].start = block.timestamp;
    } 

        function priceup(uint256 _mid,uint256 _price) public onlyStaff(5) {   
        metainfo[_mid].price = _price * 1e18 ;  //cya기준 매매가격 설정
    } 


        function depoup(uint256 _mid,uint256 _depo) public onlyStaff(5) {   
        metainfo[_mid].depo = _depo ;  //crut 기준 임대 보증금 설정
    } 

    function taxbankup(address _taxbank) public onlyStaff(5) {   
        taxbank = _taxbank;
    } 


  
    function commissionup(uint8 _commission) public onlyStaff(5) {   
        commission = _commission;
    } 
      
    function ownerpriceup(uint256 _mid,uint256 _price) public {   
        require(metainfo[_mid].owner == msg.sender, "no owner");
        require(metainfo[_mid].trade == 1, "Unchangeable price");

        metainfo[_mid].price = _price * 1e18 ;  //cya기준 매매가격 설정
    } 


   function ownerdepoup(uint256 _mid,uint256 _depo) public {   
        require(metainfo[_mid].owner == msg.sender, "no owner");
        require(metainfo[_mid].trade == 1, "Unchangeable depo");

        metainfo[_mid].depo = _depo ;  //보증금 변경
    } 


    function newMeta(string memory _name, string memory _location, string memory _detail, string memory _img, uint256 _depo,uint256 _price) public onlyStaff(5) {
      
        Meta storage meta = metainfo[mid];
        meta.name = _name;
        meta.location = _location;
        meta.detail = _detail;
        meta.img = _img;
        meta.depo = _depo; //crut 기준 임대료
        meta.user = taxbank;
        meta.trade = 1; // 거래가능성 4:해지신청 3: 임대가능, 2: 사용중, 1: 거래가능 0:준
        meta.owner = msg.sender;
        meta.price = _price *1e18;
        mid += 1 ;
    }


    function buy(uint _mid) public {  
        uint pay = metainfo[_mid].price;
        require(metainfo[_mid].trade == 1, "Not for sale");
        require(cutbank.getlevel(msg.sender) >= 1, "No membership level");
        require(g2(msg.sender) >= pay, "cya not enough");      
        cya.approve(msg.sender, pay); 
        uint256 allowance = cya.allowance(msg.sender, address(this));
        require(allowance >= pay, "Check the token allowance");
        cya.transferFrom(msg.sender, address(this), pay);     
        cya.transfer(metainfo[_mid].owner,pay);  
        cutbank.expup(msg.sender, pay / 1e18);
        address mento = cutbank.getmento(msg.sender);
        cutbank.depoup(mento,pay *commission/100);
        metainfo[_mid].owner = msg.sender;
        metainfo[_mid].user = msg.sender;
        metainfo[_mid].trade = 0;
    }


 
    
    function forrent(uint _mid) public {  //직접사용하지 않고 임대자 구함
        require(metainfo[_mid].trade == 0, "Cannot rent");
        require(metainfo[_mid].owner == msg.sender, "no owner");
        
        metainfo[_mid].trade = 3; // 거래가능성 4:해지신청 3: 임대가능, 2: 사용중, 1: 거래가능 0:준비중
 
    }
   

   function rent(uint _mid) public {  //임차인이 신청
        uint pay = (metainfo[_mid].depo);
         require(metainfo[_mid].trade == 3, "Cannot rent");
        require( g3(msg.sender) > pay, "no crut");
        crut.approve(msg.sender, pay); 
        uint256 allowance = crut.allowance(msg.sender, address(this));
        require(allowance >= pay, "Check the token allowance");
        crut.transferFrom(msg.sender, address(this), pay);                 //crut 이 계약에 스테이킹
        metainfo[_mid].trade = 2; // 거래가능성 4:해지신청 3: 임대가능, 2: 사용중, 1: 거래가능 0:준비중
        metainfo[_mid].user = msg.sender;
        metainfo[_mid].depo = 0 ;
        metainfo[_mid].wdepo = pay ;
        metainfo[_mid].start = block.timestamp; //임대시작
        crut.transfer(metainfo[_mid].owner,pay*99/100); //계약이 오너에게 임대보증금 지급  
    } 


    
    function cancell(uint _mid) public {  //오너가 crut을 임차인에게 지불하고 계약해지
        require(metainfo[_mid].trade == 2, "Not in use");
        require(metainfo[_mid].owner == msg.sender, "no owner");
        require(metainfo[_mid].wdepo <= g3(msg.sender), "no crut");
        require(metainfo[_mid].start >= metainfo[_mid].start+time, "Rental time remaining");
        uint pay =  metainfo[_mid].wdepo;
        crut.approve(msg.sender, pay); 
        uint256 allowance = crut.allowance(msg.sender, address(this));
        require(allowance >= pay, "Check the token allowance");
        crut.transferFrom(msg.sender, address(this), pay);   
        metainfo[_mid].depo = pay;
        crut.transfer(metainfo[_mid].user,pay); //임차인에게 임대보증금 지급                 
        metainfo[_mid].trade = 0; //4:해지신청 3: 임대가능, 2: 사용중, 1: 거래가능 0:준비중
        metainfo[_mid].user = metainfo[_mid].owner;
        metainfo[_mid].depo = metainfo[_mid].wdepo;
         metainfo[_mid].wdepo = 0;
    }


        
 
    

    function stopUsingStaff(uint _mid,uint8 _trade ) public onlyStaff(5) {
    
        metainfo[_mid].trade = _trade;  // 거래가능 상태 변경
      
    }


   

    function g1() public view virtual returns (uint256) {  
        return cya.balanceOf(address(this));
    }

    function g2(address user) public view virtual returns (uint256) {  
        return cya.balanceOf(user);
    }

        function g3(address user) public view virtual returns (uint256) {  
        return crut.balanceOf(user);
    }

       function g4() public view virtual returns (uint256) {  
          return crut.balanceOf(address(this));
    }

}
