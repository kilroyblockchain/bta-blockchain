import { IsNotEmpty, IsString } from 'class-validator';

export class ModelVersionDto {
  @IsString()
  @IsNotEmpty()
  id: string;

  @IsString()
  @IsNotEmpty()
  versionName: string;
}
