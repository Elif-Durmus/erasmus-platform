import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserProfile } from './entities/user-profile.entity';
import { UserExchange } from './entities/user-exchange.entity';
import { Country } from './entities/country.entity';
import { University } from './entities/university.entity';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { UserFollow } from './entities/user-follow.entity';
import { NotificationsService } from '../notifications/notifications.service';
import { Post } from '../posts/entities/post.entity';


@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(UserProfile)
    private profileRepo: Repository<UserProfile>,
    @InjectRepository(UserExchange)
    private exchangeRepo: Repository<UserExchange>,
    @InjectRepository(Country)
    private countryRepo: Repository<Country>,
    @InjectRepository(University)
    private universityRepo: Repository<University>,
    @InjectRepository(UserFollow) 
    private followRepo: Repository<UserFollow>,
    private notificationsService: NotificationsService,
    @InjectRepository(Post)
    private postRepo: Repository<Post>,
  ) {}

  async getProfile(userId: string) {
    const profile = await this.profileRepo.findOne({
      where: { userId },
      relations: ['user'],
    });
    if (!profile) throw new NotFoundException('Profil bulunamadı');
    return profile;
  }

  async getProfileByUsername(username: string) {
    const profile = await this.profileRepo.findOne({
      where: { username },
      relations: ['user'],
    });
    if (!profile) throw new NotFoundException('Kullanıcı bulunamadı');
    return profile;
  }

  async updateProfile(userId: string, dto: UpdateProfileDto) {
    await this.profileRepo.update({ userId }, dto);
    return this.getProfile(userId);
  }

  async updateProfilePhoto(userId: string, photoUrl: string) {
    await this.profileRepo.update({ userId }, { profilePhotoUrl: photoUrl });
    return this.getProfile(userId);
  }

  async searchUsers(query: string) {
    return this.profileRepo
      .createQueryBuilder('p')
      .leftJoinAndSelect('p.user', 'u')
      .where('p.username ILIKE :q OR p.full_name ILIKE :q', { q: `%${query}%` })
      .andWhere('u.status = :status', { status: 'active' })
      .take(20)
      .getMany();
  }

  async getExchanges(userId: string) {
    return this.exchangeRepo.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async createExchange(userId: string, data: any) {
    if (data.isCurrent) {
      await this.exchangeRepo.update({ userId }, { isCurrent: false });
    }
    const exchange = this.exchangeRepo.create({ ...data, userId });
    return this.exchangeRepo.save(exchange);
  }

  async deleteExchange(userId: string, exchangeId: string) {
    await this.exchangeRepo.delete({ id: exchangeId, userId });
    return { success: true };
  }

  async getCountries() {
    return this.countryRepo.find({ order: { name: 'ASC' } });
  }

  async getUniversities(countryId?: string) {
    const where = countryId ? { countryId } : {};
    return this.universityRepo.find({ where, order: { name: 'ASC' } });
  }

  async followUser(followerUserId: string, followedUsername: string) {
    const target = await this.profileRepo.findOne({
      where: { username: followedUsername },
    });
    if (!target) throw new NotFoundException('Kullanıcı bulunamadı');
    if (target.userId === followerUserId) {
      return { success: false, message: 'Kendini takip edemezsin' };
    }

    const existing = await this.followRepo.findOne({
      where: { followerUserId, followedUserId: target.userId },
    });
    if (existing) return { success: true, following: true };

    await this.followRepo.save(
      this.followRepo.create({
        followerUserId,
        followedUserId: target.userId,
      }),
    );

    return { success: true, following: true, followedUserId: target.userId };
  }

  async unfollowUser(followerUserId: string, followedUsername: string) {
    const target = await this.profileRepo.findOne({
      where: { username: followedUsername },
    });
    if (!target) throw new NotFoundException('Kullanıcı bulunamadı');

    await this.followRepo.delete({
      followerUserId,
      followedUserId: target.userId,
    });
    return { success: true, following: false };
  }

  async getFollowStats(username: string, currentUserId?: string) {
    const profile = await this.profileRepo.findOne({ where: { username } });
    if (!profile) throw new NotFoundException('Kullanıcı bulunamadı');

    const followers = await this.followRepo.count({
      where: { followedUserId: profile.userId },
    });
    const following = await this.followRepo.count({
      where: { followerUserId: profile.userId },
    });

    let isFollowing = false;
    if (currentUserId) {
      const rel = await this.followRepo.findOne({
        where: { followerUserId: currentUserId, followedUserId: profile.userId },
      });
      isFollowing = !!rel;
    }

    return { followers, following, isFollowing };
  }

  async getFollowers(username: string) {
    const profile = await this.profileRepo.findOne({ where: { username } });
    if (!profile) throw new NotFoundException('Kullanıcı bulunamadı');

    const follows = await this.followRepo.find({
      where: { followedUserId: profile.userId },
      order: { createdAt: 'DESC' },
    });

    // Takipçilerin profil bilgilerini getir
    const followerIds = follows.map((f) => f.followerUserId);
    if (followerIds.length === 0) return [];

    return this.profileRepo
      .createQueryBuilder('p')
      .where('p.user_id IN (:...ids)', { ids: followerIds })
      .getMany();
  }

  async getFollowing(username: string) {
    const profile = await this.profileRepo.findOne({ where: { username } });
    if (!profile) throw new NotFoundException('Kullanıcı bulunamadı');

    const follows = await this.followRepo.find({
      where: { followerUserId: profile.userId },
      order: { createdAt: 'DESC' },
    });

    const followedIds = follows.map((f) => f.followedUserId);
    if (followedIds.length === 0) return [];

    return this.profileRepo
      .createQueryBuilder('p')
      .where('p.user_id IN (:...ids)', { ids: followedIds })
      .getMany();
  }

  async getUserPosts(username: string) {
    const profile = await this.profileRepo.findOne({ where: { username } });
    if (!profile) throw new NotFoundException('Kullanıcı bulunamadı');

    return this.postRepo
      .createQueryBuilder('p')
      .leftJoinAndSelect('p.user', 'u')
      .leftJoinAndSelect('u.profile', 'profile')
      .where('p.user_id = :userId', { userId: profile.userId })
      .andWhere('p.status = :status', { status: 'published' })
      .orderBy('p.createdAt', 'DESC')
      .getMany();
  }
}