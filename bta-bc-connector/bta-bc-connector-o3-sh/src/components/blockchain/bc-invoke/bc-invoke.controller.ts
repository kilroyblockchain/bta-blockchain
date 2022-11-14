import {
  Body,
  Controller,
  HttpStatus,
  Headers,
  Post,
  HttpCode,
} from '@nestjs/common';
import { Response } from 'src/@core/common/dto/response.dto';
import { SDKRequestDto } from 'src/@core/common/dto/sdk-request.dto';
import { BcInvokeService } from './bc-invoke.service';

@Controller('bc-invoke')
export class BcInvokeController {
  constructor(private readonly bcInvokeService: BcInvokeService) {}

  @Post()
  // @UseGuards(BlockchainStatusGuard, AuthorizationGuard)
  @HttpCode(HttpStatus.OK)
  async invokeChaincode(
    @Body() sDKRequestDto: SDKRequestDto,
    @Headers() header,
  ): Promise<Response> {
    return new Response(
      'Data Stored Successfully',
      await this.bcInvokeService.invokeChaincode(
        sDKRequestDto,
        header.key,
        header.org_name,
        header.salt,
      ),
    ).setStatusCode(HttpStatus.OK);
  }
}
