import { Injectable } from '@nestjs/common';
import { SDKRequestDto } from 'src/@core/common/dto/sdk-request.dto';
import { BcInvokeService } from '../blockchain/bc-invoke/bc-invoke.service';
import { BcQueryService } from '../blockchain/bc-query/bc-query.service';
import { ModelVersionResponseDto } from './dto/model-version-response.dto';
import { StoreModelVersionDto } from './dto/store-model-version.dto';

@Injectable()
export class ModelVersionService {
  // Name of ModelVersion Chaincode
  private readonly CHAINCODE_NAME = 'model-version';
  constructor(
    private readonly bcInvokeService: BcInvokeService,
    private readonly bcQueryService: BcQueryService,
  ) {}

  /**
   * Create Project Version Function calls 'StoreModelVersion' chaincode functions on chaincode 'model version' which creates new state if non and updates the existing state.
   *
   *
   * @param {StoreModelVersionDto} storeModelVersionDto - Object of StoreModelVersionDto
   * @param {string} key - Key of the user to get the detail
   * @param {string} orgName - Name of the Organization to be used for transaction
   * @param {string} channelName - Name of the channel to send the transaction
   * @param {string} salt - Unique string associated with the key generated
   * @returns {Promise<ProjectResponseDto>} - Returns Promise of ProjectResponseDto
   *
   *
   **/
  async storeVersionProject(
    storeModelVersionDto: StoreModelVersionDto,
    key: string,
    orgName: string,
    channelName: string,
    salt: string,
  ): Promise<ModelVersionResponseDto> {
    const chaincodeFunctionName = 'StoreModelVersion';

    const sDKRequestDto = new SDKRequestDto();
    sDKRequestDto.chaincodeName = this.CHAINCODE_NAME;
    sDKRequestDto.functionName = chaincodeFunctionName;
    sDKRequestDto.args = [JSON.stringify(storeModelVersionDto)];
    sDKRequestDto.channelName = channelName;
    const response = await this.bcInvokeService.invokeChaincode(
      sDKRequestDto,
      key,
      orgName,
      salt,
    );
    return this.buildModelVersionResponseDto(JSON.parse(response.args));
  }

  /**
   * GetProject Function calls 'GetProject' chaincode functions on chaincode 'model version' which returns the model version current state on the basis of model version id
   *
   *
   * @param {string} modelVersionId - Id of the model version state to fetch
   * @param {string} key - Key of the user to get the detail
   * @param {string} orgName - Name of the Organization to be used for transaction
   * @param {string} channelName - Name of the channel to send the transaction
   * @param {string} salt - Unique string associated with the key generated
   * @returns {Promise<ModelVersionResponseDto>} - Returns Promise of ModelVersionResponseDto
   *
   *
   **/
  async getModelVersion(
    modelVersionId: string,
    key: string,
    orgName: string,
    channelName: string,
    salt,
  ): Promise<ModelVersionResponseDto> {
    const chaincodeFunctionName = 'GetModelVersion';

    const sDKRequestDto = new SDKRequestDto();
    sDKRequestDto.chaincodeName = this.CHAINCODE_NAME;
    sDKRequestDto.functionName = chaincodeFunctionName;
    sDKRequestDto.args = [modelVersionId];
    sDKRequestDto.channelName = channelName;
    const response = await this.bcQueryService.queryChaincode(
      sDKRequestDto,
      key,
      orgName,
      salt,
    );
    return this.buildModelVersionResponseDto(response.args);
  }

  /**
   * GetProjectHistory Function calls 'GetProjectHistory' chaincode functions on chaincode 'model version' which returns all the state of model version stored on the basis of model version id
   *
   *
   * @param {string} modelVersionId - Id of the model version state to fetch
   * @param {string} key - Key of the user to get the detail
   * @param {string} orgName - Name of the Organization to be used for transaction
   * @param {string} channelName - Name of the channel to send the transaction
   * @param {string} salt - Unique string associated with the key generated
   * @returns {Promise<ModelVersionResponseDto>} - Returns Promise of ModelVersionResponseDto
   *
   *
   **/
  async getModelVersionHistory(
    modelVersionId: string,
    key: string,
    orgName: string,
    channelName: string,
    salt,
  ): Promise<ModelVersionResponseDto[]> {
    const chaincodeFunctionName = 'GetModelVersionHistory';

    const sDKRequestDto = new SDKRequestDto();
    sDKRequestDto.chaincodeName = this.CHAINCODE_NAME;
    sDKRequestDto.functionName = chaincodeFunctionName;
    sDKRequestDto.args = [modelVersionId];
    sDKRequestDto.channelName = channelName;
    const response = await this.bcQueryService.queryChaincode(
      sDKRequestDto,
      key,
      orgName,
      salt,
    );
    return this.buildModelVersionResponseDtoList(response.args);
  }

  /**
   * *******************PRIVATE FUNCTION*******************
   * BuildModelVersionResponseDto Sync Function typecasts args of type any to ModelVersionResponseDto
   *
   *
   * @param {any} args - args response from chaincode.
   * @returns {ModelVersionResponseDto} - Returns ModelVersionResponseDto
   *
   *
   **/
  private buildModelVersionResponseDto(args: any): ModelVersionResponseDto {
    const modelVersionResponseDto: ModelVersionResponseDto = args;
    modelVersionResponseDto.recordDate = args.recordDate;
    return modelVersionResponseDto;
  }

  /**
   * *******************PRIVATE FUNCTION*******************
   * BuildModelVersionResponseDtoList Sync Function typecasts args of type any to ModelVersionResponseDto List
   *
   *
   * @param {any} args - args response from chaincode
   * @returns {ModelVersionResponseDto[]} - Returns ModelVersionResponseDto List
   *
   *
   **/
  private buildModelVersionResponseDtoList(
    args: any,
  ): ModelVersionResponseDto[] {
    const modelVersionResponseDtoList = [];
    for (const data of args) {
      const modelVersionResponseDto = this.buildModelVersionResponseDto(data);
      modelVersionResponseDtoList.push(modelVersionResponseDto);
    }
    return modelVersionResponseDtoList;
  }
}
