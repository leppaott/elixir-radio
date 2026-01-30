-- Seed data for Elixir Radio
INSERT INTO genres (name, description, image_url, inserted_at, updated_at) VALUES
('Electronic', 'Electronic music including house, techno, ambient, and more', 'https://example.com/genres/electronic.jpg', NOW(), NOW()),
('Jazz', 'Jazz music from traditional to modern fusion', 'https://example.com/genres/jazz.jpg', NOW(), NOW()),
('Rock', 'Rock music spanning decades', 'https://example.com/genres/rock.jpg', NOW(), NOW());

INSERT INTO artists (name, bio, image_url, inserted_at, updated_at) VALUES
('Axel Le Baron', 'French electronic music producer', 'https://example.com/artists/axel.jpg', NOW(), NOW()),
('The Jazz Collective', 'Modern jazz ensemble from New York', 'https://example.com/artists/jazz_collective.jpg', NOW(), NOW()),
('Midnight Riders', 'Classic rock band', 'https://example.com/artists/midnight_riders.jpg', NOW(), NOW());

INSERT INTO albums (title, artist_id, genre_id, release_year, cover_image_url, description, inserted_at, updated_at) VALUES
('Electronic Dreams', 1, 1, 2024, 'https://example.com/albums/dreams.jpg', 'A journey through electronic soundscapes', NOW(), NOW()),
('Neon Nights', 1, 1, 2023, 'https://example.com/albums/neon.jpg', 'Late night electronic vibes', NOW(), NOW()),
('Midnight Sessions', 2, 2, 2023, 'https://example.com/albums/midnight.jpg', 'Live jazz recordings', NOW(), NOW()),
('Highway Freedom', 3, 3, 2020, 'https://example.com/albums/highway.jpg', 'Classic rock anthems', NOW(), NOW());

INSERT INTO tracks (title, album_id, track_number, duration_seconds, upload_status, inserted_at, updated_at) VALUES
('Music is the Danger (Club edit)', 1, 1, 248, 'pending', NOW(), NOW()),
('Midnight Drive', 1, 2, 312, 'pending', NOW(), NOW()),
('Pulse', 1, 3, 275, 'pending', NOW(), NOW()),
('City Lights', 2, 1, 294, 'pending', NOW(), NOW()),
('Neon Dreams', 2, 2, 268, 'pending', NOW(), NOW()),
('After Hours', 2, 3, 301, 'pending', NOW(), NOW()),
('Blue Note', 3, 1, 342, 'pending', NOW(), NOW()),
('Swing Time', 3, 2, 286, 'pending', NOW(), NOW()),
('Born to Run Free', 4, 1, 267, 'pending', NOW(), NOW()),
('Thunder Road', 4, 2, 298, 'pending', NOW(), NOW());
