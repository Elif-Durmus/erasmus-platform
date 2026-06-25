import {
  Controller, Get, Patch, Post, Delete, Body, Param, Query, UseGuards,
  UseInterceptors, UploadedFile, BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { memoryStorage } from 'multer';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { UsersService } from './users.service';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { UploadService } from '../upload/upload.service';

@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(
    private usersService: UsersService,
    private uploadService: UploadService,
  ) {}

  @Get('me')
  getMe(@CurrentUser() user: any) {
    return this.usersService.getProfile(user.userId);
  }

  @Get('me/exchanges')
  getExchanges(@CurrentUser() user: any) {
    return this.usersService.getExchanges(user.userId);
  }

  @Post('me/exchanges')
  createExchange(@CurrentUser() user: any, @Body() body: any) {
    return this.usersService.createExchange(user.userId, body);
  }

  @Delete('me/exchanges/:id')
  deleteExchange(@CurrentUser() user: any, @Param('id') id: string) {
    return this.usersService.deleteExchange(user.userId, id);
  }

  @Post('me/photo')
  @UseInterceptors(FileInterceptor('file', { storage: memoryStorage() }))
  async uploadPhoto(
    @CurrentUser() user: any,
    @UploadedFile() file: Express.Multer.File,
  ) {
    if (!file) throw new BadRequestException('Dosya bulunamadı');
    const url = await this.uploadService.uploadImage(file, 'erasmus/profiles');
    return this.usersService.updateProfilePhoto(user.userId, url);
  }

  @Patch('me')
  updateMe(@CurrentUser() user: any, @Body() dto: UpdateProfileDto) {
    return this.usersService.updateProfile(user.userId, dto);
  }

  @Get('search')
  search(@Query('q') q: string) {
    if (!q || q.trim().length < 2) return [];
    return this.usersService.searchUsers(q.trim());
  }

  @Get('countries')
  getCountries() {
    return this.usersService.getCountries();
  }

  @Get('universities')
  getUniversities(@Query('countryId') countryId?: string) {
    return this.usersService.getUniversities(countryId);
  }

  @Post(':username/follow')
  follow(@CurrentUser() user: any, @Param('username') username: string) {
    return this.usersService.followUser(user.userId, username);
  }

  @Delete(':username/follow')
  unfollow(@CurrentUser() user: any, @Param('username') username: string) {
    return this.usersService.unfollowUser(user.userId, username);
  }

  @Get(':username/follow-stats')
  getFollowStats(@CurrentUser() user: any, @Param('username') username: string) {
    return this.usersService.getFollowStats(username, user.userId);
  }

  @Get(':username/followers')
  getFollowers(@Param('username') username: string) {
    return this.usersService.getFollowers(username);
  }

  @Get(':username/following')
  getFollowing(@Param('username') username: string) {
    return this.usersService.getFollowing(username);
  }

  @Get(':username/posts')
  getUserPosts(@Param('username') username: string) {
    return this.usersService.getUserPosts(username);
  }

  @Get(':username')
  getByUsername(@Param('username') username: string) {
    return this.usersService.getProfileByUsername(username);
  }
}