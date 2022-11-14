import { Injectable, Logger } from '@nestjs/common';
import { CHANNEL_CONSTANT } from 'src/@core/common/constants/channel.constant';
import { ChaincodeResponseDto } from 'src/@core/common/dto/chaincode-response.dto';
import { SDKRequestDto } from 'src/@core/common/dto/sdk-request.dto';
import { SDKResponseDto } from 'src/@core/common/dto/sdk-response.dto';
import { HandleChaincodeException } from 'src/@core/common/exceptions/chaincode-exceptions';
import { BcUserService } from '../bc-user/bc-user.service';
import { ProposalRequestDto } from '../dto/proposal-request.dto';

@Injectable()
export class BcQueryService {
  constructor(private readonly bcUserService: BcUserService) {}

  async queryChaincode(
    sdkRequest: SDKRequestDto,
    key: string,
    orgName: string,
    salt: string,
  ): Promise<SDKResponseDto> {
    await new Promise((r) => setTimeout(r, 2000));
    const logger = new Logger('QueryChaincode');
    const peerNames = JSON.parse(process.env.PEER_NAMES);
    const client = await this.bcUserService.getClientInfoForOrg(
      orgName,
      key,
      salt,
    );
    const channel = client.getChannel(sdkRequest.channelName);
    if (!channel) {
      logger.error(
        'Channel ' +
          sdkRequest.channelName +
          ' was not defined in the connection profile',
      );
      throw new Error(CHANNEL_CONSTANT.CHANNEL_NOT_FOUND);
    }

    const proposalRequestDto = new ProposalRequestDto();
    proposalRequestDto.targets = peerNames;
    proposalRequestDto.chaincodeId = sdkRequest.chaincodeName;
    proposalRequestDto.fcn = sdkRequest.functionName;
    proposalRequestDto.args = sdkRequest.args;
    const responsePayload = await channel.queryByChaincode(proposalRequestDto);
    if (
      responsePayload &&
      responsePayload[0] &&
      responsePayload[0].toString()
    ) {
      if (responsePayload[0] instanceof Error) {
        const responsePayloadString = responsePayload[0].toString();
        if (responsePayloadString.includes('statusCode')) {
          const responseError = responsePayloadString.split('{');
          const errorMessage = '{' + responseError[1];
          const responseErrorToChaincode: ChaincodeResponseDto =
            JSON.parse(errorMessage);
          logger.error(responseError);
          await HandleChaincodeException(responseErrorToChaincode);
        }
        throw new Error(responsePayloadString);
      }
      const responseBuffer = responsePayload[0].toString();
      const response: ChaincodeResponseDto = JSON.parse(responseBuffer);
      sdkRequest.args = response.result;
      return this.buildSDKResponseDto(sdkRequest, orgName);
    } else {
      logger.error('Response payload is null');
      throw new Error('Response payload is null');
    }
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
