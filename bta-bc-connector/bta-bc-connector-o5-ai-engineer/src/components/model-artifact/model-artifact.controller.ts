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
import { GetModelArtifactDto } from './dto/get-model-artifact.dto';
import { StoreModelArtifactDto } from './dto/store-model-artifact.dto';
import { ModelArtifactService } from './model-artifact.service';

@Controller('model-artifact')
export class ModelArtifactController {
  constructor(private readonly modelArtifactService: ModelArtifactService) {}

  @Post()
  @UseGuards(BlockchainStatusGuard, AuthorizationGuard)
  @HttpCode(HttpStatus.OK)
  async storeModelArtifact(
    @Body() storeModelArtifactDto: StoreModelArtifactDto,
    @Headers() header,
  ): Promise<Response> {
    return new Response(
      'Model Artifact Stored',
      await this.modelArtifactService.storeModelArtifact(
        storeModelArtifactDto,
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
  async getModelArtifact(
    @Body() getModelArtifactDto: GetModelArtifactDto,
    @Headers() header,
  ): Promise<Response> {
    return new Response(
      'Model Artifact Fetched',
      await this.modelArtifactService.getModelArtifact(
        getModelArtifactDto,
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
  async getModelArtifactHistory(
    @Body() getModelArtifactDto: GetModelArtifactDto,
    @Headers() header,
  ): Promise<Response> {
    return new Response(
      'Model Artifact History Fetched',
      await this.modelArtifactService.getModelArtifactHistory(
        getModelArtifactDto,
        header.key,
        header.org_name,
        header.channel_name,
        header.salt,
      ),
    ).setStatusCode(HttpStatus.OK);
  }
}
