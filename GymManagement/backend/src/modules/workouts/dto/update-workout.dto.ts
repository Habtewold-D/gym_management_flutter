import { IsString, IsNumber, IsOptional, IsBoolean } from 'class-validator';

export class UpdateWorkoutDto {
  @IsOptional()
  @IsString()
  eventTitle?: string;

  @IsOptional()
  @IsNumber()
  userId?: number;

  @IsOptional()
  @IsNumber()
  sets?: number;

  @IsOptional()
  @IsNumber()
  repsOrSecs?: number;

  @IsOptional()
  @IsNumber()
  restTime?: number;

  @IsOptional()
  @IsString()
  imageUri?: string;

  @IsOptional()
  @IsBoolean()
  isCompleted?: boolean;
} 