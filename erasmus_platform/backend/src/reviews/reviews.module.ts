import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Review } from './entities/review.entity';
import { ReviewRating } from './entities/review-rating.entity';
import { ReviewsService } from './reviews.service';
import { ReviewsController } from './reviews.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Review, ReviewRating])],
  controllers: [ReviewsController],
  providers: [ReviewsService],
})
export class ReviewsModule {}