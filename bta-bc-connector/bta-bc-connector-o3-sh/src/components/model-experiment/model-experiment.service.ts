import { Injectable } from '@nestjs/common';
import { SDKRequestDto } from 'src/@core/common/dto/sdk-request.dto';
import { BcInvokeService } from '../blockchain/bc-invoke/bc-invoke.service';
import { BcQueryService } from '../blockchain/bc-query/bc-query.service';
import { GetModelExperimentDto } from './dto/get-model-experiment.dto';
import { ModelExperimentResponseDto } from './dto/model-experiment-response.dto';
import { StoreModelExperimentDto } from './dto/store-model-experiment.dto';

@Injectable()
export class ModelExperimentService {
  // Name of ModelExperiment Chaincode
  private readonly CHAINCODE_NAME = 'model-experiment';
  constructor(
    private readonly bcInvokeService: BcInvokeService,
    private readonly bcQueryService: BcQueryService,
  ) {}

  /**
   * StoreModelExperiment Function calls 'StoreModelExperiment' chaincode functions on model-experiment chaincode which creates new state if non and updates the existing state.
   *
   *
   * @param {StoreModelExperimentDto} storeModelExperimentDto - Object of StoreModelExperimentDto
   * @param {string} key - Key of the user to get the detail
   * @param {string} orgName - Name of the Organization to be used for transaction
   * @param {string} channelName - Name of the channel to send the transaction
   * @param {string} salt - Unique string associated with the key generated
   * @returns {Promise<ModelExperimentResponseDto>} - Returns Promise of ModelExperimentResponseDto
   *
   *
   **/
  async storeModelExperiment(
    storeModelExperimentDto: StoreModelExperimentDto,
    key: string,
    orgName: string,
    channelName: string,
    salt: string,
  ): Promise<ModelExperimentResponseDto> {
    const chaincodeFunctionName = 'StoreModelExperiment';

    const sDKRequestDto = new SDKRequestDto();
    sDKRequestDto.chaincodeName = this.CHAINCODE_NAME;
    sDKRequestDto.functionName = chaincodeFunctionName;
    sDKRequestDto.args = [JSON.stringify(storeModelExperimentDto)];
    sDKRequestDto.channelName = channelName;
    const response = await this.bcInvokeService.invokeChaincode(
      sDKRequestDto,
      key,
      orgName,
      salt,
    );
    return this.buildModelExperimentResponseDto(JSON.parse(response.args));
  }

  /**
   * GetModelExperiment Function calls 'GetModelExperiment' chaincode functions on model-experiment chaincode which returns the model experiment's current state on the basis of GetModelExperimentDto.
   *
   *
   * @param {GetModelExperimentDto} getModelExperimentDto - Object of GetModelExperimentDto
   * @param {string} key - Key of the user to get the detail
   * @param {string} orgName - Name of the Organization to be used for transaction
   * @param {string} channelName - Name of the channel to send the transaction
   * @param {string} salt - Unique string associated with the key generated
   * @returns {Promise<ModelExperimentResponseDto>} - Returns Promise of ModelExperimentResponseDto
   *
   *
   **/
  async getModelExperiment(
    getModelExperimentDto: GetModelExperimentDto,
    key: string,
    orgName: string,
    channelName: string,
    salt,
  ): Promise<ModelExperimentResponseDto> {
    const chaincodeFunctionName = 'GetModelExperiment';

    const sDKRequestDto = new SDKRequestDto();
    sDKRequestDto.chaincodeName = this.CHAINCODE_NAME;
    sDKRequestDto.functionName = chaincodeFunctionName;
    sDKRequestDto.args = [JSON.stringify(getModelExperimentDto)];
    sDKRequestDto.channelName = channelName;
    const response = await this.bcQueryService.queryChaincode(
      sDKRequestDto,
      key,
      orgName,
      salt,
    );
    return this.buildModelExperimentResponseDto(response.args);
  }

  /**
   * GetModelExperimentHistory Function calls 'GetModelExperimentHistory' chaincode functions on model-experiment chaincode which returns all the state of model experiment stored on the basis of GetModelExperimentDto.
   *
   *
   * @param {GetModelExperimentDto} getModelExperimentDto - Object of GetModelExperimentDto
   * @param {string} key - Key of the user to get the detail
   * @param {string} orgName - Name of the Organization to be used for transaction
   * @param {string} channelName - Name of the channel to send the transaction
   * @param {string} salt - Unique string associated with the key generated
   * @returns {Promise<ModelExperimentResponseDto>} - Returns Promise of ModelExperimentResponseDto
   *
   *
   **/
  async getModelExperimentHistory(
    getModelExperimentDto: GetModelExperimentDto,
    key: string,
    orgName: string,
    channelName: string,
    salt,
  ): Promise<ModelExperimentResponseDto[]> {
    const chaincodeFunctionName = 'GetModelExperimentHistory';

    const sDKRequestDto = new SDKRequestDto();
    sDKRequestDto.chaincodeName = this.CHAINCODE_NAME;
    sDKRequestDto.functionName = chaincodeFunctionName;
    sDKRequestDto.args = [JSON.stringify(getModelExperimentDto)];
    sDKRequestDto.channelName = channelName;
    const response = await this.bcQueryService.queryChaincode(
      sDKRequestDto,
      key,
      orgName,
      salt,
    );
    return this.buildModelExperimentResponseDtoList(response.args);
  }

  /**
   * *******************PRIVATE FUNCTION*******************
   * BuildModelExperimentResponseDto Sync Function typecasts args of type any to ModelExperimentResponseDto
   *
   *
   * @param {any} args - args response from chaincode.
   * @returns {ModelExperimentResponseDto} - Returns ModelExperimentResponseDto
   *
   *
   **/
  private buildModelExperimentResponseDto(
    args: any,
  ): ModelExperimentResponseDto {
    const modelExperimentResponseDto: ModelExperimentResponseDto = args;
    modelExperimentResponseDto.recordDate = args.recordDate;
    return modelExperimentResponseDto;
  }

  /**
   * *******************PRIVATE FUNCTION*******************
   * BuildModelExperimentResponseDtoList Sync Function typecasts args of type any to ModelExperimentResponseDto List
   *
   *
   * @param {any} args - args response from chaincode
   * @returns {ModelExperimentResponseDto[]} - Returns ModelExperimentResponseDto List
   *
   *
   **/
  private buildModelExperimentResponseDtoList(
    args: any,
  ): ModelExperimentResponseDto[] {
    const modelExperimentResponseDtoList = [];
    for (const data of args) {
      const modelExperimentResponseDto =
        this.buildModelExperimentResponseDto(data);
      modelExperimentResponseDtoList.push(modelExperimentResponseDto);
    }
    return modelExperimentResponseDtoList;
  }
}
