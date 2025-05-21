import { DataSource } from 'typeorm';
import { User } from '../../modules/users/entities/user.entitiy';
import { Role } from '../../modules/auth/enums/roles.enum';
import * as bcrypt from 'bcrypt';

export class UserSeed {
  public async run(dataSource: DataSource): Promise<void> {
    const userRepository = dataSource.getRepository(User);

    // Create admin user
    const adminUser = new User();
    adminUser.email = 'admin@gym.com';
    adminUser.password = await bcrypt.hash('admin123', 10);
    adminUser.name = 'Admin User';
    adminUser.role = Role.ADMIN;

    // Save admin user
    await userRepository.save(adminUser);
    console.log('Admin user created successfully');
  }
} 