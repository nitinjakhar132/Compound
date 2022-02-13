//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.3;

import "hardhat/console.sol";
import "./Interface.sol";

contract Compound {

    address comptroller_address = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;
    address pricefeed_address = 0x922018674c12a7F0D394ebEEf9B58F186CdE13c1;
    uint ctokenbalance = 0;

    event DepositDone(address, uint);
    event WithDrawDone(uint);
    event BorrowDone(address, uint);
    event PayBackDone(uint);

    function Deposit(
        uint _amount,
        address _ctoken,
        address _token
    ) external {
        CErc20 ctoken = CErc20(_ctoken);
        IERC20 token = IERC20(_token);
        token.transferFrom(msg.sender, address(this), _amount);
        token.approve(_ctoken, _amount);
        uint before_ctoken_balance = ctoken.balanceOf(address(this));
        require(ctoken.mint(_amount) == 0, "Mint Failed");
        uint after_ctoken_balance = ctoken.balanceOf(address(this));
        ctokenbalance = after_ctoken_balance - before_ctoken_balance;
        emit DepositDone(msg.sender,_amount);
    }

    function WithDraw(
        address _ctoken,
        address _token,
        uint ctoken_amount
    ) external {
        CErc20 ctoken = CErc20(_ctoken);
        IERC20 token = IERC20(_token);

        require(ctokenbalance >= ctoken_amount, "Choose Lower Amount Value!");
        require(ctoken.approve(_ctoken, ctoken_amount), "Approve Failed!");
        token.transfer(msg.sender, token.balanceOf(address(this)));
        emit WithDrawDone(ctoken_amount);
    }

    function Borrow(
        address _tokenToBorrow,
        address _cTokenToBorrow,
        uint _decimals,
        uint _amount,
        address[] memory cTokens
    ) external {
        CErc20 cToken = CErc20(_cTokenToBorrow);
        IERC20 token = IERC20(_tokenToBorrow);
        PriceFeed price1 = PriceFeed(pricefeed_address);
        Comptroller comp = Comptroller(comptroller_address);
        uint[] memory errors = comp.enterMarkets(cTokens);
        
        for (uint i = 0; i < errors.length; i++) {
            require(errors[i] == 0, "Comptroller EnterMarkets Fails!");
        }
        
        (, uint liquidity , )= comp.getAccountLiquidity(address(this));

        uint price = price1.getUnderlyingPrice(_cTokenToBorrow);
        uint maxBorrow = (liquidity * (10**_decimals)) / price;

        require(maxBorrow > _amount, "Can't Borrow This Much!");

        cToken.transfer(msg.sender,_amount);

        require(cToken.borrow(_amount) == 0, "Borrow Failed");
        emit BorrowDone(_cTokenToBorrow, _amount);
    }

    function PayBack(
        address _tokenBorrowed,
        address _cTokenBorrowed,
        uint _amount
    ) external {
        IERC20 token = IERC20(_tokenBorrowed);
        CErc20 cToken = CErc20(_cTokenBorrowed);

        token.approve(_cTokenBorrowed, _amount);

        token.transferFrom(msg.sender, address(this), _amount);

        token.transfer(_cTokenBorrowed, _amount);

        require(cToken.repayBorrow(_amount) == 0, "PayBack Failed!");
        emit PayBackDone(_amount);
    }

    receive()external payable{}
}