import { IsEmail, IsNotEmpty, IsString } from 'class-validator';

export class RegisterUserDto {
  @IsNotEmpty()
  @IsString()
  readonly userId: string;

  @IsNotEmpty()
  @IsEmail()
  readonly email: string;
}
