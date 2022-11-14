import { Module } from '@nestjs/common';
import { BcInvokeModule } from '../blockchain/bc-invoke/bc-invoke.module';
import { BcQueryModule } from '../blockchain/bc-query/bc-query.module';
import { BcUserModule } from '../blockchain/bc-user/bc-user.module';
import { ModelVersionController } from './model-version.controller';
import { ModelVersionService } from './model-version.service';

@Module({
  imports: [BcInvokeModule, BcUserModule, BcQueryModule],
  controllers: [ModelVersionController],
  providers: [ModelVersionService],
})
export class ModelVersionModule {}
