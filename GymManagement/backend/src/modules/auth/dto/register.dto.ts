// backend/src/modules/auth/dto/register.dto.ts
import { IsEmail, IsString, IsNumber, MinLength, Matches } from 'class-validator';

export class RegisterDto {
  @IsString()
  name: string;

  @IsEmail()
  email: string;

  @IsString()
  @MinLength(6)
  password: string;

  @IsString()
  @MinLength(6)
  @Matches(/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$/, {
    message: 'Password must contain at least one letter and one number',
  })
  confirmPassword: string;

  @IsNumber()
  age: number;

  @IsNumber()
  height: number;

  @IsNumber()
  weight: number;
}