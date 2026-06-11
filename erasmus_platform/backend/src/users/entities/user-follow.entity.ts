import { Entity, PrimaryColumn, CreateDateColumn } from 'typeorm';

@Entity({ name: 'user_follows', schema: 'app' })
export class UserFollow {
  @PrimaryColumn({ name: 'follower_user_id' }) followerUserId: string;
  @PrimaryColumn({ name: 'followed_user_id' }) followedUserId: string;
  @CreateDateColumn({ name: 'created_at' }) createdAt: Date;
}