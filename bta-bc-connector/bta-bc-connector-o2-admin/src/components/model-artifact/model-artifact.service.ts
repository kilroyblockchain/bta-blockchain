import { Injectable } from '@nestjs/common';
import { SDKRequestDto } from 'src/@core/common/dto/sdk-request.dto';
import { BcInvokeService } from '../blockchain/bc-invoke/bc-invoke.service';
import { BcQueryService } from '../blockchain/bc-query/bc-query.service';
import { GetModelArtifactDto } from './dto/get-model-artifact.dto';
import { ModelArtifactResponseDto } from './dto/model-artifact-response.dto';
import { StoreModelArtifactDto } from './dto/store-model-artifact.dto';

@Injectable()
export class ModelArtifactService {
  // Name of ModelArtifact Chaincode
  private readonly CHAINCODE_NAME = 'model-artifact';
  constructor(
    private readonly bcInvokeService: BcInvokeService,
    private readonly bcQueryService: BcQueryService,
  ) {}

  /**
   * Store Model Artifact Function calls 'StoreModelArtifact' chaincode functions on chaincode which creates new state if non and updates the existing state.
   *
   *
   * @param {StoreModelArtifactDto} storeModelArtifactDto - Object of StoreModelArtifactDto
   * @param {string} key - Key of the user to get the detail
   * @param {string} orgName - Name of the Organization to be used for transaction
   * @param {string} channelName - Name of the channel to send the transaction
   * @param {string} salt - Unique string associated with the key generated
   * @returns {Promise<ModelArtifactResponseDto>} - Returns Promise of ModelArtifactResponseDto
   *
   *
   **/
  async storeModelArtifact(
    storeModelArtifactDto: StoreModelArtifactDto,
    key: string,
    orgName: string,
    channelName: string,
    salt: string,
  ): Promise<ModelArtifactResponseDto> {
    const chaincodeFunctionName = 'StoreModelArtifact';

    const sDKRequestDto = new SDKRequestDto();
    sDKRequestDto.chaincodeName = this.CHAINCODE_NAME;
    sDKRequestDto.functionName = chaincodeFunctionName;
    sDKRequestDto.args = [JSON.stringify(storeModelArtifactDto)];
    sDKRequestDto.channelName = channelName;
    const response = await this.bcInvokeService.invokeChaincode(
      sDKRequestDto,
      key,
      orgName,
      salt,
    );
    return this.buildModelArtifactResponseDto(JSON.parse(response.args));
  }

  /**
   * GetModelArtifact Function calls 'GetModelArtifact' chaincode functions on chaincode which returns the model artifact's current state on the basis of GetModelArtifactDto
   *
   *
   * @param {GetModelArtifactDto} getModelArtifactDto - Object of GetModelArtifactDto
   * @param {string} key - Key of the user to get the detail
   * @param {string} orgName - Name of the Organization to be used for transaction
   * @param {string} channelName - Name of the channel to send the transaction
   * @param {string} salt - Unique string associated with the key generated
   * @returns {Promise<ModelArtifactResponseDto>} - Returns Promise of ModelArtifactResponseDto
   *
   *
   **/
  async getModelArtifact(
    getModelArtifactDto: GetModelArtifactDto,
    key: string,
    orgName: string,
    channelName: string,
    salt,
  ): Promise<ModelArtifactResponseDto> {
    const chaincodeFunctionName = 'GetModelArtifact';

    const sDKRequestDto = new SDKRequestDto();
    sDKRequestDto.chaincodeName = this.CHAINCODE_NAME;
    sDKRequestDto.functionName = chaincodeFunctionName;
    sDKRequestDto.args = [JSON.stringify(getModelArtifactDto)];
    sDKRequestDto.channelName = channelName;
    const response = await this.bcQueryService.queryChaincode(
      sDKRequestDto,
      key,
      orgName,
      salt,
    );
    return this.buildModelArtifactResponseDto(response.args);
  }

  /**
   * GetModelArtifactHistory Function calls 'GetModelArtifactHistory' chaincode functions on 'model-artifact' chaincode which returns all the state of model artifact stored on the basis of GetModelArtifactDto
   *
   *
   * @param {GetModelArtifactDto} getModelArtifactDto - Object of GetModelArtifactDto
   * @param {string} key - Key of the user to get the detail
   * @param {string} orgName - Name of the Organization to be used for transaction
   * @param {string} channelName - Name of the channel to send the transaction
   * @param {string} salt - Unique string associated with the key generated
   * @returns {Promise<ModelArtifactResponseDto>} - Returns Promise of ModelArtifactResponseDto
   *
   *
   **/
  async getModelArtifactHistory(
    getModelArtifactDto: GetModelArtifactDto,
    key: string,
    orgName: string,
    channelName: string,
    salt,
  ): Promise<ModelArtifactResponseDto[]> {
    const chaincodeFunctionName = 'GetModelArtifactHistory';

    const sDKRequestDto = new SDKRequestDto();
    sDKRequestDto.chaincodeName = this.CHAINCODE_NAME;
    sDKRequestDto.functionName = chaincodeFunctionName;
    sDKRequestDto.args = [JSON.stringify(getModelArtifactDto)];
    sDKRequestDto.channelName = channelName;
    const response = await this.bcQueryService.queryChaincode(
      sDKRequestDto,
      key,
      orgName,
      salt,
    );
    return this.buildModelArtifactResponseDtoList(response.args);
  }

  /**
   * *******************PRIVATE FUNCTION*******************
   * BuildModelArtifactResponseDto Sync Function typecasts args of type any to ModelArtifactResponseDto
   *
   *
   * @param {any} args - args response from chaincode.
   * @returns {ModelArtifactResponseDto} - Returns ModelArtifactResponseDto
   *
   *
   **/
  private buildModelArtifactResponseDto(args: any): ModelArtifactResponseDto {
    const modelArtifactResponseDto: ModelArtifactResponseDto = args;
    modelArtifactResponseDto.recordDate = args.recordDate;
    return modelArtifactResponseDto;
  }

  /**
   * *******************PRIVATE FUNCTION*******************
   * BuildModelArtifactResponseDtoList Sync Function typecasts args of type any to ModelArtifactResponseDto List
   *
   *
   * @param {any} args - args response from chaincode
   * @returns {ModelArtifactResponseDto[]} - Returns ModelArtifactResponseDto List
   *
   *
   **/
  private buildModelArtifactResponseDtoList(
    args: any,
  ): ModelArtifactResponseDto[] {
    const modelArtifactResponseDtoList = [];
    for (const data of args) {
      const modelArtifactResponseDto = this.buildModelArtifactResponseDto(data);
      modelArtifactResponseDtoList.push(modelArtifactResponseDto);
    }
    return modelArtifactResponseDtoList;
  }
}
