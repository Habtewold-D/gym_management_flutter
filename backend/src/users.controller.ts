import { Controller, Get, UseGuards } from '@nestjs/common';
import { UsersService } from './modules/users/users.service';
import { JwtAuthGuard } from './modules/auth/guards/jwt-auth.guard';
import { Roles } from './modules/auth/decorators/roles.decorator';
import { RolesGuard } from './modules/auth/guards/roles.guard';
import { Role } from './modules/auth/enums/roles.enum';

@Controller('admin/users')
@UseGuards(JwtAuthGuard, RolesGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('members')
  @Roles(Role.ADMIN)
  getMembers(): any {
    // Return only member users (filter out admin)
    return this.usersService.findAll();
  }
}
