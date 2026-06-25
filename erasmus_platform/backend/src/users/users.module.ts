import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserProfile } from './entities/user-profile.entity';
import { UserExchange } from './entities/user-exchange.entity';
import { Country } from './entities/country.entity';
import { University } from './entities/university.entity';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
import { UploadModule } from '../upload/upload.module';
import { UserFollow } from './entities/user-follow.entity';
import { NotificationsModule } from '../notifications/notifications.module';
import { Post } from '../posts/entities/post.entity';


@Module({
  imports: [
    TypeOrmModule.forFeature([UserProfile, UserExchange, UserFollow, Country, University, Post]),
    UploadModule,
    NotificationsModule,  
  ],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}