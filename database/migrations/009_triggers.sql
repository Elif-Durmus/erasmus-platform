CREATE OR REPLACE FUNCTION app.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_set_updated_at
BEFORE UPDATE ON app.users
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

CREATE TRIGGER trg_user_profiles_set_updated_at
BEFORE UPDATE ON app.user_profiles
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

CREATE TRIGGER trg_universities_set_updated_at
BEFORE UPDATE ON app.universities
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

CREATE TRIGGER trg_user_exchanges_set_updated_at
BEFORE UPDATE ON app.user_exchanges
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

CREATE TRIGGER trg_posts_set_updated_at
BEFORE UPDATE ON app.posts
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

CREATE TRIGGER trg_post_comments_set_updated_at
BEFORE UPDATE ON app.post_comments
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

CREATE TRIGGER trg_reviews_set_updated_at
BEFORE UPDATE ON app.reviews
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

CREATE TRIGGER trg_questions_set_updated_at
BEFORE UPDATE ON app.questions
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

CREATE TRIGGER trg_answers_set_updated_at
BEFORE UPDATE ON app.answers
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

CREATE TRIGGER trg_conversations_set_updated_at
BEFORE UPDATE ON app.conversations
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

CREATE TRIGGER trg_messages_set_updated_at
BEFORE UPDATE ON app.messages
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();

CREATE TRIGGER trg_groups_set_updated_at
BEFORE UPDATE ON app.groups
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();