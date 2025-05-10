import { IsNumber, IsNotEmpty, Min } from 'class-validator';

export class CreateProgressDto {
  @IsNumber()
  @IsNotEmpty()
  traineeId: number;

  @IsNumber()
  @Min(0)
  completedWorkouts: number;

  @IsNumber()
  @Min(0)
  totalWorkouts: number;
} 