import { Controller, Get, Post, Body, Param, Query, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { QuestionsService } from './questions.service';

@Controller('questions')
export class QuestionsController {
  constructor(private questionsService: QuestionsService) {}

  @Get()
  getAll(@Query('page') page = 1) {
    return this.questionsService.getQuestions(+page);
  }

  @Get(':id')
  getOne(@Param('id') id: string) {
    return this.questionsService.getQuestion(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  create(@CurrentUser() user: any, @Body() body: { title: string; content: string; isAnonymous?: boolean }) {
    return this.questionsService.createQuestion(user.userId, body);
  }

  @Post(':id/answers')
  @UseGuards(JwtAuthGuard)
  answer(@CurrentUser() user: any, @Param('id') id: string, @Body('content') content: string) {
    return this.questionsService.createAnswer(user.userId, id, content);
  }
}