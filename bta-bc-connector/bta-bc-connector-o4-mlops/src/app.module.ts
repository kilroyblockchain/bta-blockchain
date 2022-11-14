import { Module } from '@nestjs/common';
import { BcUserModule } from './components/blockchain/bc-user/bc-user.module';
import { ConnectionModule } from './components/connection/connection.module';
import { ModelArtifactModule } from './components/model-artifact/model-artifact.module';
import { ModelExperimentModule } from './components/model-experiment/model-experiment.module';
import { ModelReviewModule } from './components/model-review/model-review.module';
import { ModelVersionModule } from './components/model-version/model-version.module';
import { ProjectModule } from './components/project/project.module';

@Module({
  imports: [
    BcUserModule,
    ProjectModule,
    ConnectionModule,
    ModelVersionModule,
    ModelReviewModule,
    ModelExperimentModule,
    ModelArtifactModule,
  ],
})
export class AppModule {}
