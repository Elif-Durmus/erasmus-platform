import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity({ name: 'universities', schema: 'app' })
export class University {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column() name: string;
  @Column({ name: 'short_name', nullable: true }) shortName: string;
  @Column({ name: 'country_id' }) countryId: string;
  @Column({ name: 'city_id', nullable: true }) cityId: string;
}