import { IsNotEmpty, IsString } from 'class-validator';

export class ProjectDto {
  @IsString()
  @IsNotEmpty()
  id: string;

  @IsString()
  @IsNotEmpty()
  projectName: string;
}
