import { Module } from '@nestjs/common';
import { BcUserModule } from '../bc-user/bc-user.module';
import { BcInvokeController } from './bc-invoke.controller';
import { BcInvokeService } from './bc-invoke.service';

@Module({
  imports: [BcUserModule],
  controllers: [BcInvokeController],
  providers: [BcInvokeService],
  exports: [BcInvokeService],
})
export class BcInvokeModule {}
