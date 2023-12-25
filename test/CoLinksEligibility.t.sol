// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Test, console2 } from "forge-std/Test.sol";
import { CoLinksEligibility } from "../src/CoLinksEligibility.sol";
import { CoLinksLike } from "../src/lib/CoLinksLike.sol";
import { DeployImplementation, DeployInstance } from "../script/Deploy.s.sol";
import { HatsModule } from "lib/hats-module/src/HatsModule.sol";
import { IHats } from "lib/hats-module/src/HatsModule.sol";

contract ModuleTest is DeployImplementation, Test {
  /// @dev Inherit from DeployPrecompiled instead of Deploy if working with pre-compiled contracts

  /// @dev variables inhereted from DeployImplementation script
  // CoLinksEligibility public implementation;
  // bytes32 public SALT;

  uint256 public fork;
  uint256 public BLOCK_NUMBER = 113_965_243;
  IHats public HATS = IHats(0x3bc1A0Ad72417f2d411118085256fC53CBdDd137); // v1.hatsprotocol.eth
  CoLinksEligibility public instance;
  CoLinksLike public COLINKS = CoLinksLike(0x7154cA7E4C756E06151aefA2D765404950FA0EE1);
  DeployInstance public deployInstance;
  uint256 public threshold;
  uint256 public targetHat = 1;

  string public MODULE_VERSION;

  function _deployInstance(uint256 _threshold) internal returns (CoLinksEligibility) {
    deployInstance.prepare(false, targetHat, address(implementation), _threshold);
    return CoLinksEligibility(deployInstance.run());
  }

  function setUp() public virtual {
    // create and activate a fork, at BLOCK_NUMBER
    fork = vm.createSelectFork(vm.rpcUrl("optimism"), BLOCK_NUMBER);

    // deploy DeployInstance script
    deployInstance = new DeployInstance();

    // deploy implementation via the script
    prepare(false, MODULE_VERSION);
    run();
  }
}

contract WithInstanceTest is ModuleTest {
  function setUp() public virtual override {
    super.setUp();

    threshold = 10;

    instance = _deployInstance(threshold);
  }
}

contract Deployment is WithInstanceTest {
  /// @dev ensure that both the implementation and instance are properly initialized
  function test_initialization() public {
    // implementation
    vm.expectRevert("Initializable: contract is already initialized");
    implementation.setUp("setUp attempt");
    // instance
    vm.expectRevert("Initializable: contract is already initialized");
    instance.setUp("setUp attempt");
  }

  function test_version() public {
    assertEq(instance.version(), MODULE_VERSION);
  }

  function test_implementation() public {
    assertEq(address(instance.IMPLEMENTATION()), address(implementation));
  }

  function test_hats() public {
    assertEq(address(instance.HATS()), address(HATS));
  }

  function test_hatId() public {
    assertEq(instance.hatId(), targetHat);
  }

  function test_coLinks() public {
    assertEq(address(instance.COLINKS()), address(COLINKS));
  }

  function test_threshold() public {
    assertEq(instance.THRESHOLD(), threshold);
  }
}

contract UnitTests is ModuleTest {
  address buyer = makeAddr("buyer");
  address target = makeAddr("target");

  function _buyLinks(address _target, address _buyer, uint256 _amount) internal {
    // find the price
    uint256 price = COLINKS.getBuyPriceAfterFee(_target, _amount);
    console2.log("price", price);
    // bankroll the buyer
    vm.deal(_buyer, price);
    // buy the links
    vm.prank(_buyer);
    COLINKS.buyLinks{ value: price }(_target, _amount);
  }

  function setUp() public virtual override {
    super.setUp();

    // target initiates a link
    _buyLinks(target, target, 1);
  }

  function test_getWearerStatus(uint256 _supply, uint256 _threshold) public {
    _supply = bound(_supply, 1, 1000);
    _threshold = bound(_threshold, 1, type(uint256).max);

    instance = _deployInstance(_threshold);

    // buy _supply - 1 links so that supply == _supply
    assertEq(COLINKS.linkSupply(target), 1, "target's link not initiated");
    console2.log("_supply", _supply);
    if (_supply > 1) {
      _buyLinks(target, buyer, _supply - 1);
    }
    assertEq(COLINKS.linkSupply(target), _supply, "unexpected supply");

    // get wearer status
    (bool eligible, bool standing) = instance.getWearerStatus(target, targetHat);

    // check eligibility
    assertEq(eligible, _supply >= _threshold);
    // standing should always be true
    assertTrue(standing);
  }

  function test_true_supplyGreaterThanThreshold() public {
    test_getWearerStatus(6, 5);
  }

  function test_true_supplyEqualsThreshold() public {
    test_getWearerStatus(5, 5);
  }

  function test_false_supplyLessThanThreshold() public {
    test_getWearerStatus(4, 5);
  }
}
