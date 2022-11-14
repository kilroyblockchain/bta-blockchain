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
import { StoreModelReviewDto } from './dto/store-model-review.dto';
import { ModelReviewService } from './model-review.service';

@Controller('model-review')
export class ModelReviewController {
  constructor(private readonly modelReviewService: ModelReviewService) {}

  @Post()
  @UseGuards(BlockchainStatusGuard, AuthorizationGuard)
  @HttpCode(HttpStatus.OK)
  async storeModelReview(
    @Body() storeModelReviewDto: StoreModelReviewDto,
    @Headers() header,
  ): Promise<Response> {
    return new Response(
      'Project Version Stored',
      await this.modelReviewService.storeModelReview(
        storeModelReviewDto,
        header.key,
        header.org_name,
        header.channel_name,
        header.salt,
      ),
    ).setStatusCode(HttpStatus.OK);
  }

  @Get(':modelReviewId')
  @UseGuards(BlockchainStatusGuard, AuthorizationGuard)
  @HttpCode(HttpStatus.OK)
  async getModelReview(
    @Param('modelReviewId') modelReviewId: string,
    @Headers() header,
  ): Promise<Response> {
    return new Response(
      'Project Version Fetched',
      await this.modelReviewService.getModelReview(
        modelReviewId,
        header.key,
        header.org_name,
        header.channel_name,
        header.salt,
      ),
    ).setStatusCode(HttpStatus.OK);
  }

  @Get('history/:modelReviewId')
  @UseGuards(BlockchainStatusGuard, AuthorizationGuard)
  @HttpCode(HttpStatus.OK)
  async getModelReviewHistory(
    @Param('modelReviewId') modelReviewId: string,
    @Headers() header,
  ): Promise<Response> {
    return new Response(
      'Project Version History Fetched',
      await this.modelReviewService.getModelReviewHistory(
        modelReviewId,
        header.key,
        header.org_name,
        header.channel_name,
        header.salt,
      ),
    ).setStatusCode(HttpStatus.OK);
  }
}
