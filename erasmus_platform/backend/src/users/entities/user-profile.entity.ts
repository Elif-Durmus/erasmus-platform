// src/users/entities/user-profile.entity.ts
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, OneToOne, JoinColumn } from 'typeorm';
import { User } from './user.entity';

@Entity({ name: 'user_profiles', schema: 'app' })
export class UserProfile {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id' })
  userId: string;

  @OneToOne(() => User, (user) => user.profile)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({ name: 'full_name', length: 150 })
  fullName: string;

  @Column({ length: 50, unique: true })
  username: string;

  @Column({ name: 'profile_photo_url', nullable: true })
  profilePhotoUrl: string;

  @Column({ nullable: true, type: 'text' })
  bio: string;

  @Column({ name: 'birth_year', nullable: true, type: 'smallint' })
  birthYear: number;

  @Column({ nullable: true })
  department: string;

  @Column({ name: 'study_level', nullable: true })
  studyLevel: string;

  @Column({
    type: 'enum',
    enum: ['public', 'verified_only', 'followers_only', 'private'],
    default: 'public',
  })
  visibility: string;

  @Column({ name: 'is_verified_student', default: false })
  isVerifiedStudent: boolean;

  @Column({ name: 'is_mentor', default: false })
  isMentor: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}