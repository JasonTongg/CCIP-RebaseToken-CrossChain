// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Client} from "@ccip/contracts/src/v0.8/ccip/libraries/Client.sol";
import {IRouterClient} from "@ccip/contracts/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {IERC20} from "@ccip/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";

contract BridgeTokens {
    function bridgeTokens(
        uint256 amountToSend,
        address tokenToSendAddress,
        address receiverAddress,
        uint64 destinationChainSelector,
        address linkTokenAddress,
        address routerAddress
    ) external {
        Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](1);
        tokenAmounts[0] = Client.EVMTokenAmount({
            token: tokenToSendAddress,
            amount: amountToSend
        });

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(receiverAddress),
            data: "",
            tokenAmounts: tokenAmounts,
            feeToken: linkTokenAddress,
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 200_000})
            )
        });

        uint256 ccipFee = IRouterClient(routerAddress).getFee(destinationChainSelector, message);

        bool linkSuccess = IERC20(linkTokenAddress).transferFrom(
            msg.sender,
            address(this),
            ccipFee
        );

        require(linkSuccess, "LINK transferFrom failed - check allowance or balance");

        bool success = IERC20(tokenToSendAddress).transferFrom(
            msg.sender,
            address(this),
            amountToSend
        );

        require(success, "TransferFrom failed - check allowance or balance");

        IERC20(linkTokenAddress).approve(routerAddress, ccipFee);
        IERC20(tokenToSendAddress).approve(routerAddress, amountToSend);

        IRouterClient(routerAddress).ccipSend(destinationChainSelector, message);
    }
}
