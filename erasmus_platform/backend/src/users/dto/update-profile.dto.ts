import { IsOptional, IsString, MaxLength, IsInt, Min, Max } from 'class-validator';

export class UpdateProfileDto {
  @IsOptional() @IsString() @MaxLength(150)
  fullName?: string;

  @IsOptional() @IsString() @MaxLength(500)
  bio?: string;

  @IsOptional() @IsString()
  department?: string;

  @IsOptional() @IsString()
  studyLevel?: string;

  @IsOptional() @IsInt() @Min(1950) @Max(2010)
  birthYear?: number;
}