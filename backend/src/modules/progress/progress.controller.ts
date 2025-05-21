import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Request, ParseIntPipe, UnauthorizedException } from '@nestjs/common';
import { ProgressService } from './progress.service';
import { CreateProgressDto } from './dto/create-progress.dto';
import { UpdateProgressDto } from './dto/update-progress.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/enums/roles.enum';

@Controller('progress')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ProgressController {
  constructor(private readonly progressService: ProgressService) {}

  @Post()
  @Roles(Role.ADMIN)
  create(@Body() createProgressDto: CreateProgressDto) {
    return this.progressService.create(createProgressDto);
  }

  @Get()
  @Roles(Role.ADMIN)
  findAll() {
    return this.progressService.findAll();
  }

  @Get(':id')
  @Roles(Role.ADMIN, Role.MEMBER)
  async findOne(@Param('id', ParseIntPipe) id: number, @Request() req) {
    const progress = await this.progressService.findOne(id);
    if (req.user.role === Role.MEMBER && progress.trainee.id !== req.user.id) {
      throw new UnauthorizedException('You can only view your own progress');
    }
    return progress;
  }

  @Get('trainee/:traineeId')
  @Roles(Role.ADMIN, Role.MEMBER)
  async findByTraineeId(
    @Param('traineeId', ParseIntPipe) traineeId: number,
    @Request() req
  ) {
    if (req.user.role === Role.MEMBER && traineeId !== req.user.id) {
      throw new UnauthorizedException('You can only view your own progress');
    }
    return this.progressService.findByTraineeId(traineeId);
  }

  @Patch(':id')
  @Roles(Role.ADMIN)
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateProgressDto: UpdateProgressDto,
  ) {
    return this.progressService.update(id, updateProgressDto);
  }

  @Delete(':id')
  @Roles(Role.ADMIN)
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.progressService.remove(id);
  }
}
