import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Post } from './entities/post.entity';
import { PostComment } from './entities/post-comment.entity';
import { CreatePostDto } from './dto/create-post.dto';
import { PostLike } from './entities/post-like.entity';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class PostsService {
  constructor(
    @InjectRepository(Post)
    private postRepo: Repository<Post>,
    @InjectRepository(PostComment)
    private postCommentRepo: Repository<PostComment>,
    @InjectRepository(PostLike)
    private postLikeRepo: Repository<PostLike>,
    private notificationsService: NotificationsService,
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

    // Bildirim oluştur
    const post = await this.postRepo.findOne({ where: { id: postId } });
    if (post) {
      await this.notificationsService.create({
        userId: post.userId,
        actorUserId: userId,
        notificationType: 'post_like',
        referenceType: 'post',
        referenceId: postId,
        title: 'Yeni beğeni',
        body: 'Bir gönderini beğendi',
      });
    }

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

    // Bildirim oluştur
    const post = await this.postRepo.findOne({ where: { id: postId } });
    if (post) {
      await this.notificationsService.create({
        userId: post.userId,
        actorUserId: userId,
        notificationType: 'post_comment',
        referenceType: 'post',
        referenceId: postId,
        title: 'Yeni yorum',
        body: 'Gönderine yorum yaptı',
      });
    }

    return saved;
  }

  async searchPosts(query: string) {
    return this.postRepo
      .createQueryBuilder('p')
      .leftJoinAndSelect('p.user', 'u')
      .leftJoinAndSelect('u.profile', 'profile')
      .where('p.title ILIKE :q OR p.content ILIKE :q', { q: `%${query}%` })
      .andWhere('p.status = :status', { status: 'published' })
      .andWhere('p.visibility = :visibility', { visibility: 'public' })
      .orderBy('p.createdAt', 'DESC')
      .take(20)
      .getMany();
  }

  async deleteComment(userId: string, commentId: string) {
    const comment = await this.postCommentRepo.findOne({
      where: { id: commentId },
    });
    if (!comment) {
      throw new NotFoundException('Yorum bulunamadı');
    }
    // Sadece kendi yorumunu silebilir
    if (comment.userId !== userId) {
      throw new ForbiddenException('Bu yorumu silme yetkiniz yok');
    }

    await this.postCommentRepo.delete({ id: commentId });
    await this.postRepo.decrement({ id: comment.postId }, 'commentCount', 1);

    return { success: true };
  }
}