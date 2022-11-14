import { Injectable, Logger } from '@nestjs/common';
import { SDKRequestDto } from 'src/@core/common/dto/sdk-request.dto';
import { INVOKE_CHAINCODE_CONSTANT } from 'src/@core/common/constants/invoke-chaincode.constant';
import { CHANNEL_CONSTANT } from 'src/@core/common/constants/channel.constant';
import { ProposalRequestDto } from '../dto/proposal-request.dto';
import { TransactionRequestDto } from '../dto/transaction-request.dto';
import { BcUserService } from '../bc-user/bc-user.service';
import Client from 'fabric-client';
import { SDKResponseDto } from 'src/@core/common/dto/sdk-response.dto';
import { ChaincodeResponseDto } from 'src/@core/common/dto/chaincode-response.dto';
import { HandleChaincodeException } from 'src/@core/common/exceptions/chaincode-exceptions';

@Injectable()
export class BcInvokeService {
  constructor(private readonly bcUserService: BcUserService) {}

  /**
   * Calls Invoke Function on the blockchain chaincode  Invoke Blockchain chaincode
   *
   *
   * @param {SDKRequestDto} sdkRequest - Object of SDKRequestDto
   * @param {string} loggedInUserId - Logged In User Id
   * @returns {Promise<SDKResponseDto>} - Returns Promise of SDKResponseDto
   *
   *
   **/
  async invokeChaincode(
    sdkRequest: SDKRequestDto,
    key: string,
    orgName: string,
    salt: string,
  ): Promise<SDKResponseDto> {
    const logger = new Logger('InvokeChaincode');
    const peerNames = JSON.parse(process.env.PEER_NAMES);
    const client = await this.bcUserService.getClientInfoForOrg(
      orgName,
      key,
      salt,
    );
    const channel = await client.getChannel(sdkRequest.channelName);
    if (!channel) {
      logger.error(
        'Channel ' +
          sdkRequest.channelName +
          ' was not defined in the connection profile',
      );
      throw new Error(CHANNEL_CONSTANT.CHANNEL_NOT_FOUND);
    }

    // Generate new Transaction ID
    const txId = await client.newTransactionID();

    const proposalRequest = new ProposalRequestDto();
    proposalRequest.targets = peerNames;
    proposalRequest.chaincodeId = sdkRequest.chaincodeName;
    proposalRequest.fcn = sdkRequest.functionName;
    proposalRequest.args = sdkRequest.args;
    proposalRequest.chainId = sdkRequest.channelName;
    proposalRequest.txId = txId;

    // Calls send proposal function that sends the transaction proposal to the peer
    const sendProposalResponse = await this.sendProposal(
      channel,
      proposalRequest,
    );

    const proposalResponses =
      sendProposalResponse[0] as Client.ProposalResponse[];
    const proposal: Client.Proposal = sendProposalResponse[1];

    const transactionRequestDto = new TransactionRequestDto();
    transactionRequestDto.txId = txId;
    transactionRequestDto.proposalResponses = proposalResponses;
    transactionRequestDto.proposal = proposal;

    // Calls send transaction function that sends the endorsed transaction to the orderer
    await this.sendTransaction(channel, transactionRequestDto);

    return this.buildSDKResponseDto(sdkRequest, orgName);
  }

  /**
   * Send Proposal function that sends transaction proposal to the peer
   *
   *
   * @param {Client.Channel} channel - Channel Definition
   * @param {ProposalRequestDto} proposalRequestDto - Dto of Proposal Request
   * @returns {Promise<Client.ProposalResponseObject>} - Returns Promise of ProposalResponseObject
   *
   *
   **/
  private async sendProposal(
    channel: Client.Channel,
    proposalRequestDto: ProposalRequestDto,
  ): Promise<Client.ProposalResponseObject> {
    const logger = new Logger('SendProposal');
    const results = await channel.sendTransactionProposal(proposalRequestDto);

    // the returned object has both the endorsement results
    // and the actual proposal, the proposal will be needed
    // later when we send a transaction to the orderer
    const proposalResponses = results[0];
    for (const i in proposalResponses) {
      if (proposalResponses[i] instanceof Error) {
        const responsePayloadString = proposalResponses[i].toString();
        if (responsePayloadString.includes('statusCode')) {
          const responseError = responsePayloadString.split('{');
          const errorMessage = '{' + responseError[1];
          const responseErrorToChaincode: ChaincodeResponseDto =
            JSON.parse(errorMessage);
          logger.error(responseError);
          await HandleChaincodeException(responseErrorToChaincode);
        }
        logger.error(responsePayloadString);
        throw new Error(responsePayloadString);
      } else if (
        // true
        (proposalResponses[i] as Client.ProposalResponse).response &&
        (proposalResponses[i] as Client.ProposalResponse).response.status == 200
      ) {
        logger.log(INVOKE_CHAINCODE_CONSTANT.PROPOSAL_SUCCESS);
        return results;
      } else {
        logger.error(
          INVOKE_CHAINCODE_CONSTANT.PROPOSAL_FAILED,
          proposalResponses[i],
        );
        throw new Error(INVOKE_CHAINCODE_CONSTANT.PROPOSAL_FAILED);
      }
    }
  }

  /**
   * Send Transaction function that sends endorsed transaction to the orderer
   *
   *
   * @param {Client.Channel} channel - Channel Definition
   * @param {TransactionRequestDto} transactionRequestDto - Dto of Transaction Request
   * @returns {Promise<Client.BroadcastResponse>} - Returns Promise of Client.BroadcastResponse
   *
   *
   **/
  private async sendTransaction(
    channel: Client.Channel,
    transactionRequestDto: TransactionRequestDto,
  ): Promise<Client.BroadcastResponse> {
    const logger = new Logger('SendTransaction');
    const transactionResponse = await channel.sendTransaction(
      transactionRequestDto,
    );

    if (transactionResponse.status != 'SUCCESS') {
      logger.error(
        INVOKE_CHAINCODE_CONSTANT.TRANSACTION_FAILURE +
          transactionResponse.status,
      );
      throw new Error(INVOKE_CHAINCODE_CONSTANT.TRANSACTION_FAILURE);
    }
    return transactionResponse;
  }

  private buildSDKResponseDto(
    sDKRequestDto: SDKRequestDto,
    orgName: string,
  ): SDKResponseDto {
    const sDKResponseDto: SDKResponseDto = {
      channelName: sDKRequestDto.channelName,
      chaincodeName: sDKRequestDto.chaincodeName,
      functionName: sDKRequestDto.functionName,
      args: sDKRequestDto.args,
      orgName: orgName,
    };
    return sDKResponseDto;
  }
}
