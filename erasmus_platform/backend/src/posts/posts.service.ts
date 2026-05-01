import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Post } from './entities/post.entity';
import { PostComment } from './entities/post-comment.entity';
import { CreatePostDto } from './dto/create-post.dto';
import { PostLike } from './entities/post-like.entity';

@Injectable()
export class PostsService {
  constructor(
    @InjectRepository(Post)
    private postRepo: Repository<Post>,
    @InjectRepository(PostComment)
    private postCommentRepo: Repository<PostComment>,
    @InjectRepository(PostLike)
    private postLikeRepo: Repository<PostLike>,
  ) {}

  async getFeed(page = 1, limit = 20) {
    const [posts, total] = await this.postRepo.findAndCount({
      where: { status: 'published', visibility: 'public' },
      relations: ['user', 'user.profile'],
      order: { createdAt: 'DESC' },
      skip: (page - 1) * limit,
      take: limit,
    });
    return { posts, total, page, limit };
  }

  async createPost(userId: string, dto: CreatePostDto) {
    const post = this.postRepo.create({ ...dto, userId });
    return this.postRepo.save(post);
  }

  async getPost(id: string) {
    return this.postRepo.findOne({
      where: { id },
      relations: ['user', 'user.profile'],
    });
  }

  async likePost(postId: string, userId: string) {
    const existing = await this.postLikeRepo.findOne({
      where: { postId, userId },
    });
    if (existing) return { success: true, liked: true };

    await this.postLikeRepo.save(
      this.postLikeRepo.create({ postId, userId }),
    );
    await this.postRepo.increment({ id: postId }, 'likeCount', 1);
    return { success: true, liked: true };
  }

  async unlikePost(postId: string, userId: string) {
    const existing = await this.postLikeRepo.findOne({
      where: { postId, userId },
    });
    if (!existing) return { success: true, liked: false };

    await this.postLikeRepo.delete({ postId, userId });
    await this.postRepo.decrement({ id: postId }, 'likeCount', 1);
    return { success: true, liked: false };
  }

  async isLiked(postId: string, userId: string) {
    const existing = await this.postLikeRepo.findOne({
      where: { postId, userId },
    });
    return { liked: !!existing };
  }

  async getComments(postId: string) {
    return this.postCommentRepo.find({
      where: { postId, status: 'published' as any },
      relations: ['user', 'user.profile'],
      order: { createdAt: 'ASC' },
    });
  }

  async createComment(userId: string, postId: string, content: string) {
    const comment = this.postCommentRepo.create({ userId, postId, content });
    const saved = await this.postCommentRepo.save(comment);
    await this.postRepo.increment({ id: postId }, 'commentCount', 1);
    return saved;
  }
}