-- Seed data for Elixir Radio
INSERT INTO genres (name, description, image_url, inserted_at, updated_at) VALUES
('Electronic', 'Electronic music including house, techno, ambient, and more', NULL, NOW(), NOW()),
('House', 'House music from deep house to progressive', NULL, NOW(), NOW()),
('Techno', 'Techno beats from Detroit to Berlin', NULL, NOW(), NOW()),
('Hip Hop', 'Hip hop and rap music', NULL, NOW(), NOW()),
('Jazz', 'Jazz music from traditional to modern fusion', NULL, NOW(), NOW()),
('Rock', 'Rock music spanning decades', NULL, NOW(), NOW());

INSERT INTO artists (name, bio, image_url, inserted_at, updated_at) VALUES
('Axel Le Baron', 'French electronic music producer', NULL, NOW(), NOW()),
('Deep Groove', 'House music producer from Chicago', NULL, NOW(), NOW()),
('Berlin Pulse', 'Techno collective from Germany', NULL, NOW(), NOW()),
('MC Flow', 'West coast hip hop artist', NULL, NOW(), NOW()),
('The Jazz Collective', 'Modern jazz ensemble from New York', NULL, NOW(), NOW()),
('Midnight Riders', 'Classic rock band', NULL, NOW(), NOW()),
('Nina Soundwave', 'Progressive house DJ', NULL, NOW(), NOW()),
('Rhythm Masters', 'Detroit techno pioneers', NULL, NOW(), NOW()),
('Urban Poets', 'Underground hip hop crew', NULL, NOW(), NOW()),
('Smooth Operators', 'Jazz fusion band', NULL, NOW(), NOW()),
('Electric Thunder', 'Rock legends', NULL, NOW(), NOW()),
('Luna Bass', 'Bass house producer', NULL, NOW(), NOW()),
('Acid Mind', 'Acid techno producer', NULL, NOW(), NOW()),
('Lyric Soul', 'Conscious hip hop artist', NULL, NOW(), NOW()),
('Blue Notes', 'Traditional jazz quartet', NULL, NOW(), NOW()),
('Vinyl Collective', 'Retro electronic artist', NULL, NOW(), NOW()),
('Groove Factory', 'Funk house producer', NULL, NOW(), NOW()),
('Techno Warriors', 'Hard techno crew', NULL, NOW(), NOW()),
('Beat Poets', 'Abstract hip hop', NULL, NOW(), NOW()),
('Analog Jazz', 'Vinyl-only jazz band', NULL, NOW(), NOW());

INSERT INTO albums (title, artist_id, genre_id, release_year, cover_image_url, description, inserted_at, updated_at) VALUES
('Electronic Dreams', 1, 1, 2024, NULL, 'A journey through electronic soundscapes', NOW(), NOW()),
('Neon Nights', 1, 1, 2023, NULL, 'Late night electronic vibes', NOW(), NOW()),
('Deep in the Night', 2, 2, 2024, NULL, 'Deep house grooves', NOW(), NOW()),
('Basement Sessions', 2, 2, 2023, NULL, 'Underground house classics', NOW(), NOW()),
('Chicago Nights', 7, 2, 2024, NULL, 'Progressive house journey', NOW(), NOW()),
('Warehouse Tales', 7, 2, 2023, NULL, 'Classic house anthems', NOW(), NOW()),
('Analog Dreams', 12, 2, 2024, NULL, 'Bass house bangers', NOW(), NOW()),
('Industrial Complex', 3, 3, 2024, NULL, 'Berlin techno at its finest', NOW(), NOW()),
('Factory Floor', 3, 3, 2023, NULL, 'Raw techno energy', NOW(), NOW()),
('Motor City Soul', 8, 3, 2024, NULL, 'Detroit techno heritage', NOW(), NOW()),
('Electric Pulse', 8, 3, 2022, NULL, 'Pure techno essence', NOW(), NOW()),
('Acid Test', 13, 3, 2024, NULL, 'Acid techno experiments', NOW(), NOW()),
('West Side Story', 4, 4, 2024, NULL, 'Modern west coast hip hop', NOW(), NOW()),
('Street Chronicles', 4, 4, 2023, NULL, 'Urban storytelling', NOW(), NOW()),
('Underground Tapes', 9, 4, 2024, NULL, 'Raw hip hop beats', NOW(), NOW()),
('City Lights Vol. 1', 9, 4, 2023, NULL, 'Hip hop essentials', NOW(), NOW()),
('Conscious Mind', 14, 4, 2024, NULL, 'Thoughtful hip hop', NOW(), NOW()),
('Midnight Sessions', 5, 5, 2023, NULL, 'Live jazz recordings', NOW(), NOW()),
('Fusion Experiments', 10, 5, 2024, NULL, 'Jazz fusion explorations', NOW(), NOW()),
('Smooth Sailing', 10, 5, 2022, NULL, 'Easy listening jazz', NOW(), NOW()),
('Blue Hour', 15, 5, 2024, NULL, 'Traditional jazz standards', NOW(), NOW()),
('Highway Freedom', 6, 6, 2020, NULL, 'Classic rock anthems', NOW(), NOW()),
('Thunder & Lightning', 11, 6, 2024, NULL, 'Heavy rock experience', NOW(), NOW()),
('Live at Red Rocks', 11, 6, 2023, NULL, 'Live rock performance', NOW(), NOW()),
('Amplified', 6, 6, 2022, NULL, 'Rock essentials', NOW(), NOW()),
('Synthwave Journey', 1, 1, 2022, NULL, 'Retro electronic vibes', NOW(), NOW()),
('Dance Floor Killers', 2, 2, 2022, NULL, 'House party favorites', NOW(), NOW()),
('Techno Cathedral', 3, 3, 2021, NULL, 'Spiritual techno experience', NOW(), NOW()),
('Hip Hop Chronicles', 4, 4, 2022, NULL, 'Hip hop evolution', NOW(), NOW()),
('Jazz After Dark', 5, 5, 2021, NULL, 'Late night jazz', NOW(), NOW()),
('Vinyl Dreams', 16, 1, 2024, NULL, 'Electronic music for vinyl lovers', NOW(), NOW()),
('Groove Machine', 17, 2, 2024, NULL, 'Funky house grooves', NOW(), NOW()),
('Warehouse Anthems', 17, 2, 2023, NULL, 'Classic warehouse vibes', NOW(), NOW()),
('Underground Sound', 18, 3, 2024, NULL, 'Raw underground techno', NOW(), NOW()),
('Minimal Tech', 18, 3, 2023, NULL, 'Minimal techno exploration', NOW(), NOW()),
('Boom Bap Chronicles', 19, 4, 2024, NULL, '90s inspired hip hop', NOW(), NOW()),
('Jazz Noir', 20, 5, 2024, NULL, 'Dark jazz atmospheres', NOW(), NOW()),
('Rock Solid', 11, 6, 2024, NULL, 'Pure rock energy', NOW(), NOW()),
('Electronic Sunrise', 1, 1, 2021, NULL, 'Morning electronic vibes', NOW(), NOW()),
('Deep House Essentials', 2, 2, 2021, NULL, 'Deep house collection', NOW(), NOW()),
('Techno Pulse', 8, 3, 2021, NULL, 'Driving techno beats', NOW(), NOW()),
('Urban Stories', 9, 4, 2021, NULL, 'Street narratives', NOW(), NOW()),
('Jazz Standards', 15, 5, 2020, NULL, 'Classic jazz interpretations', NOW(), NOW()),
('Rock Revolution', 6, 6, 2021, NULL, 'Revolutionary rock sounds', NOW(), NOW()),
('Ambient Spaces', 16, 1, 2023, NULL, 'Ambient electronic soundscapes', NOW(), NOW()),
('House Nation', 7, 2, 2022, NULL, 'House music celebration', NOW(), NOW()),
('Techno Warfare', 18, 3, 2022, NULL, 'Hard hitting techno', NOW(), NOW()),
('Lyrical Genius', 14, 4, 2023, NULL, 'Poetic hip hop', NOW(), NOW()),
('Bebop Dreams', 20, 5, 2023, NULL, 'Modern bebop jazz', NOW(), NOW()),
('Guitar Heroes', 11, 6, 2023, NULL, 'Epic guitar solos', NOW(), NOW()),
('Digital Love', 1, 1, 2020, NULL, 'Digital electronic emotions', NOW(), NOW()),
('House Therapy', 12, 2, 2020, NULL, 'Therapeutic house music', NOW(), NOW()),
('Techno Vision', 3, 3, 2020, NULL, 'Visionary techno', NOW(), NOW()),
('Rap Chronicles', 4, 4, 2020, NULL, 'Hip hop history', NOW(), NOW()),
('Smooth Jazz', 10, 5, 2019, NULL, 'Relaxing jazz tunes', NOW(), NOW());

INSERT INTO tracks (title, album_id, track_number, duration_seconds, alt_track_number, upload_status, inserted_at, updated_at) VALUES
-- Electronic Dreams (Album 1) - 5 tracks with vinyl sides
('Music is the Danger (Club edit)', 1, 1, 248, 'A1', 0, NOW(), NOW()),
('Midnight Drive', 1, 2, 312, 'A2', 0, NOW(), NOW()),
('Pulse', 1, 3, 275, 'A3', 0, NOW(), NOW()),
('Digital Waves', 1, 4, 298, 'B1', 0, NOW(), NOW()),
('Electric Dreams', 1, 5, 334, 'B2', 0, NOW(), NOW()),

-- Neon Nights (Album 2) - 7 tracks with vinyl sides
('City Lights', 2, 1, 294, 'A1', 0, NOW(), NOW()),
('Neon Dreams', 2, 2, 268, 'A2', 0, NOW(), NOW()),
('After Hours', 2, 3, 301, 'A3', 0, NOW(), NOW()),
('Midnight Runner', 2, 4, 287, 'A4', 0, NOW(), NOW()),
('Urban Glow', 2, 5, 312, 'B1', 0, NOW(), NOW()),
('Night Drive', 2, 6, 289, 'B2', 0, NOW(), NOW()),
('Dawn Breaks', 2, 7, 256, 'B3', 0, NOW(), NOW()),

-- Deep in the Night (Album 3) - 11 tracks with vinyl sides
('Deep Groove', 3, 1, 378, 'A1', 0, NOW(), NOW()),
('Basement Vibes', 3, 2, 421, 'A2', 0, NOW(), NOW()),
('Sunrise', 3, 3, 356, 'A3', 0, NOW(), NOW()),
('Soul Movement', 3, 4, 389, 'A4', 0, NOW(), NOW()),
('Late Night', 3, 5, 398, 'A5', 0, NOW(), NOW()),
('Deep Waters', 3, 6, 367, 'A6', 0, NOW(), NOW()),
('House Feeling', 3, 7, 412, 'B1', 0, NOW(), NOW()),
('Groove Theory', 3, 8, 387, 'B2', 0, NOW(), NOW()),
('Night Session', 3, 9, 445, 'B3', 0, NOW(), NOW()),
('Morning Light', 3, 10, 423, 'B4', 0, NOW(), NOW()),
('Final Dance', 3, 11, 401, 'B5', 0, NOW(), NOW()),

-- Basement Sessions (Album 4) - 5 tracks
('Underground', 4, 1, 392, 'A1', 0, NOW(), NOW()),
('Chicago Shuffle', 4, 2, 367, 'A2', 0, NOW(), NOW()),
('Basement Love', 4, 3, 378, 'A3', 0, NOW(), NOW()),
('Deep Down', 4, 4, 398, 'B1', 0, NOW(), NOW()),
('House Rules', 4, 5, 356, 'B2', 0, NOW(), NOW()),

-- Chicago Nights (Album 5) - 4 tracks
('Progressive Dreams', 5, 1, 445, NULL, 0, NOW(), NOW()),
('Loop District', 5, 2, 398, NULL, 0, NOW(), NOW()),
('Nightlife', 5, 3, 412, NULL, 0, NOW(), NOW()),
('Chicago After Dark', 5, 4, 389, NULL, 0, NOW(), NOW()),

-- Warehouse Tales (Album 6) - 5 tracks
('Classic Groove', 6, 1, 354, NULL, 0, NOW(), NOW()),
('Dance Floor Memory', 6, 2, 387, NULL, 0, NOW(), NOW()),
('Warehouse Anthem', 6, 3, 367, NULL, 0, NOW(), NOW()),
('Late Night Session', 6, 4, 398, NULL, 0, NOW(), NOW()),
('Final Call', 6, 5, 378, NULL, 0, NOW(), NOW()),

-- Analog Dreams (Album 7) - 4 tracks
('Bass Drop', 7, 1, 289, NULL, 0, NOW(), NOW()),
('Heavy Groove', 7, 2, 312, NULL, 0, NOW(), NOW()),
('Sub Frequencies', 7, 3, 298, NULL, 0, NOW(), NOW()),
('Analog Soul', 7, 4, 334, NULL, 0, NOW(), NOW()),

-- Industrial Complex (Album 8) - 5 tracks
('Berlin Calling', 8, 1, 456, NULL, 0, NOW(), NOW()),
('Factory Reset', 8, 2, 423, NULL, 0, NOW(), NOW()),
('Industrial Love', 8, 3, 398, NULL, 0, NOW(), NOW()),
('Complex Rhythms', 8, 4, 412, NULL, 0, NOW(), NOW()),
('Berlin Nights', 8, 5, 445, NULL, 0, NOW(), NOW()),

-- Factory Floor (Album 9) - 4 tracks
('Raw Energy', 9, 1, 412, NULL, 0, NOW(), NOW()),
('Machine Soul', 9, 2, 445, NULL, 0, NOW(), NOW()),
('Factory Life', 9, 3, 389, NULL, 0, NOW(), NOW()),
('Industrial Beat', 9, 4, 423, NULL, 0, NOW(), NOW()),

-- Motor City Soul (Album 10) - 5 tracks
('Detroit Techno', 10, 1, 387, NULL, 0, NOW(), NOW()),
('Motor Rhythm', 10, 2, 401, NULL, 0, NOW(), NOW()),
('City Pulse', 10, 3, 378, NULL, 0, NOW(), NOW()),
('Motor Love', 10, 4, 412, NULL, 0, NOW(), NOW()),
('Detroit After Dark', 10, 5, 398, NULL, 0, NOW(), NOW()),

-- Electric Pulse (Album 11) - 4 tracks
('Pure Techno', 11, 1, 434, NULL, 0, NOW(), NOW()),
('Electric Dreams', 11, 2, 412, NULL, 0, NOW(), NOW()),
('Pulse Wave', 11, 3, 398, NULL, 0, NOW(), NOW()),
('Energy Flow', 11, 4, 423, NULL, 0, NOW(), NOW()),

-- Acid Test (Album 12) - 5 tracks
('Acid Rain', 12, 1, 367, NULL, 0, NOW(), NOW()),
('303 Love', 12, 2, 389, NULL, 0, NOW(), NOW()),
('Mind Expansion', 12, 3, 423, NULL, 0, NOW(), NOW()),
('Acid Journey', 12, 4, 398, NULL, 0, NOW(), NOW()),
('Test Complete', 12, 5, 378, NULL, 0, NOW(), NOW()),

-- West Side Story (Album 13) - 4 tracks
('West Coast Anthem', 13, 1, 198, NULL, 0, NOW(), NOW()),
('California Dreams', 13, 2, 223, NULL, 0, NOW(), NOW()),
('Sunset Boulevard', 13, 3, 212, NULL, 0, NOW(), NOW()),
('LA Nights', 13, 4, 234, NULL, 0, NOW(), NOW()),

-- Street Chronicles (Album 14) - 5 tracks
('Street Life', 14, 1, 201, NULL, 0, NOW(), NOW()),
('Urban Tales', 14, 2, 189, NULL, 0, NOW(), NOW()),
('Block Party', 14, 3, 245, NULL, 0, NOW(), NOW()),
('Street Wisdom', 14, 4, 223, NULL, 0, NOW(), NOW()),
('Chronicles End', 14, 5, 198, NULL, 0, NOW(), NOW()),

-- Underground Tapes (Album 15) - 4 tracks
('Raw Beats', 15, 1, 178, NULL, 0, NOW(), NOW()),
('Basement Cypher', 15, 2, 234, NULL, 0, NOW(), NOW()),
('Old School Flow', 15, 3, 212, NULL, 0, NOW(), NOW()),
('Underground Legacy', 15, 4, 198, NULL, 0, NOW(), NOW()),

-- City Lights Vol. 1 (Album 16) - 5 tracks
('Streetlights', 16, 1, 198, NULL, 0, NOW(), NOW()),
('Metro Nights', 16, 2, 223, NULL, 0, NOW(), NOW()),
('Urban Glow', 16, 3, 212, NULL, 0, NOW(), NOW()),
('City Dreams', 16, 4, 234, NULL, 0, NOW(), NOW()),
('Bright Lights', 16, 5, 201, NULL, 0, NOW(), NOW()),

-- Conscious Mind (Album 17) - 4 tracks
('Wake Up Call', 17, 1, 256, NULL, 0, NOW(), NOW()),
('Social Commentary', 17, 2, 289, NULL, 0, NOW(), NOW()),
('Better Days', 17, 3, 267, NULL, 0, NOW(), NOW()),
('Conscious Flow', 17, 4, 245, NULL, 0, NOW(), NOW()),

-- Midnight Sessions (Album 18) - 5 tracks
('Blue Note', 18, 1, 342, NULL, 0, NOW(), NOW()),
('Swing Time', 18, 2, 286, NULL, 0, NOW(), NOW()),
('Midnight Groove', 18, 3, 367, NULL, 0, NOW(), NOW()),
('Jazz Session', 18, 4, 312, NULL, 0, NOW(), NOW()),
('Late Night Blues', 18, 5, 298, NULL, 0, NOW(), NOW()),

-- Fusion Experiments (Album 19) - 4 tracks
('Fusion Dance', 19, 1, 423, NULL, 0, NOW(), NOW()),
('Electric Jazz', 19, 2, 398, NULL, 0, NOW(), NOW()),
('Experimental Groove', 19, 3, 412, NULL, 0, NOW(), NOW()),
('Fusion Complete', 19, 4, 389, NULL, 0, NOW(), NOW()),

-- Smooth Sailing (Album 20) - 5 tracks
('Easy Listening', 20, 1, 312, NULL, 0, NOW(), NOW()),
('Smooth Operator', 20, 2, 289, NULL, 0, NOW(), NOW()),
('Gentle Waves', 20, 3, 334, NULL, 0, NOW(), NOW()),
('Sailing Away', 20, 4, 298, NULL, 0, NOW(), NOW()),
('Calm Waters', 20, 5, 312, NULL, 0, NOW(), NOW()),

-- Blue Hour (Album 21) - 4 tracks
('All Blues', 21, 1, 378, NULL, 0, NOW(), NOW()),
('Take Five', 21, 2, 298, NULL, 0, NOW(), NOW()),
('Blue Mood', 21, 3, 334, NULL, 0, NOW(), NOW()),
('Hour Glass', 21, 4, 312, NULL, 0, NOW(), NOW()),

-- Highway Freedom (Album 22) - 5 tracks
('Born to Run Free', 22, 1, 267, NULL, 0, NOW(), NOW()),
('Thunder Road', 22, 2, 298, NULL, 0, NOW(), NOW()),
('Freedom Highway', 22, 3, 312, NULL, 0, NOW(), NOW()),
('Open Road', 22, 4, 289, NULL, 0, NOW(), NOW()),
('Journey Ends', 22, 5, 278, NULL, 0, NOW(), NOW()),

-- Thunder & Lightning (Album 23) - 4 tracks
('Electric Storm', 23, 1, 289, NULL, 0, NOW(), NOW()),
('Heavy Thunder', 23, 2, 334, NULL, 0, NOW(), NOW()),
('Lightning Strike', 23, 3, 298, NULL, 0, NOW(), NOW()),
('Storm Passes', 23, 4, 312, NULL, 0, NOW(), NOW()),

-- Live at Red Rocks (Album 24) - 5 tracks
('Red Rock Anthem', 24, 1, 378, NULL, 0, NOW(), NOW()),
('Mountain High', 24, 2, 401, NULL, 0, NOW(), NOW()),
('Canyon Echo', 24, 3, 367, NULL, 0, NOW(), NOW()),
('Rocks and Rolls', 24, 4, 389, NULL, 0, NOW(), NOW()),
('Encore', 24, 5, 423, NULL, 0, NOW(), NOW()),

-- Amplified (Album 25) - 4 tracks
('Turn It Up', 25, 1, 245, NULL, 0, NOW(), NOW()),
('Rock Steady', 25, 2, 267, NULL, 0, NOW(), NOW()),
('Power Chord', 25, 3, 289, NULL, 0, NOW(), NOW()),
('Maximum Volume', 25, 4, 298, NULL, 0, NOW(), NOW()),

-- Synthwave Journey (Album 26) - 5 tracks
('Retro Drive', 26, 1, 256, NULL, 0, NOW(), NOW()),
('80s Dreams', 26, 2, 278, NULL, 0, NOW(), NOW()),
('Neon Highway', 26, 3, 301, NULL, 0, NOW(), NOW()),
('Synth Wave', 26, 4, 289, NULL, 0, NOW(), NOW()),
('Journey Complete', 26, 5, 267, NULL, 0, NOW(), NOW()),

-- Dance Floor Killers (Album 27) - 4 tracks
('Party Time', 27, 1, 367, NULL, 0, NOW(), NOW()),
('Dance All Night', 27, 2, 389, NULL, 0, NOW(), NOW()),
('Floor Filler', 27, 3, 378, NULL, 0, NOW(), NOW()),
('Last Dance', 27, 4, 398, NULL, 0, NOW(), NOW()),

-- Techno Cathedral (Album 28) - 5 tracks
('Sacred Beats', 28, 1, 456, NULL, 0, NOW(), NOW()),
('Spiritual Journey', 28, 2, 478, NULL, 0, NOW(), NOW()),
('Cathedral Bells', 28, 3, 423, NULL, 0, NOW(), NOW()),
('Divine Rhythm', 28, 4, 445, NULL, 0, NOW(), NOW()),
('Ascension', 28, 5, 467, NULL, 0, NOW(), NOW()),

-- Hip Hop Chronicles (Album 29) - 4 tracks
('Old School', 29, 1, 198, NULL, 0, NOW(), NOW()),
('New School', 29, 2, 212, NULL, 0, NOW(), NOW()),
('Evolution', 29, 3, 234, NULL, 0, NOW(), NOW()),
('Legacy', 29, 4, 223, NULL, 0, NOW(), NOW()),

-- Jazz After Dark (Album 30) - 5 tracks
('Midnight Blue', 30, 1, 389, NULL, 0, NOW(), NOW()),
('After Hours Jazz', 30, 2, 412, NULL, 0, NOW(), NOW()),
('Dark Nights', 30, 3, 367, NULL, 0, NOW(), NOW()),
('Jazz Dreams', 30, 4, 398, NULL, 0, NOW(), NOW()),
('Dawn Arrives', 30, 5, 378, NULL, 0, NOW(), NOW()),

-- Albums 31-55 with 4-5 tracks each
-- Vinyl Dreams (Album 31) - 4 tracks
('Vinyl Love', 31, 1, 298, NULL, 0, NOW(), NOW()),
('Analog Soul', 31, 2, 312, NULL, 0, NOW(), NOW()),
('Needle Drop', 31, 3, 289, NULL, 0, NOW(), NOW()),
('Spinning Dreams', 31, 4, 334, NULL, 0, NOW(), NOW()),

-- Groove Machine (Album 32) - 5 tracks
('Machine Funk', 32, 1, 367, NULL, 0, NOW(), NOW()),
('Groove Theory', 32, 2, 389, NULL, 0, NOW(), NOW()),
('Funky Beat', 32, 3, 378, NULL, 0, NOW(), NOW()),
('Machine Love', 32, 4, 398, NULL, 0, NOW(), NOW()),
('Final Groove', 32, 5, 367, NULL, 0, NOW(), NOW()),

-- Warehouse Anthems (Album 33) - 4 tracks
('Warehouse Party', 33, 1, 398, NULL, 0, NOW(), NOW()),
('Anthem One', 33, 2, 412, NULL, 0, NOW(), NOW()),
('Dance Unite', 33, 3, 389, NULL, 0, NOW(), NOW()),
('Warehouse Closing', 33, 4, 423, NULL, 0, NOW(), NOW()),

-- Underground Sound (Album 34) - 5 tracks
('Underground Bass', 34, 1, 445, NULL, 0, NOW(), NOW()),
('Sound System', 34, 2, 423, NULL, 0, NOW(), NOW()),
('Deep Underground', 34, 3, 456, NULL, 0, NOW(), NOW()),
('Raw Sound', 34, 4, 434, NULL, 0, NOW(), NOW()),
('Underground Anthem', 34, 5, 467, NULL, 0, NOW(), NOW()),

-- Minimal Tech (Album 35) - 4 tracks
('Minimal Beat', 35, 1, 398, NULL, 0, NOW(), NOW()),
('Tech Soul', 35, 2, 412, NULL, 0, NOW(), NOW()),
('Less Is More', 35, 3, 423, NULL, 0, NOW(), NOW()),
('Minimal Love', 35, 4, 389, NULL, 0, NOW(), NOW()),

-- Boom Bap Chronicles (Album 36) - 5 tracks
('Boom Bap Beat', 36, 1, 198, NULL, 0, NOW(), NOW()),
('Classic Flow', 36, 2, 212, NULL, 0, NOW(), NOW()),
('90s Vibes', 36, 3, 234, NULL, 0, NOW(), NOW()),
('Hip Hop Soul', 36, 4, 223, NULL, 0, NOW(), NOW()),
('Bap Legacy', 36, 5, 201, NULL, 0, NOW(), NOW()),

-- Jazz Noir (Album 37) - 4 tracks
('Dark Jazz', 37, 1, 389, NULL, 0, NOW(), NOW()),
('Noir Nights', 37, 2, 412, NULL, 0, NOW(), NOW()),
('Mystery', 37, 3, 398, NULL, 0, NOW(), NOW()),
('Film Noir', 37, 4, 423, NULL, 0, NOW(), NOW()),

-- Rock Solid (Album 38) - 5 tracks
('Solid Ground', 38, 1, 289, NULL, 0, NOW(), NOW()),
('Rock Foundation', 38, 2, 312, NULL, 0, NOW(), NOW()),
('Heavy Stone', 38, 3, 298, NULL, 0, NOW(), NOW()),
('Solid Beat', 38, 4, 334, NULL, 0, NOW(), NOW()),
('Rock On', 38, 5, 278, NULL, 0, NOW(), NOW()),

-- Electronic Sunrise (Album 39) - 4 tracks
('Dawn Breaking', 39, 1, 298, NULL, 0, NOW(), NOW()),
('Morning Light', 39, 2, 312, NULL, 0, NOW(), NOW()),
('Sunrise Dance', 39, 3, 289, NULL, 0, NOW(), NOW()),
('New Day', 39, 4, 334, NULL, 0, NOW(), NOW()),

-- Deep House Essentials (Album 40) - 5 tracks
('Essential Groove', 40, 1, 398, NULL, 0, NOW(), NOW()),
('Deep Essentials', 40, 2, 412, NULL, 0, NOW(), NOW()),
('House Foundation', 40, 3, 389, NULL, 0, NOW(), NOW()),
('Essential Beat', 40, 4, 423, NULL, 0, NOW(), NOW()),
('Deep Love', 40, 5, 398, NULL, 0, NOW(), NOW()),

-- Techno Pulse (Album 41) - 4 tracks
('Pulse Beat', 41, 1, 434, NULL, 0, NOW(), NOW()),
('Techno Heart', 41, 2, 445, NULL, 0, NOW(), NOW()),
('Pulse Wave', 41, 3, 423, NULL, 0, NOW(), NOW()),
('Final Pulse', 41, 4, 456, NULL, 0, NOW(), NOW()),

-- Urban Stories (Album 42) - 5 tracks
('City Tales', 42, 1, 198, NULL, 0, NOW(), NOW()),
('Urban Life', 42, 2, 212, NULL, 0, NOW(), NOW()),
('Street Stories', 42, 3, 234, NULL, 0, NOW(), NOW()),
('Urban Legend', 42, 4, 223, NULL, 0, NOW(), NOW()),
('Story Ends', 42, 5, 201, NULL, 0, NOW(), NOW()),

-- Jazz Standards (Album 43) - 4 tracks
('Standard One', 43, 1, 367, NULL, 0, NOW(), NOW()),
('Classic Jazz', 43, 2, 389, NULL, 0, NOW(), NOW()),
('Time Standard', 43, 3, 398, NULL, 0, NOW(), NOW()),
('Jazz Classic', 43, 4, 412, NULL, 0, NOW(), NOW()),

-- Rock Revolution (Album 44) - 5 tracks
('Revolution Start', 44, 1, 289, NULL, 0, NOW(), NOW()),
('Rebel Yell', 44, 2, 312, NULL, 0, NOW(), NOW()),
('Revolutionary', 44, 3, 298, NULL, 0, NOW(), NOW()),
('Rock Rebel', 44, 4, 334, NULL, 0, NOW(), NOW()),
('Revolution End', 44, 5, 278, NULL, 0, NOW(), NOW()),

-- Ambient Spaces (Album 45) - 4 tracks
('Space One', 45, 1, 456, NULL, 0, NOW(), NOW()),
('Ambient Flow', 45, 2, 478, NULL, 0, NOW(), NOW()),
('Deep Space', 45, 3, 445, NULL, 0, NOW(), NOW()),
('Ambient Dream', 45, 4, 467, NULL, 0, NOW(), NOW()),

-- House Nation (Album 46) - 5 tracks
('Nation United', 46, 1, 398, NULL, 0, NOW(), NOW()),
('House Pride', 46, 2, 412, NULL, 0, NOW(), NOW()),
('Nation Groove', 46, 3, 389, NULL, 0, NOW(), NOW()),
('House Unity', 46, 4, 423, NULL, 0, NOW(), NOW()),
('Nation Anthem', 46, 5, 398, NULL, 0, NOW(), NOW()),

-- Techno Warfare (Album 47) - 4 tracks
('War Beat', 47, 1, 445, NULL, 0, NOW(), NOW()),
('Techno Battle', 47, 2, 456, NULL, 0, NOW(), NOW()),
('Warfare', 47, 3, 434, NULL, 0, NOW(), NOW()),
('Victory Dance', 47, 4, 467, NULL, 0, NOW(), NOW()),

-- Lyrical Genius (Album 48) - 5 tracks
('Genius Flow', 48, 1, 212, NULL, 0, NOW(), NOW()),
('Lyrical Art', 48, 2, 234, NULL, 0, NOW(), NOW()),
('Word Play', 48, 3, 223, NULL, 0, NOW(), NOW()),
('Genius Mind', 48, 4, 245, NULL, 0, NOW(), NOW()),
('Lyrical Master', 48, 5, 198, NULL, 0, NOW(), NOW()),

-- Bebop Dreams (Album 49) - 4 tracks
('Bebop Soul', 49, 1, 389, NULL, 0, NOW(), NOW()),
('Dream State', 49, 2, 412, NULL, 0, NOW(), NOW()),
('Bebop Love', 49, 3, 398, NULL, 0, NOW(), NOW()),
('Dreams End', 49, 4, 423, NULL, 0, NOW(), NOW()),

-- Guitar Heroes (Album 50) - 5 tracks
('Hero Intro', 50, 1, 298, NULL, 0, NOW(), NOW()),
('Guitar Solo', 50, 2, 334, NULL, 0, NOW(), NOW()),
('Shred Master', 50, 3, 312, NULL, 0, NOW(), NOW()),
('Epic Solo', 50, 4, 356, NULL, 0, NOW(), NOW()),
('Hero Finale', 50, 5, 289, NULL, 0, NOW(), NOW()),

-- Digital Love (Album 51) - 4 tracks
('Digital Heart', 51, 1, 298, NULL, 0, NOW(), NOW()),
('Electronic Love', 51, 2, 312, NULL, 0, NOW(), NOW()),
('Binary Romance', 51, 3, 289, NULL, 0, NOW(), NOW()),
('Digital Soul', 51, 4, 334, NULL, 0, NOW(), NOW()),

-- House Therapy (Album 52) - 5 tracks
('Therapy Session', 52, 1, 398, NULL, 0, NOW(), NOW()),
('House Healing', 52, 2, 412, NULL, 0, NOW(), NOW()),
('Groove Medicine', 52, 3, 389, NULL, 0, NOW(), NOW()),
('Soul Therapy', 52, 4, 423, NULL, 0, NOW(), NOW()),
('Healing Dance', 52, 5, 398, NULL, 0, NOW(), NOW()),

-- Techno Vision (Album 53) - 4 tracks
('Vision Quest', 53, 1, 445, NULL, 0, NOW(), NOW()),
('Techno Future', 53, 2, 456, NULL, 0, NOW(), NOW()),
('Clear Vision', 53, 3, 434, NULL, 0, NOW(), NOW()),
('Vision Complete', 53, 4, 467, NULL, 0, NOW(), NOW()),

-- Rap Chronicles (Album 54) - 5 tracks
('Chronicle One', 54, 1, 198, NULL, 0, NOW(), NOW()),
('Rap History', 54, 2, 212, NULL, 0, NOW(), NOW()),
('Golden Era', 54, 3, 234, NULL, 0, NOW(), NOW()),
('Modern Rap', 54, 4, 223, NULL, 0, NOW(), NOW()),
('Chronicle End', 54, 5, 201, NULL, 0, NOW(), NOW()),

-- Smooth Jazz (Album 55) - 4 tracks
('Smooth Start', 55, 1, 345, NULL, 0, NOW(), NOW()),
('Jazz Flow', 55, 2, 367, NULL, 0, NOW(), NOW()),
('Smooth Groove', 55, 3, 389, NULL, 0, NOW(), NOW()),
('Jazz Sunset', 55, 4, 356, NULL, 0, NOW(), NOW());
