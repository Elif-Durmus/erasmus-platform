import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Post } from './post.entity';

@Entity({ name: 'post_likes', schema: 'app' })
export class PostLike {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ name: 'post_id' }) postId: string;
  @ManyToOne(() => Post) @JoinColumn({ name: 'post_id' }) post: Post;
  @Column({ name: 'user_id' }) userId: string;
  @ManyToOne(() => User) @JoinColumn({ name: 'user_id' }) user: User;
  @CreateDateColumn({ name: 'created_at' }) createdAt: Date;
}