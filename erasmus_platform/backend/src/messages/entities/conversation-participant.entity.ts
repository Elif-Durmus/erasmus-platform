import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Conversation } from './conversation.entity';
import { User } from '../../users/entities/user.entity';

@Entity({ name: 'conversation_participants', schema: 'app' })
export class ConversationParticipant {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ name: 'conversation_id' }) conversationId: string;
  @ManyToOne(() => Conversation) @JoinColumn({ name: 'conversation_id' }) conversation: Conversation;
  @Column({ name: 'user_id' }) userId: string;
  @ManyToOne(() => User) @JoinColumn({ name: 'user_id' }) user: User;
  @Column({ name: 'left_at', nullable: true }) leftAt: Date;
  @CreateDateColumn({ name: 'joined_at' }) joinedAt: Date;
}