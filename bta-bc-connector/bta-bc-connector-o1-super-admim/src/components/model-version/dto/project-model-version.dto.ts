import { IsNotEmpty, IsString } from 'class-validator';

export class ProjectModelVersionDto {
  @IsString()
  @IsNotEmpty()
  id: string;

  @IsString()
  @IsNotEmpty()
  projectName: string;
}
