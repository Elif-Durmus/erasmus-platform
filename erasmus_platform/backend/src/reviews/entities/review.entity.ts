import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity({ name: 'reviews', schema: 'app' })
export class Review {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ name: 'user_id' }) userId: string;
  @ManyToOne(() => User) @JoinColumn({ name: 'user_id' }) user: User;
  @Column({ name: 'review_target_type', type: 'enum', enum: ['university', 'city'] })
  reviewTargetType: string;
  @Column({ name: 'university_id', nullable: true }) universityId?: string;
  @Column({ name: 'city_id', nullable: true }) cityId?: string;
  @Column({ nullable: true }) title?: string;
  @Column({ type: 'text' }) content: string;
  @Column({ name: 'is_anonymous', default: false }) isAnonymous: boolean;
  @Column({ name: 'helpful_count', default: 0 }) helpfulCount: number;
  @Column({ type: 'enum', enum: ['draft', 'published', 'hidden', 'deleted'], default: 'published' })
  status: string;
  @CreateDateColumn({ name: 'created_at' }) createdAt: Date;
  @UpdateDateColumn({ name: 'updated_at' }) updatedAt: Date;
}