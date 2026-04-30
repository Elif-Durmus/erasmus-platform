import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity({ name: 'questions', schema: 'app' })
export class Question {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ name: 'user_id' }) userId: string;
  @ManyToOne(() => User) @JoinColumn({ name: 'user_id' }) user: User;
  @Column({ length: 255 }) title: string;
  @Column({ type: 'text' }) content: string;
  @Column({ name: 'is_anonymous', default: false }) isAnonymous: boolean;
  @Column({ type: 'enum', enum: ['open', 'closed', 'hidden', 'deleted'], default: 'open' }) status: string;
  @Column({ name: 'view_count', default: 0 }) viewCount: number;
  @Column({ name: 'answer_count', default: 0 }) answerCount: number;
  @CreateDateColumn({ name: 'created_at' }) createdAt: Date;
  @UpdateDateColumn({ name: 'updated_at' }) updatedAt: Date;
}