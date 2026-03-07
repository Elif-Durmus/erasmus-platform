CREATE TABLE app.conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_type app.conversation_type NOT NULL,
    created_by UUID REFERENCES app.users(id) ON DELETE SET NULL,
    last_message_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE app.conversation_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES app.conversations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    participant_role VARCHAR(20) NOT NULL DEFAULT 'member',
    joined_at TIMESTAMP NOT NULL DEFAULT NOW(),
    left_at TIMESTAMP,
    is_muted BOOLEAN NOT NULL DEFAULT FALSE,
    last_read_message_id UUID,
    UNIQUE(conversation_id, user_id)
);

CREATE TABLE app.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES app.conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    message_type app.message_type NOT NULL DEFAULT 'text',
    content TEXT,
    media_url TEXT,
    reply_to_message_id UUID REFERENCES app.messages(id) ON DELETE SET NULL,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE app.groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL UNIQUE REFERENCES app.conversations(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    group_type app.group_type NOT NULL,
    country_id UUID REFERENCES app.countries(id) ON DELETE SET NULL,
    city_id UUID REFERENCES app.cities(id) ON DELETE SET NULL,
    university_id UUID REFERENCES app.universities(id) ON DELETE SET NULL,
    academic_year VARCHAR(20),
    term app.term_type,
    cover_image_url TEXT,
    created_by UUID NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    is_private BOOLEAN NOT NULL DEFAULT FALSE,
    join_approval_required BOOLEAN NOT NULL DEFAULT FALSE,
    member_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);