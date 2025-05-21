import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, CreateDateColumn, UpdateDateColumn } from 'typeorm';
import { User } from '../../users/entities/user.entitiy';

@Entity('trainee_progress')
export class Progress {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => User, { eager: true })
  trainee: User;

  @Column()
  completedWorkouts: number;

  @Column()
  totalWorkouts: number;

  @Column({ type: 'bigint' })
  lastUpdated: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  get progressPercentage(): number {
    return this.totalWorkouts > 0 
      ? Math.floor((this.completedWorkouts * 100) / this.totalWorkouts) 
      : 0;
  }
} 