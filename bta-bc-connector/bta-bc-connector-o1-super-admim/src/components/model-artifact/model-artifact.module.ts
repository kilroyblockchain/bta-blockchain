import { Module } from '@nestjs/common';
import { BcInvokeModule } from '../blockchain/bc-invoke/bc-invoke.module';
import { BcQueryModule } from '../blockchain/bc-query/bc-query.module';
import { BcUserModule } from '../blockchain/bc-user/bc-user.module';
import { ModelArtifactController } from './model-artifact.controller';
import { ModelArtifactService } from './model-artifact.service';

@Module({
  imports: [BcInvokeModule, BcUserModule, BcQueryModule],
  controllers: [ModelArtifactController],
  providers: [ModelArtifactService],
})
export class ModelArtifactModule {}
