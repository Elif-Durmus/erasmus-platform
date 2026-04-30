import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Post } from './entities/post.entity';
import { CreatePostDto } from './dto/create-post.dto';

@Injectable()
export class PostsService {
  constructor(
    @InjectRepository(Post)
    private postRepo: Repository<Post>,
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
}