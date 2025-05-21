import { DataSource } from 'typeorm';
import { UserSeed } from './user.seed';
import { User } from '../../modules/users/entities/user.entitiy';
import { Workout } from '../../modules/workouts/entities/workout.entity';

async function runSeed() {
  const dataSource = new DataSource({
    type: 'mysql',
    host: 'localhost',
    port: 3306,
    username: 'root',
    password: '',
    database: 'gym_management',
    entities: [User, Workout],
    synchronize: true,
  });

  try {
    await dataSource.initialize();
    console.log('Running seeds...');

    // Run user seeds
    const userSeed = new UserSeed();
    await userSeed.run(dataSource);

    console.log('Seeds completed successfully');
  } catch (error) {
    console.error('Error running seeds:', error);
  } finally {
    await dataSource.destroy();
  }
}

runSeed(); 