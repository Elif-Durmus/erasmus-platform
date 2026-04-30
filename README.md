# Erasmus Platform

Erasmus öğrencilerinin deneyimlerini paylaşabildiği, birbirleriyle iletişim kurabildiği ve yeni adaylara rehberlik edebildiği mobil platform.

## Teknoloji Stack

| Katman | Teknoloji |
|--------|-----------|
| Mobil | Flutter (Android) |
| Backend | NestJS (Node.js) |
| Veritabanı | PostgreSQL 18 |
| Auth | JWT (JSON Web Token) |
| Gerçek Zamanlı | Socket.IO (WebSocket) |
| State Management | Riverpod |
| HTTP Client | Dio |
| Navigation | GoRouter |

## Özellikler

- Kullanıcı kayıt ve giriş sistemi
- Profil görüntüleme ve düzenleme
- Post paylaşma ve feed (Deneyim, Tavsiye, Uyarı, Konut, Etkinlik, Akademik)
- Soru-Cevap sistemi
- Gerçek zamanlı mesajlaşma (WebSocket)
- Ülke, şehir, üniversite hiyerarşisi

---

## Kurulum

### Gereksinimler

Başlamadan önce şunların kurulu olduğundan emin ol:

- [Node.js](https://nodejs.org/) v18 veya üzeri
- [Flutter SDK](https://flutter.dev/docs/get-started/install) v3.x
- [PostgreSQL](https://www.postgresql.org/download/) v15 veya üzeri
- [pgAdmin 4](https://www.pgadmin.org/download/) (PostgreSQL yönetimi için)
- [Android Studio](https://developer.android.com/studio) (Android SDK için)
- [Git](https://git-scm.com/)

### 1 — Projeyi klonla

```bash
git clone https://github.com/Elif-Durmus/erasmus-platform.git
cd erasmus-platform
```

---

### 2 — Veritabanı Kurulumu

#### 2.1 — PostgreSQL servisinin çalıştığından emin ol

**Windows:**
- Başlat menüsünde "Hizmetler" yaz ve aç
- `postgresql-x64-18` (veya kurulu sürümün) servisini bul
- Çalışmıyorsa sağ tıkla → Başlat

**Mac/Linux:**
```bash
brew services start postgresql  # Mac
sudo service postgresql start   # Linux
```

#### 2.2 — pgAdmin ile veritabanını kur

1. pgAdmin'i aç ve `postgres` kullanıcısıyla bağlan
2. Sol panelde **Databases** üzerine sağ tıkla → **Create → Database**
3. Database adı: `erasmus_db` → Save
4. `erasmus_db`'ye tıkla → **Query Tool** aç
5. Aşağıdaki SQL'i çalıştır (F5):

```sql
CREATE USER erasmus_user WITH PASSWORD 'ErasmusApp_2026_DB!';
GRANT ALL PRIVILEGES ON DATABASE erasmus_db TO erasmus_user;
```

#### 2.3 — Migration dosyalarını çalıştır

`database/` klasöründeki SQL dosyalarını pgAdmin Query Tool'da sırayla çalıştır:

> **Önemli:** Her dosyayı çalıştırmadan önce bağlantının `erasmus_db` veritabanında olduğunu kontrol et.

```
002_extensions_and_schema.sql
003_types.sql
004_core_tables.sql
005_content_tables.sql
006_messaging_tables.sql
007_social_tables.sql
008_indexes.sql
009_triggers.sql
010_seed.sql
```

Her dosyadan sonra `Query returned successfully` mesajı görmelisin.

#### 2.4 — İzinleri ver

Migration'lar bittikten sonra şunu çalıştır:

```sql
GRANT ALL PRIVILEGES ON SCHEMA app TO erasmus_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA app TO erasmus_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA app TO erasmus_user;
```

---

### 3 — Backend Kurulumu

```bash
cd erasmus_platform/backend
```

#### 3.1 — Paketleri yükle

```bash
npm install
```

#### 3.2 — `.env` dosyası oluştur

> **Not:** `.env` dosyası güvenlik nedeniyle repoda bulunmaz. Klonlayan herkes kendi `.env` dosyasını oluşturmalıdır.

`backend` klasörünün içinde, `src` klasörüyle aynı seviyeye `.env` adında bir dosya oluştur ve şunları yapıştır:

```env
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USER=erasmus_user
DATABASE_PASSWORD=ErasmusApp_2026_DB!
DATABASE_NAME=erasmus_db
JWT_SECRET=erasmus_super_secret_jwt_2026
JWT_EXPIRES_IN=7d
PORT=3000
```

#### 3.3 — Backend'i başlat

```bash
npm run start:dev
```

Terminalde şunu görmelisin:
```
Erasmus API Çalışıyor: http://localhost:3000
```

#### 3.4 — API'yi test et

Tarayıcıda aç: `http://localhost:3000/posts`

Şu yanıtı görmelisin:
```json
{"posts": [], "total": 0, "page": 1, "limit": 20}
```

---

### 4 — Flutter Kurulumu

```bash
cd erasmus_platform/mobile
```

#### 4.1 — Paketleri yükle

```bash
flutter pub get
```

#### 4.2 — API adresini ayarla

`lib/core/api/api_client.dart` dosyasını aç ve çalıştırma ortamına göre URL'i güncelle:

```dart
// Chrome'da çalıştırıyorsan:
static const String baseUrl = 'http://localhost:3000';

// Android emülatörde çalıştırıyorsan:
static const String baseUrl = 'http://10.0.2.2:3000';

// Gerçek Android cihazda (USB) çalıştırıyorsan bilgisayarının IP'sini yaz:
static const String baseUrl = 'http://192.168.1.X:3000';
```

Bilgisayarının IP'sini öğrenmek için:
```bash
# Windows (CMD):
ipconfig | findstr IPv4

# Mac/Linux:
ip route get 1 | awk '{print $7}'
```

#### 4.3 — Uygulamayı çalıştır

**Chrome'da (hızlı test için):**
```bash
flutter run -d chrome
```

**Android emülatörde:**
1. Android Studio'yu aç
2. Device Manager → Create Device → Pixel 6 → API 34 → Finish
3. Emülatörü başlat (▶ Play butonu)
4. `api_client.dart`'ta URL'i `http://10.0.2.2:3000` yap
5. Terminalde:
```bash
flutter run
```

**Gerçek Android cihazda:**
1. Telefonda: Ayarlar → Telefon Hakkında → Derleme Numarası'na 7 kez dokun
2. Ayarlar → Geliştirici Seçenekleri → USB Hata Ayıklama'yı aç
3. USB ile bilgisayara bağla → "İzin Ver" de
4. `api_client.dart`'ta URL'i bilgisayarının IP'siyle güncelle
5. Terminalde:
```bash
flutter run
```

---

## Proje Klasör Yapısı

```
erasmus-platform/
├── database/                        # SQL migration dosyaları
│   ├── 001_create_app_user_and_db.sql
│   ├── 002_extensions_and_schema.sql
│   ├── 003_types.sql
│   ├── 004_core_tables.sql
│   ├── 005_content_tables.sql
│   ├── 006_messaging_tables.sql
│   ├── 007_social_tables.sql
│   ├── 008_indexes.sql
│   ├── 009_triggers.sql
│   └── 010_seed.sql
│
└── erasmus_platform/
    ├── backend/                     # NestJS API
    │   ├── src/
    │   │   ├── auth/                # JWT auth, kayıt/giriş
    │   │   ├── users/               # Kullanıcı profilleri
    │   │   ├── posts/               # Post paylaşımları
    │   │   ├── questions/           # Soru-Cevap sistemi
    │   │   ├── messages/            # Mesajlaşma + WebSocket
    │   │   └── common/              # Guard, decorator paylaşımları
    │   ├── .env                     # ⚠️ Repoda yok — kendin oluştur
    │   └── package.json
    │
    └── mobile/                      # Flutter uygulaması
        ├── lib/
        │   ├── core/
        │   │   ├── api/             # Dio HTTP client, Socket client
        │   │   ├── storage/         # JWT token storage
        │   │   └── router/          # GoRouter navigasyon
        │   ├── features/
        │   │   ├── auth/            # Giriş/Kayıt ekranları
        │   │   ├── profile/         # Profil ekranları
        │   │   ├── feed/            # Feed ve post ekranları
        │   │   ├── questions/       # Soru-Cevap ekranları
        │   │   └── messages/        # Mesajlaşma ekranları
        │   └── shared/
        │       └── screens/         # Ana shell (bottom nav)
        └── pubspec.yaml
```

---

## API Endpoint'leri

| Method | Endpoint | Açıklama | Auth Gerekli |
|--------|----------|----------|--------------|
| POST | `/auth/register` | Yeni kullanıcı kaydı | Hayır |
| POST | `/auth/login` | Giriş yap | Hayır |
| GET | `/users/me` | Kendi profilini getir | Evet |
| PATCH | `/users/me` | Profili güncelle | Evet |
| GET | `/users/:username` | Kullanıcı profilini getir | Evet |
| GET | `/posts` | Feed listesi | Hayır |
| POST | `/posts` | Yeni post oluştur | Evet |
| GET | `/posts/:id` | Post detayı | Hayır |
| GET | `/questions` | Soru listesi | Hayır |
| POST | `/questions` | Yeni soru sor | Evet |
| GET | `/questions/:id` | Soru detayı + cevaplar | Hayır |
| POST | `/questions/:id/answers` | Cevap yaz | Evet |
| GET | `/messages/conversations` | Konuşma listesi | Evet |
| POST | `/messages/conversations/direct` | DM başlat | Evet |
| GET | `/messages/conversations/:id/messages` | Mesajları getir | Evet |

---

## Sık Karşılaşılan Sorunlar

**PostgreSQL servisi başlamıyor (Windows)**
```powershell
# PowerShell'de servis adını bul:
Get-Service | Where-Object {$_.DisplayName -like "*postgres*"}
# Sonra başlat:
Start-Service postgresql-x64-18
```

**`npm run start:dev` script hatası (Windows)**
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

**Flutter API'ye bağlanamıyor**
→ `api_client.dart`'taki URL'i kontrol et:
- Chrome → `localhost`
- Emülatör → `10.0.2.2`
- Gerçek cihaz → bilgisayarının IP adresi

**500 Internal Server Error**
→ pgAdmin'de şu SQL'i çalıştır:
```sql
GRANT ALL PRIVILEGES ON SCHEMA app TO erasmus_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA app TO erasmus_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA app TO erasmus_user;
```

**`socket_io_client` hatası (Chrome'da)**
→ WebSocket sadece gerçek cihaz veya emülatörde çalışır. Chrome'da mesajlaşma ekranı devre dışıdır, bu normaldir.

---

## Geliştirici

**Elif Durmuş** — BM328 Bilgisayar Mühendisliği Tasarım Çalışması II
