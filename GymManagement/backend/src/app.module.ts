import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersModule } from './modules/users/users.module';
import { WorkoutsModule } from './modules/workouts/workouts.module';
import { User } from './modules/users/entities/user.entitiy';
import { Workout } from './modules/workouts/entities/workout.entity';
import { Event } from './modules/events/entities/event.entity';
import { EventsModule } from './modules/events/events.module';
// import { ProgressModule } from './modules/progress/progress.module';
import { AuthModule } from './modules/auth/auth.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    TypeOrmModule.forRoot({
      type:'mysql',
      host: 'localhost',
      port:3306,
      username:'root',
      password: '',
      database: 'gym_management',
      entities:[User, Workout, Event],
      synchronize: true,
   }),
    UsersModule,
    WorkoutsModule,
    EventsModule,
    // ProgressModule,
    AuthModule,
  ],
})
export class AppModule {}
