CREATE TYPE app.user_role AS ENUM (
  'student',
  'mentor',
  'coordinator',
  'admin'
);

CREATE TYPE app.account_status AS ENUM (
  'active',
  'suspended',
  'deleted',
  'pending'
);

CREATE TYPE app.profile_visibility AS ENUM (
  'public',
  'verified_only',
  'followers_only',
  'private'
);

CREATE TYPE app.message_permission AS ENUM (
  'everyone',
  'followers_only',
  'verified_only',
  'nobody'
);

CREATE TYPE app.exchange_status AS ENUM (
  'planning',
  'accepted',
  'ongoing',
  'completed'
);

CREATE TYPE app.term_type AS ENUM (
  'fall',
  'spring',
  'summer',
  'full_year'
);

CREATE TYPE app.post_type AS ENUM (
  'experience',
  'advice',
  'warning',
  'housing',
  'event',
  'academic'
);

CREATE TYPE app.content_status AS ENUM (
  'draft',
  'published',
  'hidden',
  'deleted'
);

CREATE TYPE app.review_target_type AS ENUM (
  'university',
  'city'
);

CREATE TYPE app.question_status AS ENUM (
  'open',
  'closed',
  'hidden',
  'deleted'
);

CREATE TYPE app.conversation_type AS ENUM (
  'direct',
  'group'
);

CREATE TYPE app.message_type AS ENUM (
  'text',
  'image',
  'file',
  'system'
);

CREATE TYPE app.group_type AS ENUM (
  'country',
  'city',
  'university',
  'term',
  'custom'
);

CREATE TYPE app.report_target_type AS ENUM (
  'post',
  'comment',
  'question',
  'answer',
  'review',
  'user',
  'message'
);

CREATE TYPE app.report_status AS ENUM (
  'pending',
  'reviewed',
  'dismissed',
  'action_taken'
);