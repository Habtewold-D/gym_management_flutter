import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Event } from './entities/event.entity';
import { CreateEventDto } from './dto/create-event.dto';
import { UpdateEventDto } from './dto/update-event.dto';

@Injectable()
export class EventsService {
  constructor(
    @InjectRepository(Event)
    private eventsRepository: Repository<Event>,
  ) {}

  async create(createEventDto: CreateEventDto, userId: number) {
    const event = this.eventsRepository.create({
      ...createEventDto,
      createdBy: { id: userId },
    });
    return this.eventsRepository.save(event);
  }

  findAll() {
    return this.eventsRepository.find({
      order: { date: 'ASC' },
    });
  }

  async findOne(id: number) {
    const event = await this.eventsRepository.findOne({ where: { id } });
    if (!event) {
      throw new NotFoundException('Event not found');
    }
    return event;
  }

  async update(id: number, updateEventDto: UpdateEventDto) {
    const event = await this.findOne(id);
    Object.assign(event, updateEventDto);
    return this.eventsRepository.save(event);
  }

  async remove(id: number) {
    const event = await this.findOne(id);
    return this.eventsRepository.remove(event);
  }
}
