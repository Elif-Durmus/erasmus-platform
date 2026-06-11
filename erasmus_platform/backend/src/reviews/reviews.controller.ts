import { Controller, Get, Post, Body, Param, Query, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { ReviewsService } from './reviews.service';

@Controller('reviews')
export class ReviewsController {
  constructor(private reviewsService: ReviewsService) {}

  @Get('university/:id')
  getUniversityReviews(@Param('id') id: string) {
    return this.reviewsService.getUniversityReviews(id);
  }

  @Get('university/:id/averages')
  getUniversityAverages(@Param('id') id: string) {
    return this.reviewsService.getUniversityAverages(id);
  }

  @Get('city/:id')
  getCityReviews(@Param('id') id: string) {
    return this.reviewsService.getCityReviews(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  createReview(@CurrentUser() user: any, @Body() body: any) {
    return this.reviewsService.createReview(user.userId, body);
  }
}