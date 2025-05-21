import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Request, ParseIntPipe } from '@nestjs/common';
import { EventsService } from './events.service';
import { CreateEventDto } from './dto/create-event.dto';
import { UpdateEventDto } from './dto/update-event.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/enums/roles.enum';
import { ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../users/entities/user.entitiy';

@Controller('events')
@UseGuards(JwtAuthGuard, RolesGuard)
export class EventsController {
  constructor(private readonly eventsService: EventsService) {}

  @Post()
  @Roles(Role.ADMIN)
  async create(@Body() createEventDto: CreateEventDto, @Request() req) {
    const event = await this.eventsService.create(createEventDto, req.user.id);
    return {
      ...event,
      createdBy: event.createdBy.id,
    };
  }

  @Get()
  @Roles(Role.ADMIN, Role.MEMBER)
  async findAll() {
    return (await this.eventsService.findAll()).map(event => ({
      ...event,
      createdBy: event.createdBy.id,
    }));
  }

  @Get(':id')
  @Roles(Role.ADMIN, Role.MEMBER)
  async findOne(@Param('id', ParseIntPipe) id: number) {
    const event = await this.eventsService.findOne(id);
    return {
      ...event,
      createdBy: event.createdBy.id,
    };
  }

  @Patch(':id')
  @Roles(Role.ADMIN)
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateEventDto: UpdateEventDto,
  ) {
    const event = await this.eventsService.update(id, updateEventDto);
    return {
      ...event,
      createdBy: event.createdBy.id,
    };
  }

  @Delete(':id')
  @Roles(Role.ADMIN)
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.eventsService.remove(id);
  }

}
