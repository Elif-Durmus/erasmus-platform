CREATE TABLE app.countries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    iso_code VARCHAR(3) NOT NULL UNIQUE,
    continent VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE app.cities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    country_id UUID NOT NULL REFERENCES app.countries(id) ON DELETE RESTRICT,
    name VARCHAR(120) NOT NULL,
    latitude NUMERIC(9,6),
    longitude NUMERIC(9,6),
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(country_id, name)
);

CREATE TABLE app.universities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    country_id UUID NOT NULL REFERENCES app.countries(id) ON DELETE RESTRICT,
    city_id UUID REFERENCES app.cities(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    short_name VARCHAR(100),
    erasmus_code VARCHAR(50),
    website_url TEXT,
    logo_url TEXT,
    cover_image_url TEXT,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(country_id, name)
);

CREATE TABLE app.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email CITEXT NOT NULL UNIQUE,
    password_hash TEXT,
    auth_provider VARCHAR(50) NOT NULL DEFAULT 'email',
    role app.user_role NOT NULL DEFAULT 'student',
    status app.account_status NOT NULL DEFAULT 'active',
    is_email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    is_profile_completed BOOLEAN NOT NULL DEFAULT FALSE,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP
);

CREATE TABLE app.user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES app.users(id) ON DELETE CASCADE,
    full_name VARCHAR(150) NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    profile_photo_url TEXT,
    cover_photo_url TEXT,
    bio TEXT,
    birth_year SMALLINT,
    home_university_id UUID REFERENCES app.universities(id) ON DELETE SET NULL,
    department VARCHAR(150),
    study_level VARCHAR(30),
    current_country_id UUID REFERENCES app.countries(id) ON DELETE SET NULL,
    current_city_id UUID REFERENCES app.cities(id) ON DELETE SET NULL,
    visibility app.profile_visibility NOT NULL DEFAULT 'public',
    message_permission app.message_permission NOT NULL DEFAULT 'everyone',
    is_verified_student BOOLEAN NOT NULL DEFAULT FALSE,
    is_verified_coordinator BOOLEAN NOT NULL DEFAULT FALSE,
    is_mentor BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_birth_year CHECK (
      birth_year IS NULL OR birth_year BETWEEN 1950 AND 2100
    )
);

CREATE TABLE app.user_exchanges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    exchange_status app.exchange_status NOT NULL,
    home_university_id UUID REFERENCES app.universities(id) ON DELETE SET NULL,
    host_university_id UUID REFERENCES app.universities(id) ON DELETE SET NULL,
    host_country_id UUID REFERENCES app.countries(id) ON DELETE SET NULL,
    host_city_id UUID REFERENCES app.cities(id) ON DELETE SET NULL,
    term app.term_type,
    academic_year VARCHAR(20),
    start_date DATE,
    end_date DATE,
    is_current BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_exchange_dates CHECK (
      start_date IS NULL OR end_date IS NULL OR start_date <= end_date
    )
);