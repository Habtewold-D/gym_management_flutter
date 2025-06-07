import { Controller, Get, UseGuards, Delete, Param, HttpCode, HttpStatus } from '@nestjs/common';
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

  @Delete(':id')
  @Roles(Role.ADMIN)
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Param('id') id: string): Promise<void> {
    await this.usersService.remove(parseInt(id, 10));
  }
}
