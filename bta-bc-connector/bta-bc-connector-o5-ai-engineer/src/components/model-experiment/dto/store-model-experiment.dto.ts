import { Type } from 'class-transformer';
import { IsNotEmpty, IsString, ValidateNested } from 'class-validator';
import { ModelVersionDto } from './model-version.dto';
import { ProjectDto } from './project.dto';
export class StoreModelExperimentDto {
  @IsString()
  @IsNotEmpty()
  experimentName: string;

  @IsString()
  @IsNotEmpty()
  experimentBcHash: string;

  @ValidateNested({ each: true })
  @Type(() => ModelVersionDto)
  @IsNotEmpty()
  modelVersion: ModelVersionDto;

  @ValidateNested({ each: true })
  @Type(() => ProjectDto)
  @IsNotEmpty()
  project: ProjectDto;

  @IsString()
  @IsNotEmpty()
  entryUser: string;
}
