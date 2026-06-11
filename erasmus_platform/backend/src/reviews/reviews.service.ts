import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Review } from './entities/review.entity';
import { ReviewRating } from './entities/review-rating.entity';

@Injectable()
export class ReviewsService {
  constructor(
    @InjectRepository(Review)
    private reviewRepo: Repository<Review>,
    @InjectRepository(ReviewRating)
    private ratingRepo: Repository<ReviewRating>,
  ) {}

  async getUniversityReviews(universityId: string) {
    const reviews = await this.reviewRepo.find({
      where: { universityId, reviewTargetType: 'university', status: 'published' },
      relations: ['user', 'user.profile'],
      order: { createdAt: 'DESC' },
    });

    const reviewsWithRatings = await Promise.all(
      reviews.map(async (review) => {
        const rating = await this.ratingRepo.findOne({
          where: { reviewId: review.id },
        });
        return { ...review, rating };
      }),
    );

    return reviewsWithRatings;
  }

  async getCityReviews(cityId: string) {
    const reviews = await this.reviewRepo.find({
      where: { cityId, reviewTargetType: 'city', status: 'published' },
      relations: ['user', 'user.profile'],
      order: { createdAt: 'DESC' },
    });

    const reviewsWithRatings = await Promise.all(
      reviews.map(async (review) => {
        const rating = await this.ratingRepo.findOne({
          where: { reviewId: review.id },
        });
        return { ...review, rating };
      }),
    );

    return reviewsWithRatings;
  }

  async createReview(userId: string, data: {
    reviewTargetType: string;
    universityId?: string;
    cityId?: string;
    title?: string;
    content: string;
    isAnonymous?: boolean;
    ratings?: {
      academicScore?: number;
      socialScore?: number;
      housingScore?: number;
      transportScore?: number;
      safetyScore?: number;
      costScore?: number;
      supportScore?: number;
    };
  }) {
    const review = new Review();
review.userId = userId;
review.reviewTargetType = data.reviewTargetType;
if (data.reviewTargetType === 'university') {
  review.universityId = data.universityId;
} else {
  review.cityId = data.cityId;
}
review.title = data.title;
review.content = data.content;
review.isAnonymous = data.isAnonymous ?? false;

const saved = await this.reviewRepo.save(review);

    if (data.ratings) {
      const rating = this.ratingRepo.create({
        reviewId: saved.id,
        ...data.ratings,
      });
      await this.ratingRepo.save(rating);
    }

    return saved;
  }

  async getUniversityAverages(universityId: string) {
    const reviews = await this.reviewRepo.find({
      where: { universityId, reviewTargetType: 'university', status: 'published' },
    });

    if (reviews.length === 0) {
      return { count: 0, averages: null };
    }

    const ratings = await Promise.all(
      reviews.map((r) => this.ratingRepo.findOne({ where: { reviewId: r.id } })),
    );

    const validRatings = ratings.filter((r) => r !== null);
    if (validRatings.length === 0) {
      return { count: reviews.length, averages: null };
    }

    const avg = (key: string) => {
      const vals = validRatings.map((r) => r![key]).filter((v) => v != null);
      if (vals.length === 0) return null;
      return Math.round((vals.reduce((a, b) => a + b, 0) / vals.length) * 10) / 10;
    };

    return {
      count: reviews.length,
      averages: {
        academic: avg('academicScore'),
        social: avg('socialScore'),
        housing: avg('housingScore'),
        transport: avg('transportScore'),
        safety: avg('safetyScore'),
        cost: avg('costScore'),
        support: avg('supportScore'),
      },
    };
  }
}