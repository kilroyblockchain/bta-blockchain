import { IsNotEmpty, IsString } from 'class-validator';

export class ModelVersionProjectDto {
  @IsString()
  @IsNotEmpty()
  id: string;

  @IsString()
  @IsNotEmpty()
  versionName: string;
}
