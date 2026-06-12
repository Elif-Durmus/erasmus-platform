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
    const participations = await this.participantRepo.find({
      where: { userId, leftAt: null as any },
      relations: ['conversation'],
    });

    const result = await Promise.all(
      participations.map(async (p) => {
        const conv = p.conversation;

        const otherParticipant = await this.participantRepo
          .createQueryBuilder('cp')
          .leftJoinAndSelect('cp.user', 'u')
          .leftJoinAndSelect('u.profile', 'profile')
          .where('cp.conversation_id = :convId', { convId: conv.id })
          .andWhere('cp.user_id != :userId', { userId })
          .getOne();

        return {
          conversation: conv,
          otherUser: otherParticipant?.user
            ? {
                id: otherParticipant.user.id,
                profile: (otherParticipant.user as any).profile,
              }
            : null,
        };
      }),
    );

    result.sort((a, b) => {
      const aTime = a.conversation.lastMessageAt
        ? new Date(a.conversation.lastMessageAt).getTime()
        : 0;
      const bTime = b.conversation.lastMessageAt
        ? new Date(b.conversation.lastMessageAt).getTime()
        : 0;
      return bTime - aTime;
    });

    return result;
  }

  async getOrCreateDirect(userId1: string, userId2: string) {
    // Var olan DM'i bul: iki kullanıcının da katılımcı olduğu direct konuşma
    const existing = await this.convRepo
      .createQueryBuilder('c')
      .innerJoin(
        ConversationParticipant,
        'p1',
        'p1.conversation_id = c.id AND p1.user_id = :u1',
        { u1: userId1 },
      )
      .innerJoin(
        ConversationParticipant,
        'p2',
        'p2.conversation_id = c.id AND p2.user_id = :u2',
        { u2: userId2 },
      )
      .where('c.conversation_type = :type', { type: 'direct' })
      .getOne();

    if (existing) return existing;

    const conv = this.convRepo.create({
      conversationType: 'direct',
      createdBy: userId1,
    });
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