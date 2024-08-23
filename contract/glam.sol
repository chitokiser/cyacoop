// SPDX-License-Identifier: MIT  
// ver1.2
pragma solidity >=0.7.0 <0.9.0;

interface Ihut {
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

contract glam { //글램핑
    Ihut hut;
    Ihutbank hutbank;
    address public admin; 
    address public taxbank;
    uint256 public mid; 
    uint256 public time; 
    uint256 public tax; // 매출

  
    mapping(address => uint8) public staff;
    mapping(uint256 => Meta) public metainfo; // id별 계좌정보
   
   

      
    constructor(address _hut, address _taxbank, address _hutbank) {
        hut = Ihut(_hut);
        hutbank = Ihutbank(_hutbank);
        admin = msg.sender;
        staff[msg.sender] = 5;
        taxbank = _taxbank;
        time = 365 days;
    }

    struct Meta {
        string name; // 물건이름
        string location; // 물건 위치 주소
        string detail; // 물건 정보 상세페이지
        string img; // 물건 사진
        uint256 start; // 시작 시간
        uint256 depo; // hut기준 전세금
        uint8 trade; // 거래가능성 (3: 거래가능, 2: 준비중, 1: 사용중)
        address user; // 사용자
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

      function timeup(uint _time) public onlyStaff(5) {   
        time = _time*1 days;
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

        function priceup(uint256 _mid,uint256 _depo) public onlyStaff(5) {   
        metainfo[_mid].depo = _depo ;
    } 




    function taxbankup(address _taxbank) public onlyStaff(5) {   
        taxbank = _taxbank;
    } 

    
    function newMeta(string memory _name, string memory _location, string memory _detail, string memory _img, uint256 _depo) public onlyStaff(5) {
      
        Meta storage meta = metainfo[mid];
        meta.name = _name;
        meta.location = _location;
        meta.detail = _detail;
        meta.img = _img;
        meta.depo = _depo; //hut기준 전세금
        meta.user = taxbank;
        meta.trade = 3; // 3이면 거래 가능
        mid += 1 ;
    }

  

    function buyhouse(uint _mid) public {  //1일 기준
        uint pay = metainfo[_mid].depo;
        require(metainfo[_mid].trade == 3, "Not for sale");
        require(hutbank.getlevel(msg.sender) >= 1, "No membership level");
        require(g2(msg.sender) >= pay, "hut not enough");  
        hutbank.expup(msg.sender, pay / 1e16);
        hut.approve(msg.sender, pay); 
        uint256 allowance = hut.allowance(msg.sender, address(this));
        require(allowance >= pay, "Check the token allowance");
        hut.transferFrom(msg.sender, address(this), pay);  
        metainfo[_mid].trade = 1; // 물건 사용 중
        metainfo[_mid].user = msg.sender;
        metainfo[_mid].start = block.timestamp;  
    }


    function termination(uint _mid) public {  //계약종료
        uint pay = (metainfo[_mid].depo);
        require(metainfo[_mid].user == msg.sender, "no owner");
        require(metainfo[_mid].start + time < block.timestamp, "Contract period remains");
        require(g1() >= pay, "hut not enough");  
        hut.transfer(msg.sender,pay); 
        metainfo[_mid].trade = 3; // 물건 사용 가능
        metainfo[_mid].user = taxbank;
        metainfo[_mid].start = 0;  
    }

 
    

    function stopUsingStaff(uint _mid) public onlyStaff(5) {
    
        metainfo[_mid].trade = 3;  // 거래가능 상태 변경
        metainfo[_mid].user = address(0);
    }


   

    function g1() public view virtual returns (uint256) {  
        return hut.balanceOf(address(this));
    }

    function g2(address user) public view virtual returns (uint256) {  
        return hut.balanceOf(user);
    }

    function g3(uint _mid) public view virtual returns (uint256) { // 사용료 1시간당 산출
        return metainfo[_mid].depo;
    }

      function g4(uint _mid) public view virtual returns (uint256) { //서비스 남은시간 보기
        return(metainfo[_mid].start + time)  - block.timestamp ;
    }

  

    function getLevel(address user) external view returns (uint) {
        return hutbank.getlevel(user);
    }

}
