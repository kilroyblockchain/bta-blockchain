import { Injectable } from '@nestjs/common';
import { SDKRequestDto } from 'src/@core/common/dto/sdk-request.dto';
import { BcInvokeService } from '../blockchain/bc-invoke/bc-invoke.service';
import { BcQueryService } from '../blockchain/bc-query/bc-query.service';
import { ModelReviewResponseDto } from './dto/model-version-response.dto';
import { StoreModelReviewDto } from './dto/store-model-review.dto';

@Injectable()
export class ModelReviewService {
  // Name of ModelReview Chaincode
  private readonly CHAINCODE_NAME = 'model-review';
  constructor(
    private readonly bcInvokeService: BcInvokeService,
    private readonly bcQueryService: BcQueryService,
  ) {}

  /**
   * Store Model Review Function calls 'StoreModelReview' chaincode functions on chaincode 'model version' which creates new state if non and updates the existing state.
   *
   *
   * @param {StoreModelReviewDto} storeModelReviewDto - Object of StoreModelReviewDto
   * @param {string} key - Key of the user to get the detail
   * @param {string} orgName - Name of the Organization to be used for transaction
   * @param {string} channelName - Name of the channel to send the transaction
   * @param {string} salt - Unique string associated with the key generated
   * @returns {Promise<ProjectResponseDto>} - Returns Promise of ProjectResponseDto
   *
   *
   **/
  async storeModelReview(
    storeModelReviewDto: StoreModelReviewDto,
    key: string,
    orgName: string,
    channelName: string,
    salt: string,
  ): Promise<ModelReviewResponseDto> {
    const chaincodeFunctionName = 'ReviewModel';

    const sDKRequestDto = new SDKRequestDto();
    sDKRequestDto.chaincodeName = this.CHAINCODE_NAME;
    sDKRequestDto.functionName = chaincodeFunctionName;
    sDKRequestDto.args = [JSON.stringify(storeModelReviewDto)];
    sDKRequestDto.channelName = channelName;
    const response = await this.bcInvokeService.invokeChaincode(
      sDKRequestDto,
      key,
      orgName,
      salt,
    );
    return this.buildModelReviewResponseDto(JSON.parse(response.args));
  }

  /**
   * GetModelReview Function calls 'GetModelReview' chaincode functions on chaincode 'model version' which returns the model version current state on the basis of model version id
   *
   *
   * @param {string} modelReviewId - Id of the model version state to fetch
   * @param {string} key - Key of the user to get the detail
   * @param {string} orgName - Name of the Organization to be used for transaction
   * @param {string} channelName - Name of the channel to send the transaction
   * @param {string} salt - Unique string associated with the key generated
   * @returns {Promise<ModelReviewResponseDto>} - Returns Promise of ModelReviewResponseDto
   *
   *
   **/
  async getModelReview(
    modelReviewId: string,
    key: string,
    orgName: string,
    channelName: string,
    salt,
  ): Promise<ModelReviewResponseDto> {
    const chaincodeFunctionName = 'GetModelReview';

    const sDKRequestDto = new SDKRequestDto();
    sDKRequestDto.chaincodeName = this.CHAINCODE_NAME;
    sDKRequestDto.functionName = chaincodeFunctionName;
    sDKRequestDto.args = [modelReviewId];
    sDKRequestDto.channelName = channelName;
    const response = await this.bcQueryService.queryChaincode(
      sDKRequestDto,
      key,
      orgName,
      salt,
    );
    return this.buildModelReviewResponseDto(response.args);
  }

  /**
   * GetProjectHistory Function calls 'GetProjectHistory' chaincode functions on chaincode 'model version' which returns all the state of model version stored on the basis of model version id
   *
   *
   * @param {string} modelReviewId - Id of the model version state to fetch
   * @param {string} key - Key of the user to get the detail
   * @param {string} orgName - Name of the Organization to be used for transaction
   * @param {string} channelName - Name of the channel to send the transaction
   * @param {string} salt - Unique string associated with the key generated
   * @returns {Promise<ModelReviewResponseDto>} - Returns Promise of ModelReviewResponseDto
   *
   *
   **/
  async getModelReviewHistory(
    modelReviewId: string,
    key: string,
    orgName: string,
    channelName: string,
    salt,
  ): Promise<ModelReviewResponseDto[]> {
    const chaincodeFunctionName = 'GetModelReviewHistory';

    const sDKRequestDto = new SDKRequestDto();
    sDKRequestDto.chaincodeName = this.CHAINCODE_NAME;
    sDKRequestDto.functionName = chaincodeFunctionName;
    sDKRequestDto.args = [modelReviewId];
    sDKRequestDto.channelName = channelName;
    const response = await this.bcQueryService.queryChaincode(
      sDKRequestDto,
      key,
      orgName,
      salt,
    );
    return this.buildModelReviewResponseDtoList(response.args);
  }

  /**
   * *******************PRIVATE FUNCTION*******************
   * BuildModelReviewResponseDto Sync Function typecasts args of type any to ModelReviewResponseDto
   *
   *
   * @param {any} args - args response from chaincode.
   * @returns {ModelReviewResponseDto} - Returns ModelReviewResponseDto
   *
   *
   **/
  private buildModelReviewResponseDto(args: any): ModelReviewResponseDto {
    const modelReviewResponseDto: ModelReviewResponseDto = args;
    modelReviewResponseDto.recordDate = args.recordDate;
    modelReviewResponseDto.creatorMSP = args.creatorMSP;
    return modelReviewResponseDto;
  }

  /**
   * *******************PRIVATE FUNCTION*******************
   * BuildModelReviewResponseDtoList Sync Function typecasts args of type any to ModelReviewResponseDto List
   *
   *
   * @param {any} args - args response from chaincode
   * @returns {ModelReviewResponseDto[]} - Returns ModelReviewResponseDto List
   *
   *
   **/
  private buildModelReviewResponseDtoList(args: any): ModelReviewResponseDto[] {
    const modelReviewResponseDtoList = [];
    for (const data of args) {
      const modelReviewResponseDto = this.buildModelReviewResponseDto(data);
      modelReviewResponseDtoList.push(modelReviewResponseDto);
    }
    return modelReviewResponseDtoList;
  }
}
