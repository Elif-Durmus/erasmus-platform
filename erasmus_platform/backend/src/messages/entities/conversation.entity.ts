import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'conversations', schema: 'app' })
export class Conversation {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ name: 'conversation_type', type: 'enum', enum: ['direct', 'group'] }) conversationType: string;
  @Column({ name: 'created_by', nullable: true }) createdBy: string;
  @Column({ name: 'last_message_at', nullable: true }) lastMessageAt: Date;
  @CreateDateColumn({ name: 'created_at' }) createdAt: Date;
  @UpdateDateColumn({ name: 'updated_at' }) updatedAt: Date;
}