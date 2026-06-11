import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from './user.entity';

@Entity({ name: 'user_exchanges', schema: 'app' })
export class UserExchange {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ name: 'user_id' }) userId: string;
  @ManyToOne(() => User) @JoinColumn({ name: 'user_id' }) user: User;
  @Column({ name: 'exchange_status', type: 'enum', enum: ['planning', 'accepted', 'ongoing', 'completed'] })
  exchangeStatus: string;
  @Column({ name: 'host_country_id', nullable: true }) hostCountryId: string;
  @Column({ name: 'host_city_id', nullable: true }) hostCityId: string;
  @Column({ name: 'host_university_id', nullable: true }) hostUniversityId: string;
  @Column({ type: 'enum', enum: ['fall', 'spring', 'summer', 'full_year'], nullable: true })
  term: string;
  @Column({ name: 'academic_year', nullable: true }) academicYear: string;
  @Column({ name: 'start_date', type: 'date', nullable: true }) startDate: string;
  @Column({ name: 'end_date', type: 'date', nullable: true }) endDate: string;
  @Column({ name: 'is_current', default: false }) isCurrent: boolean;
  @CreateDateColumn({ name: 'created_at' }) createdAt: Date;
  @UpdateDateColumn({ name: 'updated_at' }) updatedAt: Date;
}