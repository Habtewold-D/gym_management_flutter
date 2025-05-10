import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, ManyToOne, Index } from 'typeorm';
import { User } from '../../users/entities/user.entitiy';

@Entity('workouts')
export class Workout {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  eventTitle: string;

  @Column()
  sets: number;

  @Column()
  repsOrSecs: number;

  @Column()
  restTime: number;

  @Column({ nullable: true })
  imageUri: string;

  @Column({ default: false })
  isCompleted: boolean;

  @ManyToOne(() => User, user => user.workouts)
  @Index()
  user: User;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
} 