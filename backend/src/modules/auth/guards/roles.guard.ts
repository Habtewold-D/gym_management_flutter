import { Injectable, CanActivate, ExecutionContext, Logger } from '@nestjs/common'; // Import Logger
import { Reflector } from '@nestjs/core';
import { Role } from '../enums/roles.enum';
import { ROLES_KEY } from '../decorators/roles.decorator';

@Injectable()
export class RolesGuard implements CanActivate {
  private readonly logger = new Logger(RolesGuard.name); // Instantiate Logger
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<Role[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    this.logger.debug(`Required roles: ${JSON.stringify(requiredRoles)}`); // Log required roles

    if (!requiredRoles) {
      this.logger.debug('No specific roles required, access granted.');
      return true;
    }

    const { user } = context.switchToHttp().getRequest();
    this.logger.debug(`User object in RolesGuard: ${JSON.stringify(user)}`); // Log user object

    if (!user || !user.role) {
      this.logger.warn('User object or user.role is undefined in RolesGuard. Denying access.');
      return false; // Explicitly deny if user or user.role is missing
    }

    const hasRequiredRole = requiredRoles.some((role) => user.role === role);
    this.logger.debug(`Does user have required role? ${hasRequiredRole}`); // Log result of role check
    return hasRequiredRole;
  }
}