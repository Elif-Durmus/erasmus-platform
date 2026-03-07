INSERT INTO app.countries (name, iso_code, continent)
VALUES
('Turkey', 'TR', 'Europe'),
('Poland', 'PL', 'Europe'),
('Spain', 'ES', 'Europe'),
('Portugal', 'PT', 'Europe')
ON CONFLICT (iso_code) DO NOTHING;

INSERT INTO app.cities (country_id, name)
SELECT id, 'Ankara' FROM app.countries WHERE iso_code = 'TR'
ON CONFLICT (country_id, name) DO NOTHING;

INSERT INTO app.cities (country_id, name)
SELECT id, 'Warsaw' FROM app.countries WHERE iso_code = 'PL'
ON CONFLICT (country_id, name) DO NOTHING;

INSERT INTO app.cities (country_id, name)
SELECT id, 'Barcelona' FROM app.countries WHERE iso_code = 'ES'
ON CONFLICT (country_id, name) DO NOTHING;

INSERT INTO app.cities (country_id, name)
SELECT id, 'Porto' FROM app.countries WHERE iso_code = 'PT'
ON CONFLICT (country_id, name) DO NOTHING;

INSERT INTO app.universities (country_id, city_id, name, short_name)
SELECT c.id, ci.id, 'Middle East Technical University', 'METU'
FROM app.countries c
JOIN app.cities ci ON ci.country_id = c.id AND ci.name = 'Ankara'
WHERE c.iso_code = 'TR'
ON CONFLICT (country_id, name) DO NOTHING;

INSERT INTO app.universities (country_id, city_id, name, short_name)
SELECT c.id, ci.id, 'Warsaw University of Technology', 'WUT'
FROM app.countries c
JOIN app.cities ci ON ci.country_id = c.id AND ci.name = 'Warsaw'
WHERE c.iso_code = 'PL'
ON CONFLICT (country_id, name) DO NOTHING;

INSERT INTO app.universities (country_id, city_id, name, short_name)
SELECT c.id, ci.id, 'University of Barcelona', 'UB'
FROM app.countries c
JOIN app.cities ci ON ci.country_id = c.id AND ci.name = 'Barcelona'
WHERE c.iso_code = 'ES'
ON CONFLICT (country_id, name) DO NOTHING;

INSERT INTO app.universities (country_id, city_id, name, short_name)
SELECT c.id, ci.id, 'University of Porto', 'U.Porto'
FROM app.countries c
JOIN app.cities ci ON ci.country_id = c.id AND ci.name = 'Porto'
WHERE c.iso_code = 'PT'
ON CONFLICT (country_id, name) DO NOTHING;