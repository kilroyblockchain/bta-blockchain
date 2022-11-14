import {
  Body,
  Controller,
  HttpStatus,
  Headers,
  Post,
  UseGuards,
  HttpCode,
} from '@nestjs/common';
import { AuthorizationGuard } from 'src/@core/auth/guards/authorization.guard';
import { BlockchainStatusGuard } from 'src/@core/auth/guards/blockchain-status.guard';
import { Response } from 'src/@core/common/dto/response.dto';
import { SDKRequestDto } from 'src/@core/common/dto/sdk-request.dto';
import { BcQueryService } from './bc-query.service';

@Controller('bc-query')
export class BcQueryController {
  constructor(private readonly bcQueryService: BcQueryService) {}

  @Post()
  @UseGuards(BlockchainStatusGuard, AuthorizationGuard)
  @HttpCode(HttpStatus.OK)
  async queryChaincode(
    @Body() sDKRequestDto: SDKRequestDto,
    @Headers() header,
  ): Promise<Response> {
    return new Response(
      'Data Fetched Successfully',
      await this.bcQueryService.queryChaincode(
        sDKRequestDto,
        header.key,
        header.org_name,
        header.salt,
      ),
    ).setStatusCode(HttpStatus.OK);
  }
}
