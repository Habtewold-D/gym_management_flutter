import { Injectable, Logger } from '@nestjs/common'; // Import Logger
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { UsersService } from '../../users/users.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  private readonly logger = new Logger(JwtStrategy.name); // Instantiate Logger
  constructor(private usersService: UsersService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET || 'your-secret-key',
    });
  }

  async validate(payload: any) {
    this.logger.debug(`JWT Payload: ${JSON.stringify(payload)}`); // Log payload
    const user = await this.usersService.findOne(payload.sub);
    const userToReturn = { // Prepare user object
      id: user.id,
      email: user.email,
      role: user.role,
    };
    this.logger.debug(`User from DB for JWT: ${JSON.stringify(userToReturn)}`); // Log user from DB
    return userToReturn; // Return the prepared object
  }
}
