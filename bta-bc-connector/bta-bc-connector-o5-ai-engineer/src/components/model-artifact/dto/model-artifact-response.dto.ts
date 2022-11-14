import { ModelVersionDto } from './model-version.dto';
import { ProjectDto } from './project.dto';

export class ModelArtifactResponseDto {
  modelArtifactName: string;

  modelArtifactBcHash: string;

  modelVersion: ModelVersionDto;

  project: ProjectDto;

  recordDate: string;

  entryUser: string;

  creatorMSP: string;
}
