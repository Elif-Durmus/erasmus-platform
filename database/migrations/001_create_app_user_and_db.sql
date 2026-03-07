-- Erasmus App Database Setup

-- Create database user
CREATE USER erasmus_user WITH PASSWORD 'ErasmusApp_2026_DB!';

-- Create database
CREATE DATABASE erasmus_db;

-- Give privileges
GRANT ALL PRIVILEGES ON DATABASE erasmus_db TO erasmus_user;