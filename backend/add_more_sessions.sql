-- Supabase SQL Script to add more live coaching sessions to the Schedule Tab
-- Paste this into the Supabase SQL Editor and click "Run"

INSERT INTO public.instructor_sessions (language, level, title, mentor_name, calendly_url, time_slot, is_active)
VALUES 
  -----------------------------------------------
  -- Spanish Sessions
  -----------------------------------------------
  ('Spanish', 'Beginner', 'Conversational Spanish Basics', 'Maria Gomez', 'https://cal.com/tanay-sahajwalla-15zm9b/spanish-basics-sessions?overlayCalendar=true&month=2026-04', '10:00 - 11:00 AM', true),
  ('Spanish', 'Advanced', 'Master Advanced Spanish Grammar', 'Santiago Fernandez', 'https://cal.com/tanay-sahajwalla-15zm9b/spanish-basics-sessions?overlayCalendar=true&month=2026-04', '1:00 - 2:00 PM', true),
  ('Spanish', 'Intermediate', 'Spanish Business Etiquette', 'Lucia Ramirez', 'https://cal.com/tanay-sahajwalla-15zm9b/spanish-basics-sessions?overlayCalendar=true&month=2026-04', '4:00 - 5:00 PM', false),
  
  -----------------------------------------------
  -- French Sessions
  -----------------------------------------------
  ('French', 'Beginner', 'French Pronunciation 101', 'Pierre Dubois', 'https://cal.com/tanay-sahajwalla-15zm9b/spanish-basics-sessions?overlayCalendar=true&month=2026-04', '9:00 - 10:00 AM', true),
  ('French', 'Intermediate', 'Discussing French Cinema', 'Amelie Laurent', 'https://cal.com/tanay-sahajwalla-15zm9b/spanish-basics-sessions?overlayCalendar=true&month=2026-04', '2:00 - 3:00 PM', true),
  
  -----------------------------------------------
  -- Japanese Sessions
  -----------------------------------------------
  ('Japanese', 'Beginner', 'Hiragana & Katakana Masterclass', 'Kenji Tanaka', 'https://cal.com/tanay-sahajwalla-15zm9b/spanish-basics-sessions?overlayCalendar=true&month=2026-04', '11:00 - 12:00 PM', true),
  ('Japanese', 'Advanced', 'Keigo (Polite Japanese) Practice', 'Yuki Sato', 'https://cal.com/tanay-sahajwalla-15zm9b/spanish-basics-sessions?overlayCalendar=true&month=2026-04', '5:00 - 6:00 PM', false),
  
  -----------------------------------------------
  -- Korean Sessions
  -----------------------------------------------
  ('Korean', 'Beginner', 'Reading Hangul Fast', 'Ji-Woo Kang', 'https://cal.com/tanay-sahajwalla-15zm9b/spanish-basics-sessions?overlayCalendar=true&month=2026-04', '3:00 - 4:00 PM', true),
  ('Korean', 'Intermediate', 'K-Drama Slang & Phrases', 'Min-Ho Lee', 'https://cal.com/tanay-sahajwalla-15zm9b/spanish-basics-sessions?overlayCalendar=true&month=2026-04', '6:00 - 7:00 PM', true),
  
  -----------------------------------------------
  -- German Sessions
  -----------------------------------------------
  ('German', 'Beginner', 'Surviving in Berlin', 'Hans Mueller', 'https://cal.com/tanay-sahajwalla-15zm9b/spanish-basics-sessions?overlayCalendar=true&month=2026-04', '8:00 - 9:00 AM', false),
  ('German', 'Advanced', 'Goethe C1 Exam Prep', 'Klara Schmidt', 'https://cal.com/tanay-sahajwalla-15zm9b/spanish-basics-sessions?overlayCalendar=true&month=2026-04', '7:00 - 8:00 PM', true)
;
