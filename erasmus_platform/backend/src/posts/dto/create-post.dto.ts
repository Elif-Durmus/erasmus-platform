import { IsString, IsEnum, IsOptional, MinLength } from 'class-validator';

export class CreatePostDto {
  @IsEnum(['experience', 'advice', 'warning', 'housing', 'event', 'academic'])
  postType: string;

  @IsOptional() @IsString()
  title?: string;

  @IsString() @MinLength(10)
  content: string;
}