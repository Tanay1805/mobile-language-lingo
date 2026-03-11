-- Supabase SQL Script to add more language courses to the platform
-- Paste this into the Supabase SQL Editor and click "Run"

INSERT INTO public.courses (netflix_series_id, series_name, target_language, thumbnail_url)
VALUES 
  -----------------------------------------------
  -- Spanish
  -----------------------------------------------
  ('SPN-001', 'Money Heist (La Casa de Papel)', 'Spanish', 'https://image.tmdb.org/t/p/w500/reEMJA1uzscCbkpeRJeTT2bjqUp.jpg'),
  ('SPN-002', 'Elite', 'Spanish', 'https://image.tmdb.org/t/p/w500/3NTAbAiaoCE80dFOEzLFOZbWdGg.jpg'),
  
  -----------------------------------------------
  -- French
  -----------------------------------------------
  ('FR-001', 'Lupin', 'French', 'https://image.tmdb.org/t/p/w500/sgxawbAF5OJEnUcZhDwwC0N1FhG.jpg'),
  ('FR-002', 'Call My Agent! (Dix pour cent)', 'French', 'https://image.tmdb.org/t/p/w500/5O9n09nUo478b0eQJikS3nEqvC8.jpg'),
  
  -----------------------------------------------
  -- German
  -----------------------------------------------
  ('GER-001', 'Dark', 'German', 'https://image.tmdb.org/t/p/w500/apbrbWs8M9lyOpJYU5WXrpFbk1Z.jpg'),
  ('GER-002', 'Babylon Berlin', 'German', 'https://image.tmdb.org/t/p/w500/xYv1v3z5tIbzFZYK0x9XHYC4xHj.jpg'),

  -----------------------------------------------
  -- Japanese
  -----------------------------------------------
  ('JPN-001', 'Alice in Borderland', 'Japanese', 'https://image.tmdb.org/t/p/w500/20mOwAAPwZ1vLQkw0fvuQHiG7bO.jpg'),
  ('JPN-002', 'Terrace House: Tokyo', 'Japanese', 'https://image.tmdb.org/t/p/w500/8c0N6kR4jC4jD5J6Z2VqX5T0X5a.jpg'),

  -----------------------------------------------
  -- Korean
  -----------------------------------------------
  ('KOR-001', 'Squid Game', 'Korean', 'https://image.tmdb.org/t/p/w500/dDlEmu3EZ0PBrh01oH21cIHT5Yg.jpg'),
  ('KOR-002', 'Crash Landing on You', 'Korean', 'https://image.tmdb.org/t/p/w500/vHkSDEZkZ0gZ9WkYgYn4f8XjEaZ.jpg'),

  -----------------------------------------------
  -- Italian
  -----------------------------------------------
  ('ITA-001', 'Suburra: Blood on Rome', 'Italian', 'https://image.tmdb.org/t/p/w500/8QzX9mN4oBXVN8z5aB8cZkZ4m8b.jpg')
;
