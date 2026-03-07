CREATE TABLE app.user_follows (
    follower_user_id UUID NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    followed_user_id UUID NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (follower_user_id, followed_user_id),
    CONSTRAINT chk_no_self_follow CHECK (follower_user_id <> followed_user_id)
);

CREATE TABLE app.entity_follows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    entity_type VARCHAR(20) NOT NULL,
    entity_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, entity_type, entity_id)
);

CREATE TABLE app.saved_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    item_type VARCHAR(20) NOT NULL,
    item_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, item_type, item_id)
);

CREATE TABLE app.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL,
    reference_type VARCHAR(30),
    reference_id UUID,
    actor_user_id UUID REFERENCES app.users(id) ON DELETE SET NULL,
    title VARCHAR(255),
    body TEXT,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE app.reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_user_id UUID NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    target_type app.report_target_type NOT NULL,
    target_id UUID NOT NULL,
    reason_code VARCHAR(50) NOT NULL,
    description TEXT,
    status app.report_status NOT NULL DEFAULT 'pending',
    reviewed_by UUID REFERENCES app.users(id) ON DELETE SET NULL,
    reviewed_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);