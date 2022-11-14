import { IsNotEmpty, IsString } from 'class-validator';

export class EntryUserDetailDto {
  @IsString()
  @IsNotEmpty()
  entryUser: string;

  @IsString()
  @IsNotEmpty()
  organizationUnit: string;

  @IsString()
  @IsNotEmpty()
  staffing: string;
}
