import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity({ name: 'notifications', schema: 'app' })
export class Notification {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ name: 'user_id' }) userId: string;
  @Column({ name: 'notification_type' }) notificationType: string;
  @Column({ name: 'reference_type', nullable: true }) referenceType: string;
  @Column({ name: 'reference_id', nullable: true }) referenceId: string;
  @Column({ name: 'actor_user_id', nullable: true }) actorUserId: string;
  @ManyToOne(() => User) @JoinColumn({ name: 'actor_user_id' }) actor: User;
  @Column({ nullable: true }) title: string;
  @Column({ type: 'text', nullable: true }) body: string;
  @Column({ name: 'is_read', default: false }) isRead: boolean;
  @CreateDateColumn({ name: 'created_at' }) createdAt: Date;
}