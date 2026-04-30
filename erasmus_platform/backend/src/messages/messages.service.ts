import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Message } from './entities/message.entity';
import { Conversation } from './entities/conversation.entity';
import { ConversationParticipant } from './entities/conversation-participant.entity';

@Injectable()
export class MessagesService {
  constructor(
    @InjectRepository(Message) private messageRepo: Repository<Message>,
    @InjectRepository(Conversation) private convRepo: Repository<Conversation>,
    @InjectRepository(ConversationParticipant) private participantRepo: Repository<ConversationParticipant>,
  ) {}

  async getMyConversations(userId: string) {
    return this.participantRepo.find({
      where: { userId, leftAt: null as any },
      relations: ['conversation'],
      order: { conversation: { lastMessageAt: 'DESC' } as any },
    });
  }

  async getOrCreateDirect(userId1: string, userId2: string) {
    // Var olan DM'i bul
    const existing = await this.convRepo.createQueryBuilder('c')
      .innerJoin('app.conversation_participants', 'p1', 'p1.conversation_id = c.id AND p1.user_id = :u1', { u1: userId1 })
      .innerJoin('app.conversation_participants', 'p2', 'p2.conversation_id = c.id AND p2.user_id = :u2', { u2: userId2 })
      .where('c.conversation_type = :type', { type: 'direct' })
      .getOne();

    if (existing) return existing;

    const conv = this.convRepo.create({ conversationType: 'direct', createdBy: userId1 });
    await this.convRepo.save(conv);

    await this.participantRepo.save([
      this.participantRepo.create({ conversationId: conv.id, userId: userId1 }),
      this.participantRepo.create({ conversationId: conv.id, userId: userId2 }),
    ]);

    return conv;
  }

  async getMessages(conversationId: string, page = 1) {
    return this.messageRepo.find({
      where: { conversationId, isDeleted: false },
      relations: ['sender', 'sender.profile'],
      order: { createdAt: 'DESC' },
      skip: (page - 1) * 30,
      take: 30,
    });
  }

  async saveMessage(data: { conversationId: string; senderId: string; content: string }) {
    const msg = this.messageRepo.create({ ...data, messageType: 'text' });
    const saved = await this.messageRepo.save(msg);
    await this.convRepo.update(data.conversationId, { lastMessageAt: new Date() });
    return saved;
  }
}