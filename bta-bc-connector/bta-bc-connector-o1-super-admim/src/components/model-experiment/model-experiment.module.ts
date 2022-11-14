import { Module } from '@nestjs/common';
import { BcInvokeModule } from '../blockchain/bc-invoke/bc-invoke.module';
import { BcQueryModule } from '../blockchain/bc-query/bc-query.module';
import { BcUserModule } from '../blockchain/bc-user/bc-user.module';
import { ModelExperimentController } from './model-experiment.controller';
import { ModelExperimentService } from './model-experiment.service';

@Module({
  imports: [BcInvokeModule, BcUserModule, BcQueryModule],
  controllers: [ModelExperimentController],
  providers: [ModelExperimentService],
})
export class ModelExperimentModule {}
