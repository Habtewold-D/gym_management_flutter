import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Request, ParseIntPipe, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { WorkoutsService } from './workouts.service';
import { CreateWorkoutDto } from './dto/create-workout.dto';
import { UpdateWorkoutDto } from './dto/update-workout.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/enums/roles.enum';
import { UsersModule } from '../users/users.module';
import { UsersService } from '../users/users.service';

@Controller('workouts')
@UseGuards(JwtAuthGuard, RolesGuard)
export class WorkoutsController {
  constructor(
    private readonly workoutsService: WorkoutsService,
    private readonly usersService: UsersService
  ) {}

  @Post()
  @Roles(Role.ADMIN)
  async create(@Body() createWorkoutDto: CreateWorkoutDto) {
    // Get the target user
    const targetUser = await this.usersService.findOne(createWorkoutDto.userId);
    
    // Check if target user exists
    if (!targetUser) {
      throw new BadRequestException('User not found');
    }

    // Check if target user is a member
    if (targetUser.role !== Role.MEMBER) {
      throw new BadRequestException('Workouts can only be created for members');
    }

    return this.workoutsService.create(createWorkoutDto);
  }

  @Get()
  @Roles(Role.ADMIN)
  findAll() {
    return this.workoutsService.findAll();
  }

  @Get('my-workout')
  @Roles(Role.MEMBER)
  async findMyWorkouts(@Request() req) {
    return this.workoutsService.findByUserId(req.user.id);
  }

  @Get('user/:userId')
  @Roles(Role.ADMIN)
  async findByUserId(@Param('userId', ParseIntPipe) userId: number) {
    // Get the target user
    const targetUser = await this.usersService.findOne(userId);
    
    // Check if target user exists
    if (!targetUser) {
      throw new BadRequestException('User not found');
    }

    // Check if target user is a member
    if (targetUser.role !== Role.MEMBER) {
      throw new BadRequestException('Can only view workouts of members');
    }

    return this.workoutsService.findByUserId(userId);
  }

  @Get('stats/:userId')
  @Roles(Role.MEMBER)
  async getStats(@Param('userId', ParseIntPipe) userId: number, @Request() req) {
    // Members can only view their own stats
    if (req.user.id !== userId) {
      throw new UnauthorizedException('You can only view your own stats');
    }
    return this.workoutsService.getWorkoutStats(userId);
  }

  @Get('users/all-progress')
  @Roles(Role.ADMIN)
  async getAllUsersProgress() {
    // Get all members
    const members = await this.usersService.findAllMembers();
    
    // Get progress for each member
    const progressPromises = members.map(async (member) => {
      const stats = await this.workoutsService.getWorkoutStats(member.id);
      return {
        userId: member.id,
        name: member.name,
        email: member.email,
        totalWorkouts: stats.totalWorkouts,
        completedWorkouts: stats.completedWorkouts,
        progressPercentage: stats.completionRate
      };
    });

    return Promise.all(progressPromises);
  }

  @Patch(':id')
  @Roles(Role.ADMIN)
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateWorkoutDto: UpdateWorkoutDto,
  ) {
    return this.workoutsService.update(id, updateWorkoutDto);
  }

  @Patch(':id/toggle-completion')
  @Roles(Role.MEMBER)
  async toggleCompletion(@Param('id', ParseIntPipe) id: number, @Request() req) {
    const workout = await this.workoutsService.findOne(id);
    // Members can only toggle their own workouts
    if (workout.user.id !== req.user.id) {
      throw new UnauthorizedException('You can only toggle your own workouts');
    }
    return this.workoutsService.toggleCompletion(id);
  }

  @Delete(':id')
  @Roles(Role.ADMIN)
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.workoutsService.remove(id);
  }
}
