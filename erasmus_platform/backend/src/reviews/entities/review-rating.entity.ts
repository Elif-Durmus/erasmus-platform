import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, OneToOne, JoinColumn } from 'typeorm';
import { Review } from './review.entity';

@Entity({ name: 'review_ratings', schema: 'app' })
export class ReviewRating {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ name: 'review_id' }) reviewId: string;
  @OneToOne(() => Review) @JoinColumn({ name: 'review_id' }) review: Review;
  @Column({ name: 'academic_score', type: 'smallint', nullable: true }) academicScore: number;
  @Column({ name: 'social_score', type: 'smallint', nullable: true }) socialScore: number;
  @Column({ name: 'housing_score', type: 'smallint', nullable: true }) housingScore: number;
  @Column({ name: 'transport_score', type: 'smallint', nullable: true }) transportScore: number;
  @Column({ name: 'safety_score', type: 'smallint', nullable: true }) safetyScore: number;
  @Column({ name: 'cost_score', type: 'smallint', nullable: true }) costScore: number;
  @Column({ name: 'support_score', type: 'smallint', nullable: true }) supportScore: number;
  @CreateDateColumn({ name: 'created_at' }) createdAt: Date;
}