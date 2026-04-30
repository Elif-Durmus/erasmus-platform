import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity({ name: 'messages', schema: 'app' })
export class Message {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ name: 'conversation_id' }) conversationId: string;
  @Column({ name: 'sender_id' }) senderId: string;
  @ManyToOne(() => User) @JoinColumn({ name: 'sender_id' }) sender: User;
  @Column({ name: 'message_type', default: 'text' }) messageType: string;
  @Column({ type: 'text', nullable: true }) content: string;
  @Column({ name: 'is_deleted', default: false }) isDeleted: boolean;
  @CreateDateColumn({ name: 'created_at' }) createdAt: Date;
}