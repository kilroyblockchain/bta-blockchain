import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsNotEmpty,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { ProjectModelVersionDto } from './project-model-version.dto';
export class StoreModelVersionDto {
  @IsString()
  @IsNotEmpty()
  id: string;

  @IsString()
  @IsNotEmpty()
  versionName: string;

  @IsString()
  @IsNotEmpty()
  logFilePath: string;

  @IsString()
  @IsOptional()
  logFileBCHash: string;

  @IsString()
  @IsNotEmpty()
  noteBookVersion: string;

  @IsString()
  @IsNotEmpty()
  testDataSetsUrl: string;

  @IsString()
  @IsOptional()
  testDatasetBCHash: string;

  @IsString()
  @IsOptional()
  trainDataSetsUrl: string;

  @IsString()
  @IsOptional()
  trainDatasetBCHash: string;

  @IsString()
  @IsOptional()
  aiModelUrl: string;

  @IsString()
  @IsOptional()
  aiModelBCHash: string;

  @IsString()
  @IsNotEmpty()
  codeVersion: string;

  @IsString()
  @IsNotEmpty()
  codeRepo: string;

  @IsString()
  @IsNotEmpty()
  comment: string;

  @IsString()
  @IsNotEmpty()
  versionStatus: string;

  @IsBoolean()
  @IsNotEmpty()
  status: boolean;

  @ValidateNested({ each: true })
  @Type(() => ProjectModelVersionDto)
  project: ProjectModelVersionDto[];

  @IsString()
  @IsNotEmpty()
  entryUser: string;
}
