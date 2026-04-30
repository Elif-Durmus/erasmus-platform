// src/auth/auth.service.ts
import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { User } from '../users/entities/user.entity';
import { UserProfile } from '../users/entities/user-profile.entity';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private userRepo: Repository<User>,
    @InjectRepository(UserProfile)
    private profileRepo: Repository<UserProfile>,
    private jwtService: JwtService,
  ) {}

  async register(dto: RegisterDto) {
    const existing = await this.userRepo.findOne({ where: { email: dto.email } });
    if (existing) throw new ConflictException('Bu e-posta zaten kayıtlı');

    const existingUsername = await this.profileRepo.findOne({ where: { username: dto.username } });
    if (existingUsername) throw new ConflictException('Bu kullanıcı adı alınmış');

    const passwordHash = await bcrypt.hash(dto.password, 12);

    const user = this.userRepo.create({ email: dto.email, passwordHash });
    await this.userRepo.save(user);

    const profile = this.profileRepo.create({
      userId: user.id,
      fullName: dto.fullName,
      username: dto.username,
    });
    await this.profileRepo.save(profile);

    const token = this.jwtService.sign({ sub: user.id, email: user.email, role: user.role });
    return { token, user: { id: user.id, email: user.email, username: dto.username } };
  }

  async login(dto: LoginDto) {
    const user = await this.userRepo.findOne({ where: { email: dto.email }, relations: ['profile'] });
    if (!user) throw new UnauthorizedException('E-posta veya şifre hatalı');

    const match = await bcrypt.compare(dto.password, user.passwordHash);
    if (!match) throw new UnauthorizedException('E-posta veya şifre hatalı');

    await this.userRepo.update(user.id, { lastLoginAt: new Date() });

    const token = this.jwtService.sign({ sub: user.id, email: user.email, role: user.role });
    return {
      token,
      user: {
        id: user.id,
        email: user.email,
        username: user.profile?.username,
        fullName: user.profile?.fullName,
        profilePhotoUrl: user.profile?.profilePhotoUrl,
      },
    };
  }
}