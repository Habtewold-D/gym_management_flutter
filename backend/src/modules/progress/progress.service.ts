import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Progress } from './entities/progress.entity';
import { CreateProgressDto } from './dto/create-progress.dto';
import { UpdateProgressDto } from './dto/update-progress.dto';

@Injectable()
export class ProgressService {
  constructor(
    @InjectRepository(Progress)
    private progressRepository: Repository<Progress>,
  ) {}

  async create(createProgressDto: CreateProgressDto) {
    const progress = this.progressRepository.create({
      ...createProgressDto,
      trainee: { id: createProgressDto.traineeId },
      lastUpdated: Date.now(),
    });
    return this.progressRepository.save(progress);
  }

  async findAll() {
    return this.progressRepository.find({
      order: { lastUpdated: 'DESC' },
    });
  }

  async findOne(id: number) {
    const progress = await this.progressRepository.findOne({ where: { id } });
    if (!progress) {
      throw new NotFoundException('Progress record not found');
    }
    return progress;
  }

  async findByTraineeId(traineeId: number) {
    return this.progressRepository.find({
      where: { trainee: { id: traineeId } },
      order: { lastUpdated: 'DESC' },
      take: 1,
    });
  }

  async update(id: number, updateProgressDto: UpdateProgressDto) {
    const progress = await this.findOne(id);
    Object.assign(progress, {
      ...updateProgressDto,
      trainee: updateProgressDto.traineeId ? { id: updateProgressDto.traineeId } : undefined,
      lastUpdated: Date.now(),
    });
    return this.progressRepository.save(progress);
  }

  async remove(id: number) {
    const progress = await this.findOne(id);
    return this.progressRepository.remove(progress);
  }
}
