// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Interface is taken from https://medium.com/compound-finance/borrowing-assets-from-compound-quick-start-guide-f5e69af4b8f4

interface CErc20 is IERC20 {
    function balanceOf(address) external view override returns (uint256);

    function mint(uint256) external returns (uint256);

    function exchangeRateCurrent() external returns (uint256);

    function supplyRatePerBlock() external returns (uint256);

    function balanceOfUnderlying(address) external returns (uint256);

    function redeem(uint256) external returns (uint256);

    function redeemUnderlying(uint256) external returns (uint256);

    function borrow(uint256) external returns (uint256);

    function borrowBalanceCurrent(address) external returns (uint256);

    function borrowRatePerBlock() external view returns (uint256);

    function repayBorrow(uint256) external returns (uint256);

    function liquidateBorrow(
        address borrower,
        uint256 amount,
        address collateral
    ) external returns (uint256);
}

interface Comptroller {
    function markets(address)
        external
        view
        returns (
            bool,
            uint256,
            bool
        );

    function enterMarkets(address[] calldata)
        external
        returns (uint256[] memory);

    function getAccountLiquidity(address)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function closeFactorMantissa() external view returns (uint256);

    function liquidationIncentiveMantissa() external view returns (uint256);

    function liquidateCalculateSeizeTokens(
        address cTokenBorrowed,
        address cTokenCollateral,
        uint256 actualRepayAmount
    ) external view returns (uint256, uint256);
}

interface PriceFeed {
    function getUnderlyingPrice(address cToken) external view returns (uint256);
}
