import { Module } from '@nestjs/common';
import { BcUserModule } from '../blockchain/bc-user/bc-user.module';
import { ConnectionController } from './connection.controller';

@Module({
  imports: [BcUserModule],
  controllers: [ConnectionController],
})
export class ConnectionModule {}
