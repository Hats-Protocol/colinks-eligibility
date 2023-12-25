// SPDX-License-Identifier: None
pragma solidity ^0.8.2;

interface CoLinksLike {
  function linkSupply(address linkTarget) external view returns (uint256);

  function getBuyPriceAfterFee(address linkTarget, uint256 amount) external view returns (uint256);

  function buyLinks(address linkTarget, uint256 amount) external payable;
}
