import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Question } from './question.entity';

@Entity({ name: 'answers', schema: 'app' })
export class Answer {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ name: 'question_id' }) questionId: string;
  @ManyToOne(() => Question) @JoinColumn({ name: 'question_id' }) question: Question;
  @Column({ name: 'user_id' }) userId: string;
  @ManyToOne(() => User) @JoinColumn({ name: 'user_id' }) user: User;
  @Column({ type: 'text' }) content: string;
  @Column({ name: 'is_accepted', default: false }) isAccepted: boolean;
  @Column({ name: 'helpful_count', default: 0 }) helpfulCount: number;
  @CreateDateColumn({ name: 'created_at' }) createdAt: Date;
}