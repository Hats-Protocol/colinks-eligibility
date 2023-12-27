# CoLinks Eligibility

CoLinksEligibility is a [Hats Protocol](https://github.com/Hats-Protocol/hats-protocol) eligibility module that sets eligibility for a target hat based on the supply of a user's (aka "wearer's") [CoLinks](https://github.com/coordinape/coordinape-protocol/blob/main/contracts/colinks/CoLinks.sol) links.

Since the supply of a user's links is a fuzzy-yet-credible signal of their reputation within the Coordinape and CoLinks ecosystem, this module can be used to help ensure that wearers of a given hat meet minimum reputation requirements. Similarly, it can also be used as a Sybil-resistance mechanism for the hat.

## Usage

This module inherits from [HatsModule](https://github.com/Hats-Protocol/hats-module), which means that it is designed to be used by deploying a new instance (i.e. a minimal proxy clone) via the [HatsModuleFactory](https://github.com/Hats-Protocol/hats-module/blob/main/src/HatsModuleFactory.sol) and then attached to the target hat.

The module can be configured with a single parameter `threshold`, which is the minimum number of links that a wearer must have in order to be eligible for the hat. The module will then set the wearer's eligibility to `true` if they have at least `threshold` links, and `false` otherwise.

This module does not deal with the `standing` portion of Hats eligibility, so `standing` is always set to `true` for the wearer. However, this module can be [chained together](https://docs.hatsprotocol.xyz/for-developers/hats-modules/building-hats-modules/about-module-chains) with another eligibility module that does deal with `standing`.

## Development

This repo uses Foundry for development and testing. To get started:

1. Fork the project
2. Install [Foundry](https://book.getfoundry.sh/getting-started/installation)
3. To install dependencies, run `forge install`
4. To compile the contracts, run `forge build`
5. To test, run `forge test`
