import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, OneToOne } from 'typeorm';
import { UserProfile } from './user-profile.entity';

@Entity({ name: 'users', schema: 'app' })
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'citext', unique: true })
  email: string;

  @Column({ name: 'password_hash', nullable: true })
  passwordHash: string;

  @Column({ name: 'auth_provider', default: 'email' })
  authProvider: string;

  @Column({ type: 'enum', enum: ['student', 'mentor', 'coordinator', 'admin'], default: 'student' })
  role: string;

  @Column({ type: 'enum', enum: ['active', 'suspended', 'deleted', 'pending'], default: 'active' })
  status: string;

  @Column({ name: 'is_email_verified', default: false })
  isEmailVerified: boolean;

  @Column({ name: 'is_profile_completed', default: false })
  isProfileCompleted: boolean;

  @Column({ name: 'last_login_at', nullable: true })
  lastLoginAt: Date;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @OneToOne(() => UserProfile, (profile) => profile.user)
  profile: UserProfile;
}