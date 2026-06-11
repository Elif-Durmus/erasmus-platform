import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Question } from './entities/question.entity';
import { Answer } from './entities/answer.entity';
import { NotificationsService } from '../notifications/notifications.service';


@Injectable()
export class QuestionsService {
  constructor(
    @InjectRepository(Question) private questionRepo: Repository<Question>,
    @InjectRepository(Answer) private answerRepo: Repository<Answer>,
    private notificationsService: NotificationsService,
  ) {}

  async getQuestions(page = 1, limit = 20) {
    const [questions, total] = await this.questionRepo.findAndCount({
      where: { status: 'open' },
      relations: ['user', 'user.profile'],
      order: { createdAt: 'DESC' },
      skip: (page - 1) * limit,
      take: limit,
    });
    return { questions, total };
  }

  async getQuestion(id: string) {
    const q = await this.questionRepo.findOne({
      where: { id },
      relations: ['user', 'user.profile'],
    });
    const answers = await this.answerRepo.find({
      where: { questionId: id },
      relations: ['user', 'user.profile'],
      order: { isAccepted: 'DESC', helpfulCount: 'DESC' },
    });
    return { ...q, answers };
  }

  async createQuestion(userId: string, data: { title: string; content: string; isAnonymous?: boolean }) {
    const q = this.questionRepo.create({ ...data, userId });
    return this.questionRepo.save(q);
  }


  async createAnswer(userId: string, questionId: string, content: string) {
    const answer = this.answerRepo.create({ userId, questionId, content });
    const saved = await this.answerRepo.save(answer);
    await this.questionRepo.increment({ id: questionId }, 'answerCount', 1);

    const question = await this.questionRepo.findOne({ where: { id: questionId } });
    if (question) {
      await this.notificationsService.create({
        userId: question.userId,
        actorUserId: userId,
        notificationType: 'question_answer',
        referenceType: 'question',
        referenceId: questionId,
        title: 'Yeni cevap',
        body: 'Sorunu cevapladı',
      });
    }

    return saved;
  }

  async searchQuestions(query: string) {
    return this.questionRepo
      .createQueryBuilder('q')
      .leftJoinAndSelect('q.user', 'u')
      .leftJoinAndSelect('u.profile', 'profile')
      .where('q.title ILIKE :query OR q.content ILIKE :query', { query: `%${query}%` })
      .andWhere('q.status = :status', { status: 'open' })
      .orderBy('q.createdAt', 'DESC')
      .take(20)
      .getMany();
  }

}