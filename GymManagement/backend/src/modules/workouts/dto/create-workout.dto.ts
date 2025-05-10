import { IsString, IsNumber, IsOptional, IsBoolean } from 'class-validator';

export class CreateWorkoutDto {
  @IsString()
  eventTitle: string;

  @IsNumber()
  userId: number;

  @IsNumber()
  sets: number;

  @IsNumber()
  repsOrSecs: number;

  @IsNumber()
  restTime: number;

  @IsOptional()
  @IsString()
  imageUri?: string;

  @IsOptional()
  @IsBoolean()
  isCompleted?: boolean;
} 