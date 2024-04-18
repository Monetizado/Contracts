// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MonetizadoLibrary.sol";

contract Monetizadov1 {
    
    // Struct with info about the protected content (for paying to access)
    struct ProtectedContentInfo {
        string name;
        uint256 accessCost;
        bool isProtected;
        uint256 sequenceId;
        address creator;
        uint256 amountAvailable;
        uint256 amountCollected;
    }


    mapping(address => bool) private creators;
    mapping(address => bool) public hosting;

    mapping(address => MonetizadoLibrary.ProtectedContent[]) private paginasProtegidas;

    event GrantedAccess(address usuario, address creator, uint256 sequenceId);

    address private _owner;
    uint256 private _platformFeePercentage;
    uint256 private _platformBalance;

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only the owner can call this function");
        _;
    }

    constructor() {
        _owner = msg.sender;
        _platformFeePercentage = 0;
        _platformBalance = 0;
    }


    function addProtectedContent(string memory name, uint256 accessCost) public returns (uint256) {
        
        uint256 cantidadPaginasCreador = paginasProtegidas[msg.sender].length;
        MonetizadoLibrary.ProtectedContent[] storage paginas = paginasProtegidas[msg.sender];
        MonetizadoLibrary.ProtectedContent storage pagina = paginas.push();
        pagina.name = name;
        pagina.accessCost = accessCost;
        pagina.isProtected = true;
        pagina.sequenceId = cantidadPaginasCreador;
        pagina.creator = msg.sender;
        pagina.amountCollected = 0;
        pagina.amountAvailable = 0;

        creators[msg.sender] = true;

        return cantidadPaginasCreador;
    }

    function getProtectedContentsForCurrentUser() public view returns (ProtectedContentInfo[] memory) {
        uint256 cantidadPaginasPorCreador = paginasProtegidas[msg.sender].length;
        ProtectedContentInfo[] memory paginas = new ProtectedContentInfo[](cantidadPaginasPorCreador);

        for (uint256 i = 0; i < cantidadPaginasPorCreador; i++) {
            MonetizadoLibrary.ProtectedContent storage pagina = paginasProtegidas[msg.sender][i];
            paginas[i] = ProtectedContentInfo(pagina.name, pagina.accessCost, pagina.isProtected, pagina.sequenceId, pagina.creator, pagina.amountAvailable, pagina.amountCollected);
        }

        return paginas;
    }

    function getProtectedContentByAddressAndId(address creator, uint256 sequenceId) public view returns (ProtectedContentInfo memory) {
        MonetizadoLibrary.ProtectedContent storage pagina = paginasProtegidas[creator][sequenceId];
        ProtectedContentInfo memory paginas = ProtectedContentInfo(pagina.name, pagina.accessCost, pagina.isProtected, pagina.sequenceId, pagina.creator, pagina.amountAvailable, pagina.amountCollected);
        return paginas;
    }

    function payAccess(address creator, uint256 sequenceId) external payable {

        MonetizadoLibrary.ProtectedContent storage pagina = paginasProtegidas[creator][sequenceId];
        require(msg.value == pagina.accessCost, "Incorrect payment amount");
        require(pagina.isProtected == true, "The page is not protected and you do not need to pay access");

        MonetizadoLibrary.Subscriber storage subscriber = pagina.subscribers[msg.sender];
        subscriber.paid = true;
        subscriber.amount = msg.value;
        pagina.amountCollected += msg.value;
        pagina.amountAvailable += msg.value;
        emit GrantedAccess(msg.sender, creator, sequenceId);
    }

    function currentUserHasAccess(address creator, uint256 sequenceId) public view returns(bool) {
        MonetizadoLibrary.ProtectedContent storage pagina = paginasProtegidas[creator][sequenceId];
        return pagina.subscribers[msg.sender].paid;
    }

    function changeAccessCost(uint256 sequenceId, uint256 newCost) external {
        MonetizadoLibrary.ProtectedContent storage pagina = paginasProtegidas[msg.sender][sequenceId];
        pagina.accessCost = newCost;
    }

    function unprotectContent(uint256 sequenceId) external {
        MonetizadoLibrary.ProtectedContent storage pagina = paginasProtegidas[msg.sender][sequenceId];
        pagina.isProtected = false;
    }

    function protectContent(uint256 sequenceId) external {
        MonetizadoLibrary.ProtectedContent storage pagina = paginasProtegidas[msg.sender][sequenceId];
        pagina.isProtected = true;
    }

    function changePlatformFee(uint256 feePlatform) external onlyOwner {
        require(feePlatform <= 100, "The fee should be between 0.01 to 1% (1 - 100 in a 10000 scale)");
        _platformFeePercentage = feePlatform;
    }

    function withdrawMoneyFromContent(uint256 sequenceId,uint256 amount) external {
        MonetizadoLibrary.ProtectedContent storage pagina = paginasProtegidas[msg.sender][sequenceId];
        require(pagina.amountAvailable >= amount, "Insufficient balance");
        uint256 amountForPlatform = amount * _platformFeePercentage / 10000;
        _platformBalance += amountForPlatform;
        payable(_owner).transfer(amountForPlatform);
        payable(msg.sender).transfer(amount - amountForPlatform);
        pagina.amountAvailable -= amount;
    }

    function getPlatformFee() public view returns(uint256) {
        return _platformFeePercentage;
    }

    function getPlatformBalance() public view returns(uint256) {
        return _platformBalance;
    }

    function withdrawMoneyPlatform(uint256 amount) external onlyOwner {
        require(_platformBalance >= amount, "Insufficient balance");
        payable(msg.sender).transfer(amount);
        _platformBalance -= amount;
    }


    // function obtenerAccesos(string hashPagina) external view returns (string[] memory) {
    //     uint256 totalAccesos = 0;
    //     for (uint256 i = 0; i < paginasProtegidas[hashPagina].pagadores.length; i++) {
    //         if (paginasProtegidas[hashPagina].pagadores[i]) {
    //             totalAccesos++;
    //         }
    //     }

    //     string[] memory accesos = new bytes32[](totalAccesos);
    //     uint256 index = 0;
    //     for (uint256 i = 0; i < paginasProtegidas[hashPagina].pagadores.length; i++) {
    //         if (paginasProtegidas[hashPagina].pagadores[i]) {
    //             accesos[index] = i;
    //             index++;
    //         }
    //     }

    //     return accesos;
    // }
}
