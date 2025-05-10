import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProgressService } from './progress.service';
import { ProgressController } from './progress.controller';
import { Progress } from './entities/progress.entity';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Progress]),
    UsersModule
  ],
  controllers: [ProgressController],
  providers: [ProgressService],
  exports: [ProgressService]
})
export class ProgressModule {}
