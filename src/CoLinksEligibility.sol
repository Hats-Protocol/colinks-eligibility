// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

// import { console2 } from "forge-std/Test.sol"; // comment out before deploy
import { HatsEligibilityModule } from "hats-module/src/HatsEligibilityModule.sol";
import { HatsModule } from "lib/hats-module/src/HatsModule.sol";
import { CoLinksLike } from "./lib/CoLinksLike.sol";

contract CoLinksEligibility is HatsEligibilityModule {
  /*//////////////////////////////////////////////////////////////
                            CONSTANTS 
  //////////////////////////////////////////////////////////////*/

  /**
   * This contract is a clone with immutable args, which means that it is deployed with a set of
   * immutable storage variables (ie constants). Accessing these constants is cheaper than accessing
   * regular storage variables (such as those set on initialization of a typical EIP-1167 clone),
   * but requires a slightly different approach since they are read from calldata instead of storage.
   *
   * Below is a table of constants and their location.
   *
   * For more, see here: https://github.com/Saw-mon-and-Natalie/clones-with-immutable-args
   *
   * ----------------------------------------------------------------------+
   * CLONE IMMUTABLE "STORAGE"                                             |
   * ----------------------------------------------------------------------|
   * Offset  | Constant          | Type        | Length  | Source          |
   * ----------------------------------------------------------------------|
   * 0       | IMPLEMENTATION    | address     | 20      | HatsModule      |
   * 20      | HATS              | address     | 20      | HatsModule      |
   * 40      | hatId             | uint256     | 32      | HatsModule      |
   * 72      | COLINKS           | CoLinksLike | 20      | this            |
   * 92      | THRESHOLD         | uint256     | 32      | this            |
   * ----------------------------------------------------------------------+
   */

  function COLINKS() public pure returns (CoLinksLike) {
    return CoLinksLike(_getArgAddress(72));
  }

  function THRESHOLD() public pure returns (uint256) {
    return _getArgUint256(92);
  }

  /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
  //////////////////////////////////////////////////////////////*/

  /// @notice Deploy the implementation contract and set its version
  /// @dev This is only used to deploy the implementation contract, and should not be used to deploy clones
  constructor(string memory _version) HatsModule(_version) { }

  /*//////////////////////////////////////////////////////////////
                            INITIALIZER
  //////////////////////////////////////////////////////////////*/

  /// @inheritdoc HatsModule
  function _setUp(bytes calldata _initData) internal override {
    // decode init data
  }

  /*//////////////////////////////////////////////////////////////
                    HATS ELIGIBILITY FUNCTION
  //////////////////////////////////////////////////////////////*/

  /// @inheritdoc HatsEligibilityModule
  function getWearerStatus(address _wearer, uint256 /* _hatId */ )
    public
    view
    virtual
    override
    returns (bool eligible, bool standing)
  {
    // this module only checks eligibility, not standing
    standing = true;

    eligible = COLINKS().linkSupply(_wearer) >= THRESHOLD();
  }
}
