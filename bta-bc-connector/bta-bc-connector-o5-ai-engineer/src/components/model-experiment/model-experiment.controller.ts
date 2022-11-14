import {
  Body,
  Controller,
  HttpStatus,
  Headers,
  Post,
  HttpCode,
  UseGuards,
} from '@nestjs/common';
import { AuthorizationGuard } from 'src/@core/auth/guards/authorization.guard';
import { BlockchainStatusGuard } from 'src/@core/auth/guards/blockchain-status.guard';
import { Response } from 'src/@core/common/dto/response.dto';
import { GetModelExperimentDto } from './dto/get-model-experiment.dto';
import { StoreModelExperimentDto } from './dto/store-model-experiment.dto';
import { ModelExperimentService } from './model-experiment.service';

@Controller('model-experiment')
export class ModelExperimentController {
  constructor(
    private readonly modelExperimentService: ModelExperimentService,
  ) {}

  @Post()
  @UseGuards(BlockchainStatusGuard, AuthorizationGuard)
  @HttpCode(HttpStatus.OK)
  async storeModelExperiment(
    @Body() storeModelExperimentDto: StoreModelExperimentDto,
    @Headers() header,
  ): Promise<Response> {
    return new Response(
      'Model Experiment Stored',
      await this.modelExperimentService.storeModelExperiment(
        storeModelExperimentDto,
        header.key,
        header.org_name,
        header.channel_name,
        header.salt,
      ),
    ).setStatusCode(HttpStatus.OK);
  }

  @Post('/get')
  @UseGuards(BlockchainStatusGuard, AuthorizationGuard)
  @HttpCode(HttpStatus.OK)
  async getModelExperiment(
    @Body() getModelExperimentDto: GetModelExperimentDto,
    @Headers() header,
  ): Promise<Response> {
    return new Response(
      'Model Experiment Fetched',
      await this.modelExperimentService.getModelExperiment(
        getModelExperimentDto,
        header.key,
        header.org_name,
        header.channel_name,
        header.salt,
      ),
    ).setStatusCode(HttpStatus.OK);
  }

  @Post('history')
  @UseGuards(BlockchainStatusGuard, AuthorizationGuard)
  @HttpCode(HttpStatus.OK)
  async getModelExperimentHistory(
    @Body() getModelExperimentDto: GetModelExperimentDto,
    @Headers() header,
  ): Promise<Response> {
    return new Response(
      'Model Experiment History Fetched',
      await this.modelExperimentService.getModelExperimentHistory(
        getModelExperimentDto,
        header.key,
        header.org_name,
        header.channel_name,
        header.salt,
      ),
    ).setStatusCode(HttpStatus.OK);
  }
}
