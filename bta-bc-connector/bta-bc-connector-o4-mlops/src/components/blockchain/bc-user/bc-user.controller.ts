import {
  Controller,
  HttpStatus,
  HttpCode,
  UseGuards,
  Post,
  Body,
  Headers,
  UnauthorizedException,
} from '@nestjs/common';
import { AuthorizationGuard } from 'src/@core/auth/guards/authorization.guard';
import { BlockchainStatusGuard } from 'src/@core/auth/guards/blockchain-status.guard';
import { Response } from 'src/@core/common/dto/response.dto';
import { BcUserService } from './bc-user.service';
import { RegisterUserDto } from './dto/register-user.dto';

@Controller('bc-user')
export class BcUserController {
  constructor(private readonly bcUserService: BcUserService) {}

  @Post('/register')
  @UseGuards(BlockchainStatusGuard, AuthorizationGuard)
  @HttpCode(HttpStatus.OK)
  async registerUser(
    @Body() registerUserDto: RegisterUserDto,
    @Headers() header,
  ): Promise<Response> {
    return new Response(
      'User Registered Successfully',
      await this.bcUserService.enrollAndRegisterUser(
        registerUserDto,
        header.org_name,
      ),
    ).setStatusCode(HttpStatus.OK);
  }

  @Post('/registerSuperAdmin')
  @UseGuards(AuthorizationGuard)
  @HttpCode(HttpStatus.OK)
  async registerSuperAdmin(
    @Body() registerUserDto: RegisterUserDto,
    @Headers() header,
  ): Promise<Response> {
    if (!header.admin_id) {
      throw new UnauthorizedException(['Admin id not found on header']);
    }
    if (header.admin_id != process.env.ADMIN_ID) {
      throw new UnauthorizedException(['Incorrect admin credentials']);
    }
    return new Response(
      'User Registered Successfully',
      await this.bcUserService.enrollAndRegisterUser(
        registerUserDto,
        header.org_name,
      ),
    ).setStatusCode(HttpStatus.OK);
  }

  @Post('re-enroll')
  @UseGuards(BlockchainStatusGuard, AuthorizationGuard)
  @HttpCode(HttpStatus.OK)
  async enroll(
    @Body() registerUserDto: RegisterUserDto,
    @Headers() header,
  ): Promise<Response> {
    return new Response(
      'User Re-enrolled Successfully',
      await this.bcUserService.userReEnrollment(
        registerUserDto,
        header.org_name,
      ),
    ).setStatusCode(HttpStatus.OK);
  }
}
