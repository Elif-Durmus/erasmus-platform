import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { v2 as cloudinary } from 'cloudinary';

@Injectable()
export class UploadService {
  constructor(private config: ConfigService) {
    cloudinary.config({
      cloud_name: config.get('CLOUDINARY_CLOUD_NAME'),
      api_key: config.get('CLOUDINARY_API_KEY'),
      api_secret: config.get('CLOUDINARY_API_SECRET'),
    });
  }

  async uploadImage(file: Express.Multer.File, folder = 'erasmus'): Promise<string> {
    return new Promise((resolve, reject) => {
      cloudinary.uploader.upload_stream(
        {
          folder,
          transformation: [{ width: 500, height: 500, crop: 'fill', quality: 'auto' }],
        },
        (error, result) => {
          if (error) reject(error);
          else resolve(result!.secure_url);
        },
      ).end(file.buffer);
    });
  }
}