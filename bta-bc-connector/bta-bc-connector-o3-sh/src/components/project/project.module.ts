import { Module } from '@nestjs/common';
import { BcInvokeModule } from '../blockchain/bc-invoke/bc-invoke.module';
import { BcQueryModule } from '../blockchain/bc-query/bc-query.module';
import { BcUserModule } from '../blockchain/bc-user/bc-user.module';
import { ProjectController } from './project.controller';
import { ProjectService } from './project.service';

@Module({
  imports: [BcInvokeModule, BcUserModule, BcQueryModule],
  controllers: [ProjectController],
  providers: [ProjectService],
})
export class ProjectModule {}
