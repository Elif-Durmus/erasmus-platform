# Erasmus Öğrenci Platformu

Erasmus değişim programına katılan veya katılmayı planlayan öğrencilerin deneyimlerini paylaşabildiği, birbirlerine sorular sorabildiği, üniversiteleri değerlendirebildiği ve gerçek zamanlı iletişim kurabildiği kapsamlı bir mobil platform.

> **BM328 Bilgisayar Mühendisliği Tasarım Çalışması II** kapsamında geliştirilmiştir.
> Bilecik Şeyh Edebali Üniversitesi — Bilgisayar Mühendisliği Bölümü

---

## İçindekiler

- [Teknoloji Altyapısı](#teknoloji-altyapısı)
- [Özellikler](#özellikler)
- [Mimari](#mimari)
- [Kurulum](#kurulum)
- [Bulut Dağıtımı (Railway)](#bulut-dağıtımı-railway)
- [APK Oluşturma](#apk-oluşturma)
- [Proje Yapısı](#proje-yapısı)
- [API Uç Noktaları](#api-uç-noktaları)
- [Sık Karşılaşılan Sorunlar](#sık-karşılaşılan-sorunlar)

---

## Teknoloji Altyapısı

| Katman | Teknoloji |
|--------|-----------|
| Mobil (İstemci) | Flutter (Android) / Dart |
| Backend (Sunucu) | NestJS (Node.js) / TypeScript |
| Veritabanı | PostgreSQL |
| ORM | TypeORM |
| Kimlik Doğrulama | JWT (JSON Web Token) + bcrypt |
| Gerçek Zamanlı | Socket.IO (WebSocket) |
| Durum Yönetimi | Riverpod |
| HTTP İstemcisi | Dio |
| Yönlendirme | GoRouter |
| Medya Depolama | Cloudinary |
| Bulut Dağıtımı | Railway |
| Sürüm Kontrolü | Git / GitHub |

---

## Özellikler

- **Kimlik doğrulama** — JWT tabanlı güvenli kayıt ve giriş, bcrypt ile parola koruması
- **Profil yönetimi** — Cloudinary ile profil fotoğrafı, seçmeli bölüm/eğitim seviyesi, biyografi
- **Erasmus değişim bilgisi** — ülke/üniversite/dönem seçimi, takvim ile tarih seçimi
- **Gönderi akışı** — 6 kategori (Deneyim, Tavsiye, Uyarı, Konut, Etkinlik, Akademik)
- **Beğeni ve yorum** — yorum silme (sahiplik kontrolü ile), göreli zaman gösterimi
- **Soru-Cevap** — anonim soru sorma seçeneği
- **Üniversite değerlendirme** — 7 boyutlu puanlama (akademik, sosyal, konaklama, ulaşım, güvenlik, maliyet, destek), aranabilir üniversite listesi
- **Arama** — kullanıcı, gönderi ve soru arama (debounce ile)
- **Takip sistemi** — takip et/bırak, takipçi/takip/paylaşım listeleri
- **Bildirimler** — beğeni, yorum, cevap ve takip bildirimleri (okunmamış rozeti ile)
- **Gerçek zamanlı mesajlaşma** — Socket.IO ile anlık birebir sohbet
- **Splash screen** — oturum durumu kontrolü ile açılış ekranı
- 30 ülke ve 150+ üniversite içeren başlangıç verisi

---

## Mimari

Sistem üç katmanlı bir mimariyle tasarlanmıştır:

```
┌─────────────────┐     HTTP/REST + WebSocket     ┌──────────────────┐     TypeORM     ┌──────────────┐
│  Flutter (Mobil)│ ◄──────────────────────────► │  NestJS (Sunucu) │ ◄────────────► │  PostgreSQL  │
│   Android APK   │         JSON / JWT            │  REST + Socket.IO│                │  (app şeması)│
└─────────────────┘                               └──────────────────┘                └──────────────┘
                                                          │
                                                          ▼
                                                   ┌──────────────┐
                                                   │  Cloudinary  │ (görsel depolama)
                                                   └──────────────┘
```

---

## Kurulum

### Gereksinimler

- [Node.js](https://nodejs.org/) v18 veya üzeri
- [Flutter SDK](https://flutter.dev/docs/get-started/install) v3.x
- [PostgreSQL](https://www.postgresql.org/download/) v15 veya üzeri
- [pgAdmin 4](https://www.pgadmin.org/download/)
- [Android Studio](https://developer.android.com/studio) (Android SDK için)
- [Git](https://git-scm.com/)

### 1 — Projeyi klonla

```bash
git clone https://github.com/Elif-Durmus/erasmus-platform.git
cd erasmus-platform/erasmus_platform
```

### 2 — Veritabanı kurulumu

`database/` klasöründeki SQL dosyalarını **sırayla** çalıştır (pgAdmin Query Tool ile):

1. `002_extensions_and_schema.sql` — uzantılar ve `app` şeması
2. `003_types.sql` — ENUM tipleri
3. `004_core_tables.sql` — temel tablolar
4. `005_content_tables.sql` — içerik tabloları
5. `006_messaging_tables.sql` — mesajlaşma tabloları
6. `007_social_tables.sql` — sosyal tablolar
7. `008_indexes.sql` — indeksler
8. `009_triggers.sql` — tetikleyiciler
9. `010_seed.sql` — başlangıç verisi
10. `011_seed_expanded.sql` — genişletilmiş ülke/üniversite verisi (30 ülke, 150+ üniversite)

> **Not:** `001_create_app_user_and_db.sql` yalnızca yerel kurulumda, ayrı bir veritabanı/kullanıcı oluşturmak için kullanılır. Railway gibi hazır PostgreSQL örneklerinde bu adım atlanır.

### 3 — Backend kurulumu

```bash
cd erasmus_platform/backend
npm install
```

`backend/` klasöründe bir `.env` dosyası oluştur (bu dosya gizlidir, repoya dahil değildir):

```env
# Yerel geliştirme için (ayrı değişkenler)
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USER=erasmus_user
DATABASE_PASSWORD=SENIN_SIFREN
DATABASE_NAME=erasmus_db

# Veya bulut için tek bağlantı adresi
# DATABASE_URL=postgresql://...

JWT_SECRET=guclu_bir_gizli_anahtar
JWT_EXPIRES_IN=7d
PORT=3000

# Cloudinary (https://cloudinary.com adresinden ücretsiz hesap)
CLOUDINARY_CLOUD_NAME=cloud_adin
CLOUDINARY_API_KEY=api_anahtarin
CLOUDINARY_API_SECRET=api_gizli_anahtarin
CLOUDINARY_UPLOAD_PRESET=erasmus_uploads
```

Backend'i başlat:

```bash
npm run start:dev
```

Başarılı olursa terminalde `Erasmus API Çalışıyor` mesajını görürsün.

### 4 — Mobil uygulama kurulumu

```bash
cd erasmus_platform/mobile
flutter pub get
```

`lib/core/api/api_client.dart` dosyasındaki `baseUrl` değerini ortamına göre ayarla:

| Ortam | baseUrl |
|-------|---------|
| Android Emülatör | `http://10.0.2.2:3000` |
| Gerçek cihaz (aynı WiFi) | `http://BILGISAYAR_IP:3000` |
| Bulut (Railway) | `https://erasmus-platform-production.up.railway.app` |

Uygulamayı çalıştır (cihaz USB ile bağlıyken):

```bash
flutter run
```

---

## Bulut Dağıtımı (Railway)

Proje, yerel ortamdan bağımsız çalışacak şekilde [Railway](https://railway.app) üzerine dağıtılmıştır.

1. Railway'de bir **PostgreSQL** servisi oluştur
2. Veritabanı tablolarını (yukarıdaki SQL dosyaları) Railway veritabanında çalıştır
3. GitHub deposunu Railway'e bağla, **Root Directory** olarak `erasmus_platform/backend` ayarla
4. Ortam değişkenlerini (`DATABASE_URL`, `JWT_SECRET`, `CLOUDINARY_*`) Railway'de tanımla
5. Servise public bir domain ata
6. Mobil uygulamada `baseUrl`'ü bu domaine güncelle

> Backend, `DATABASE_URL` ortam değişkeni varsa otomatik olarak bulut moduna (SSL ile) geçer; yoksa yerel ayrı değişkenleri kullanır.

---

## APK Oluşturma

```bash
cd erasmus_platform/mobile
flutter build apk --release
```

Oluşan APK: `build/app/outputs/flutter-apk/app-release.apk`

> **Önemli:** Release APK'nın internete erişebilmesi için `android/app/src/main/AndroidManifest.xml` dosyasında `INTERNET` izni tanımlı olmalıdır.

---

## Proje Yapısı

```
erasmus-platform/
├── database/                    # SQL migration dosyaları (001-011)
└── erasmus_platform/
    ├── backend/                 # NestJS sunucu
    │   └── src/
    │       ├── auth/            # Kimlik doğrulama
    │       ├── users/           # Kullanıcı, profil, takip, değişim
    │       ├── posts/           # Gönderiler, beğeni, yorum
    │       ├── questions/       # Soru-cevap
    │       ├── reviews/         # Üniversite değerlendirmeleri
    │       ├── messages/        # Gerçek zamanlı mesajlaşma
    │       ├── notifications/   # Bildirimler
    │       └── upload/          # Cloudinary görsel yükleme
    └── mobile/                  # Flutter uygulaması
        └── lib/
            ├── core/            # API istemcisi, depolama, yardımcılar
            ├── features/        # Özellik bazlı ekranlar
            │   ├── auth/
            │   ├── feed/
            │   ├── questions/
            │   ├── reviews/
            │   ├── messages/
            │   ├── notifications/
            │   ├── profile/
            │   ├── search/
            │   └── splash/
            └── shared/          # Ortak bileşenler (alt menü vb.)
```

---

## API Uç Noktaları

| Metot | Uç Nokta | İşlev |
|-------|----------|-------|
| POST | `/auth/register` | Kullanıcı kaydı |
| POST | `/auth/login` | Kullanıcı girişi |
| GET | `/posts` | Akış gönderileri |
| POST | `/posts` | Yeni gönderi |
| POST | `/posts/:id/like` | Gönderi beğen |
| GET | `/posts/search?q=` | Gönderi ara |
| GET | `/questions` | Sorular |
| POST | `/reviews` | Değerlendirme oluştur |
| GET | `/reviews/university/:id` | Üniversite değerlendirmeleri |
| POST | `/users/:username/follow` | Takip et |
| GET | `/users/:username/followers` | Takipçiler |
| GET | `/notifications` | Bildirimler |
| GET | `/messages/conversations` | Konuşmalar |

---

## Sık Karşılaşılan Sorunlar

**NestJS yönlendirme çakışması (`invalid input syntax for type uuid`):**
Statik yollar (`/search`, `/countries`) parametre içeren yollardan (`/:id`) **önce** tanımlanmalıdır.

**Release APK'da kayıt/giriş başarısız:**
`AndroidManifest.xml` dosyasında `INTERNET` izni eksik olabilir.

**Gerçek cihazda bağlantı yok:**
Telefon ve bilgisayar aynı WiFi ağında olmalı; `baseUrl` bilgisayarın yerel IP adresini göstermeli (ya da bulut URL'i kullanılmalı).

**Railway'de eksik tablo:**
Migration dosyalarının tümünün Railway veritabanında çalıştırıldığından emin olun.

---

## Lisans

Bu proje, akademik bir tasarım çalışması olarak geliştirilmiştir.
