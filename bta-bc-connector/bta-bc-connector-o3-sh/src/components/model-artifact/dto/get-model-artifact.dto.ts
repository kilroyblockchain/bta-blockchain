import { Type } from 'class-transformer';
import { IsNotEmpty, IsString } from 'class-validator';
import { ModelVersionDto } from './model-version.dto';
import { ProjectDto } from './project.dto';
export class GetModelArtifactDto {
  @IsString()
  @IsNotEmpty()
  modelArtifactName: string;

  @Type(() => ModelVersionDto)
  @IsNotEmpty()
  modelVersion: ModelVersionDto;

  @Type(() => ProjectDto)
  @IsNotEmpty()
  project: ProjectDto;
}
