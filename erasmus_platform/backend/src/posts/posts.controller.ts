import { Controller, Get, Post, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { PostsService } from './posts.service';
import { CreatePostDto } from './dto/create-post.dto';

@Controller('posts')
export class PostsController {
  constructor(private postsService: PostsService) {}

  @Get()
  getFeed(@Query('page') page = 1, @Query('limit') limit = 20) {
    return this.postsService.getFeed(+page, +limit);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  createPost(@CurrentUser() user: any, @Body() dto: CreatePostDto) {
    return this.postsService.createPost(user.userId, dto);
  }

  @Get(':id')
  getPost(@Param('id') id: string) {
    return this.postsService.getPost(id);
  }

  @Post(':id/like')
  @UseGuards(JwtAuthGuard)
  likePost(@CurrentUser() user: any, @Param('id') id: string) {
    return this.postsService.likePost(id, user.userId);
  }

  @Delete(':id/like')
  @UseGuards(JwtAuthGuard)
  unlikePost(@CurrentUser() user: any, @Param('id') id: string) {
    return this.postsService.unlikePost(id, user.userId);
  }

  @Get(':id/comments')
  getComments(@Param('id') id: string) {
    return this.postsService.getComments(id);
  }

  @Post(':id/comments')
  @UseGuards(JwtAuthGuard)
  createComment(
    @CurrentUser() user: any,
    @Param('id') id: string,
    @Body('content') content: string,
  ) {
    return this.postsService.createComment(user.userId, id, content);
  }

  @Get(':id/liked')
  @UseGuards(JwtAuthGuard)
  isLiked(@CurrentUser() user: any, @Param('id') id: string) {
    return this.postsService.isLiked(id, user.userId);
  }
}