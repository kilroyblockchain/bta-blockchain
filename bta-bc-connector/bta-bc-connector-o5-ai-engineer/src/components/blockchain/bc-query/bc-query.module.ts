import { Module } from '@nestjs/common';
import { BcUserModule } from '../bc-user/bc-user.module';
import { BcQueryController } from './bc-query.controller';
import { BcQueryService } from './bc-query.service';

@Module({
  imports: [BcUserModule],
  controllers: [BcQueryController],
  providers: [BcQueryService],
  exports: [BcQueryService],
})
export class BcQueryModule {}
