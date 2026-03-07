CREATE TABLE app.posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    post_type app.post_type NOT NULL,
    title VARCHAR(255),
    content TEXT NOT NULL,
    country_id UUID REFERENCES app.countries(id) ON DELETE SET NULL,
    city_id UUID REFERENCES app.cities(id) ON DELETE SET NULL,
    university_id UUID REFERENCES app.universities(id) ON DELETE SET NULL,
    exchange_id UUID REFERENCES app.user_exchanges(id) ON DELETE SET NULL,
    visibility app.profile_visibility NOT NULL DEFAULT 'public',
    status app.content_status NOT NULL DEFAULT 'published',
    like_count INTEGER NOT NULL DEFAULT 0,
    comment_count INTEGER NOT NULL DEFAULT 0,
    save_count INTEGER NOT NULL DEFAULT 0,
    share_count INTEGER NOT NULL DEFAULT 0,
    report_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP
);

CREATE TABLE app.post_media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES app.posts(id) ON DELETE CASCADE,
    media_type VARCHAR(20) NOT NULL,
    media_url TEXT NOT NULL,
    thumbnail_url TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE app.post_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES app.posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    parent_comment_id UUID REFERENCES app.post_comments(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    like_count INTEGER NOT NULL DEFAULT 0,
    status app.content_status NOT NULL DEFAULT 'published',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP
);

CREATE TABLE app.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    review_target_type app.review_target_type NOT NULL,
    university_id UUID REFERENCES app.universities(id) ON DELETE CASCADE,
    city_id UUID REFERENCES app.cities(id) ON DELETE CASCADE,
    exchange_id UUID REFERENCES app.user_exchanges(id) ON DELETE SET NULL,
    title VARCHAR(255),
    content TEXT NOT NULL,
    is_anonymous BOOLEAN NOT NULL DEFAULT FALSE,
    helpful_count INTEGER NOT NULL DEFAULT 0,
    status app.content_status NOT NULL DEFAULT 'published',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_review_target CHECK (
      (review_target_type = 'university' AND university_id IS NOT NULL AND city_id IS NULL)
      OR
      (review_target_type = 'city' AND city_id IS NOT NULL AND university_id IS NULL)
    )
);

CREATE TABLE app.review_ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id UUID NOT NULL UNIQUE REFERENCES app.reviews(id) ON DELETE CASCADE,
    academic_score SMALLINT,
    social_score SMALLINT,
    housing_score SMALLINT,
    transport_score SMALLINT,
    safety_score SMALLINT,
    cost_score SMALLINT,
    support_score SMALLINT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_academic_score CHECK (academic_score IS NULL OR academic_score BETWEEN 1 AND 5),
    CONSTRAINT chk_social_score CHECK (social_score IS NULL OR social_score BETWEEN 1 AND 5),
    CONSTRAINT chk_housing_score CHECK (housing_score IS NULL OR housing_score BETWEEN 1 AND 5),
    CONSTRAINT chk_transport_score CHECK (transport_score IS NULL OR transport_score BETWEEN 1 AND 5),
    CONSTRAINT chk_safety_score CHECK (safety_score IS NULL OR safety_score BETWEEN 1 AND 5),
    CONSTRAINT chk_cost_score CHECK (cost_score IS NULL OR cost_score BETWEEN 1 AND 5),
    CONSTRAINT chk_support_score CHECK (support_score IS NULL OR support_score BETWEEN 1 AND 5)
);

CREATE TABLE app.questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    country_id UUID REFERENCES app.countries(id) ON DELETE SET NULL,
    city_id UUID REFERENCES app.cities(id) ON DELETE SET NULL,
    university_id UUID REFERENCES app.universities(id) ON DELETE SET NULL,
    exchange_id UUID REFERENCES app.user_exchanges(id) ON DELETE SET NULL,
    is_anonymous BOOLEAN NOT NULL DEFAULT FALSE,
    status app.question_status NOT NULL DEFAULT 'open',
    view_count INTEGER NOT NULL DEFAULT 0,
    answer_count INTEGER NOT NULL DEFAULT 0,
    follower_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP
);

CREATE TABLE app.answers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_id UUID NOT NULL REFERENCES app.questions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_accepted BOOLEAN NOT NULL DEFAULT FALSE,
    helpful_count INTEGER NOT NULL DEFAULT 0,
    status app.content_status NOT NULL DEFAULT 'published',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP
);