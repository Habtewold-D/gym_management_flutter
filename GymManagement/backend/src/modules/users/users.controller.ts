import { Controller, Get, Put, Body, Param, UseGuards, ParseIntPipe, Request, UnauthorizedException, Delete } from '@nestjs/common';
import { UsersService } from './users.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/enums/roles.enum';

@Controller('users')
@UseGuards(JwtAuthGuard, RolesGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  @Roles(Role.ADMIN)
  findAll() {
    return this.usersService.findAll();
  }

  @Get(':id')
  @Roles(Role.MEMBER)
  async findOne(@Param('id', ParseIntPipe) id: number, @Request() req) {
    // Members can only view their own profile
    if (req.user.id !== id) {
      throw new UnauthorizedException('You can only view your own profile');
    }
    return this.usersService.findOne(id);
  }

  @Put(':id')
  @Roles(Role.MEMBER)
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateUserDto: UpdateUserDto,
    @Request() req
  ) {
    // Members can only update their own profile
    if (req.user.id !== id) {
      throw new UnauthorizedException('You can only update your own profile');
    }
    return this.usersService.update(id, updateUserDto);
  }

  @Delete(':id')
  @Roles(Role.ADMIN)
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.usersService.remove(id);
  }

  @Get('email/:email')
  @Roles(Role.ADMIN)
  async findByEmail(@Param('email') email: string) {
    return this.usersService.findByEmail(email);
  }
}
