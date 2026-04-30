import { Controller, Get, Post, Body, Param, Query, UseGuards } from '@nestjs/common';
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
}