import {
  Controller, Post, UseInterceptors, UploadedFile, UseGuards, BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { memoryStorage } from 'multer';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { UploadService } from './upload.service';

@Controller('upload')
@UseGuards(JwtAuthGuard)
export class UploadController {
  constructor(private uploadService: UploadService) {}

  @Post('image')
  @UseInterceptors(FileInterceptor('file', { storage: memoryStorage() }))
  async uploadImage(@UploadedFile() file: Express.Multer.File) {
    if (!file) throw new BadRequestException('Dosya bulunamadı');
    if (!file.mimetype.startsWith('image/')) throw new BadRequestException('Sadece resim yüklenebilir');
    const url = await this.uploadService.uploadImage(file);
    return { url };
  }
}