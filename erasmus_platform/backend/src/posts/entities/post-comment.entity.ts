import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Post } from './post.entity';

@Entity({ name: 'post_comments', schema: 'app' })
export class PostComment {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ name: 'post_id' }) postId: string;
  @ManyToOne(() => Post) @JoinColumn({ name: 'post_id' }) post: Post;
  @Column({ name: 'user_id' }) userId: string;
  @ManyToOne(() => User) @JoinColumn({ name: 'user_id' }) user: User;
  @Column({ name: 'parent_comment_id', nullable: true }) parentCommentId: string;
  @Column({ type: 'text' }) content: string;
  @Column({ name: 'like_count', default: 0 }) likeCount: number;
  @Column({ type: 'enum', enum: ['draft', 'published', 'hidden', 'deleted'], default: 'published' }) status: string;
  @CreateDateColumn({ name: 'created_at' }) createdAt: Date;
  @UpdateDateColumn({ name: 'updated_at' }) updatedAt: Date;
}