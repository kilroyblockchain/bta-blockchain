import { Module } from '@nestjs/common';
import { BcInvokeModule } from '../blockchain/bc-invoke/bc-invoke.module';
import { BcQueryModule } from '../blockchain/bc-query/bc-query.module';
import { BcUserModule } from '../blockchain/bc-user/bc-user.module';
import { ModelReviewController } from './model-review.controller';
import { ModelReviewService } from './model-review.service';

@Module({
  imports: [BcInvokeModule, BcUserModule, BcQueryModule],
  controllers: [ModelReviewController],
  providers: [ModelReviewService],
})
export class ModelReviewModule {}
