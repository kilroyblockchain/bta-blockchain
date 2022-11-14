import { Type } from 'class-transformer';
import { IsNotEmpty, IsString } from 'class-validator';
import { ModelVersionDto } from './model-version.dto';
import { ProjectDto } from './project.dto';
export class GetModelExperimentDto {
  @IsString()
  @IsNotEmpty()
  experimentName: string;

  // @ValidateNested({ each: true })
  @Type(() => ModelVersionDto)
  @IsNotEmpty()
  modelVersion: ModelVersionDto;

  // @ValidateNested({ each: true })
  @Type(() => ProjectDto)
  @IsNotEmpty()
  project: ProjectDto;
}
