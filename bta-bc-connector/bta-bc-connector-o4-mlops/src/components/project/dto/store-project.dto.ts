import { Type } from 'class-transformer';
import {
  IsArray,
  IsBoolean,
  IsNotEmpty,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { ModelVersionProjectDto } from 'src/components/model-version/dto/model-version-project.dto';

export class PurposeDetail {
  @IsString()
  @IsOptional()
  purpose: string;
  @IsString()
  @IsOptional()
  docUrl: string;
  @IsString()
  @IsOptional()
  docName: string;
}

export class StoreProjectDto {
  @IsString()
  @IsNotEmpty()
  id: string;

  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsOptional()
  detail: string;

  @IsString()
  @IsOptional()
  domain: string;

  @IsNotEmpty()
  @IsArray()
  members: string[];

  @IsNotEmpty()
  @IsBoolean()
  status: boolean;

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ModelVersionProjectDto)
  modelVersions: ModelVersionProjectDto[];

  @IsOptional()
  @Type(() => PurposeDetail)
  purposeDetail: PurposeDetail;

  @IsOptional()
  @IsString()
  entryUser: string;

  @IsOptional()
  @IsString()
  createdBy: string;
}
