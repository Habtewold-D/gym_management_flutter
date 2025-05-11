import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Workout } from './entities/workout.entity';
import { CreateWorkoutDto } from './dto/create-workout.dto';
import { UpdateWorkoutDto } from './dto/update-workout.dto';

@Injectable()
export class WorkoutsService {
  constructor(
    @InjectRepository(Workout)
    private workoutsRepository: Repository<Workout>,
  ) {}

  async create(createWorkoutDto: CreateWorkoutDto): Promise<Workout> {
    const workout = this.workoutsRepository.create({
      ...createWorkoutDto,
      user: { id: createWorkoutDto.userId },
    });
    return this.workoutsRepository.save(workout);
  }

  async findAll(): Promise<Workout[]> {
    return this.workoutsRepository.find({
      order: { createdAt: 'DESC' },
      relations: ['user'],
    });
  }

  async findByUserId(userId: number): Promise<Workout[]> {
    return this.workoutsRepository.find({
      where: { user: { id: userId } },
      order: { createdAt: 'DESC' },
      relations: ['user'],
    });
  }

  async findOne(id: number): Promise<Workout> {
    const workout = await this.workoutsRepository.findOne({
      where: { id },
      relations: ['user'],
    });

    if (!workout) {
      throw new NotFoundException(`Workout with ID ${id} not found`);
    }

    return workout;
  }

  async update(id: number, updateWorkoutDto: UpdateWorkoutDto): Promise<Workout> {
    const workout = await this.findOne(id);
    
    if (updateWorkoutDto.userId) {
      workout.user = { id: updateWorkoutDto.userId } as any;
    }
    
    Object.assign(workout, {
      ...updateWorkoutDto,
      userId: undefined, // Remove userId from the update
    });
    
    return this.workoutsRepository.save(workout);
  }

  async remove(id: number): Promise<void> {
    const workout = await this.findOne(id);
    await this.workoutsRepository.remove(workout);
  }

  async toggleCompletion(id: number): Promise<Workout> {
    const workout = await this.findOne(id);
    workout.isCompleted = !workout.isCompleted;
    return this.workoutsRepository.save(workout);
  }

  async getWorkoutStats(userId: number): Promise<{
    totalWorkouts: number;
    completedWorkouts: number;
    completionRate: number;
  }> {
    const workouts = await this.findByUserId(userId);
    const totalWorkouts = workouts.length;
    const completedWorkouts = workouts.filter(w => w.isCompleted).length;
    
    return {
      totalWorkouts,
      completedWorkouts,
      completionRate: totalWorkouts > 0 ? Math.round((completedWorkouts / totalWorkouts) * 100) : 0,
    };
  }
}
