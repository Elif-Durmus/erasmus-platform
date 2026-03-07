CREATE INDEX idx_user_profiles_home_university_id ON app.user_profiles(home_university_id);
CREATE INDEX idx_user_profiles_current_country_id ON app.user_profiles(current_country_id);
CREATE INDEX idx_user_profiles_current_city_id ON app.user_profiles(current_city_id);

CREATE INDEX idx_user_exchanges_host_university_id ON app.user_exchanges(host_university_id);
CREATE INDEX idx_user_exchanges_host_city_id ON app.user_exchanges(host_city_id);
CREATE INDEX idx_user_exchanges_host_country_id ON app.user_exchanges(host_country_id);

CREATE INDEX idx_posts_user_id ON app.posts(user_id);
CREATE INDEX idx_posts_university_id ON app.posts(university_id);
CREATE INDEX idx_posts_city_id ON app.posts(city_id);
CREATE INDEX idx_posts_country_id ON app.posts(country_id);
CREATE INDEX idx_posts_post_type ON app.posts(post_type);
CREATE INDEX idx_posts_created_at ON app.posts(created_at DESC);
CREATE INDEX idx_posts_visibility_status_created_at
  ON app.posts(visibility, status, created_at DESC);

CREATE INDEX idx_questions_user_id ON app.questions(user_id);
CREATE INDEX idx_questions_university_id ON app.questions(university_id);
CREATE INDEX idx_questions_city_id ON app.questions(city_id);
CREATE INDEX idx_questions_country_id ON app.questions(country_id);
CREATE INDEX idx_questions_status ON app.questions(status);
CREATE INDEX idx_questions_created_at ON app.questions(created_at DESC);

CREATE INDEX idx_answers_question_id ON app.answers(question_id);
CREATE INDEX idx_answers_user_id ON app.answers(user_id);
CREATE INDEX idx_answers_is_accepted ON app.answers(is_accepted);

CREATE INDEX idx_messages_conversation_id_created_at
  ON app.messages(conversation_id, created_at DESC);

CREATE INDEX idx_notifications_user_id_is_read_created_at
  ON app.notifications(user_id, is_read, created_at DESC);

CREATE INDEX idx_reports_status_created_at
  ON app.reports(status, created_at DESC);