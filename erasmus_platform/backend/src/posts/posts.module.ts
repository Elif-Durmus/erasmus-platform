import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Post } from './entities/post.entity';
import { PostComment } from './entities/post-comment.entity';
import { PostLike } from './entities/post-like.entity';
import { PostsService } from './posts.service';
import { PostsController } from './posts.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Post, PostComment, PostLike])],
  controllers: [PostsController],
  providers: [PostsService],
})
export class PostsModule {}