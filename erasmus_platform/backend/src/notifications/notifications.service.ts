import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Notification } from './entities/notification.entity';

@Injectable()
export class NotificationsService {
  constructor(
    @InjectRepository(Notification)
    private notificationRepo: Repository<Notification>,
  ) {}

  async create(data: {
    userId: string;
    notificationType: string;
    referenceType?: string;
    referenceId?: string;
    actorUserId?: string;
    title?: string;
    body?: string;
  }) {
    // Kendine bildirim gönderme
    if (data.userId === data.actorUserId) return null;
    const notification = this.notificationRepo.create(data);
    return this.notificationRepo.save(notification);
  }

  async getMyNotifications(userId: string) {
    return this.notificationRepo.find({
      where: { userId },
      relations: ['actor', 'actor.profile'],
      order: { createdAt: 'DESC' },
      take: 50,
    });
  }

  async getUnreadCount(userId: string) {
    const count = await this.notificationRepo.count({
      where: { userId, isRead: false },
    });
    return { count };
  }

  async markAsRead(userId: string, notificationId: string) {
    await this.notificationRepo.update(
      { id: notificationId, userId },
      { isRead: true },
    );
    return { success: true };
  }

  async markAllAsRead(userId: string) {
    await this.notificationRepo.update(
      { userId, isRead: false },
      { isRead: true },
    );
    return { success: true };
  }
}