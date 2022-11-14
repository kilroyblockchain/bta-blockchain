import { Module } from '@nestjs/common';
import { BcUserController } from './bc-user.controller';
import { BcUserService } from './bc-user.service';

@Module({
  controllers: [BcUserController],
  providers: [BcUserService],
  exports: [BcUserService],
})
export class BcUserModule {}
