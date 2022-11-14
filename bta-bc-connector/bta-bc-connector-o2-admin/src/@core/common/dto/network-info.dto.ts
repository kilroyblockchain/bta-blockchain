import { IsNotEmpty, IsString } from 'class-validator';
export class NetworkInfoDto {
  @IsString()
  @IsNotEmpty()
  loggedInUserId: string;

  @IsString()
  @IsNotEmpty()
  channelName: string;

  @IsString()
  @IsNotEmpty()
  orgName: string;
}
