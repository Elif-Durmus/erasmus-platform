import { Controller, Get, Post, Body, Param, Query, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { MessagesService } from './messages.service';

@Controller('messages')
@UseGuards(JwtAuthGuard)
export class MessagesController {
  constructor(private messagesService: MessagesService) {}

  @Get('conversations')
  getConversations(@CurrentUser() user: any) {
    return this.messagesService.getMyConversations(user.userId);
  }

  @Post('conversations/direct')
  startDirect(@CurrentUser() user: any, @Body('userId') targetId: string) {
    return this.messagesService.getOrCreateDirect(user.userId, targetId);
  }

  @Get('conversations/:id/messages')
  getMessages(@Param('id') id: string, @Query('page') page = 1) {
    return this.messagesService.getMessages(id, +page);
  }
}