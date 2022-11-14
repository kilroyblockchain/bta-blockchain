import { ModelVersionDto } from './model-version.dto';
import { ProjectDto } from './project.dto';

export class ModelExperimentResponseDto {
  experimentName: string;

  experimentBcHash: string;

  modelVersion: ModelVersionDto[];

  project: ProjectDto[];

  recordDate: string;

  entryUser: string;

  creatorMSP: string;
}
