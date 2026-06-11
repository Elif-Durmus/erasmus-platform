// src/app.module.ts
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { PostsModule } from './posts/posts.module';
import { QuestionsModule } from './questions/questions.module';
import { MessagesModule } from './messages/messages.module';
import { UploadModule } from './upload/upload.module';
import { NotificationsModule } from './notifications/notifications.module';
import { ReviewsModule } from './reviews/reviews.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (config: ConfigService) => {
        const databaseUrl = config.get<string>('DATABASE_URL');

        if (databaseUrl) {
          // Railway / production ortamı
          return {
            type: 'postgres',
            url: databaseUrl,
            schema: 'app',
            autoLoadEntities: true,
            synchronize: false,
            ssl: { rejectUnauthorized: false },
          };
        }

        // Lokal geliştirme ortamı
        return {
          type: 'postgres',
          host: config.get('DATABASE_HOST'),
          port: parseInt(config.get('DATABASE_PORT') ?? '5432'),
          username: config.get('DATABASE_USER'),
          password: config.get('DATABASE_PASSWORD'),
          database: config.get('DATABASE_NAME'),
          schema: 'app',
          autoLoadEntities: true,
          synchronize: false,
        };
      },
      inject: [ConfigService],
    }),
    AuthModule,
    UsersModule,
    PostsModule,
    QuestionsModule,
    MessagesModule,
    UploadModule,
    NotificationsModule,
    ReviewsModule,
  ],
})
export class AppModule {}