import {
  Body,
  Controller,
  HttpStatus,
  Headers,
  Post,
  HttpCode,
  UseGuards,
  Get,
  Param,
} from '@nestjs/common';
import { AuthorizationGuard } from 'src/@core/auth/guards/authorization.guard';
import { BlockchainStatusGuard } from 'src/@core/auth/guards/blockchain-status.guard';
import { Response } from 'src/@core/common/dto/response.dto';
import { StoreModelVersionDto } from './dto/store-model-version.dto';
import { ModelVersionService } from './model-version.service';

@Controller('model-version')
export class ModelVersionController {
  constructor(private readonly modelVersionService: ModelVersionService) {}

  @Post()
  @UseGuards(BlockchainStatusGuard, AuthorizationGuard)
  @HttpCode(HttpStatus.OK)
  async storeModelVersion(
    @Body() storeModelVersionDto: StoreModelVersionDto,
    @Headers() header,
  ): Promise<Response> {
    return new Response(
      'Project Version Stored',
      await this.modelVersionService.storeVersionProject(
        storeModelVersionDto,
        header.key,
        header.org_name,
        header.channel_name,
        header.salt,
      ),
    ).setStatusCode(HttpStatus.OK);
  }

  @Get(':modelVersionId')
  @UseGuards(BlockchainStatusGuard, AuthorizationGuard)
  @HttpCode(HttpStatus.OK)
  async getModelVersion(
    @Param('modelVersionId') modelVersionId: string,
    @Headers() header,
  ): Promise<Response> {
    return new Response(
      'Project Version Fetched',
      await this.modelVersionService.getModelVersion(
        modelVersionId,
        header.key,
        header.org_name,
        header.channel_name,
        header.salt,
      ),
    ).setStatusCode(HttpStatus.OK);
  }

  @Get('history/:modelVersionId')
  @UseGuards(BlockchainStatusGuard, AuthorizationGuard)
  @HttpCode(HttpStatus.OK)
  async getModelVersionHistory(
    @Param('modelVersionId') modelVersionId: string,
    @Headers() header,
  ): Promise<Response> {
    return new Response(
      'Project Version History Fetched',
      await this.modelVersionService.getModelVersionHistory(
        modelVersionId,
        header.key,
        header.org_name,
        header.channel_name,
        header.salt,
      ),
    ).setStatusCode(HttpStatus.OK);
  }
}
