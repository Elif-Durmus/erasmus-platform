import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity({ name: 'countries', schema: 'app' })
export class Country {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column() name: string;
  @Column({ name: 'iso_code' }) isoCode: string;
  @Column({ nullable: true }) continent: string;
}