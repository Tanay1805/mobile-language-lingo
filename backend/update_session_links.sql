-- Supabase SQL Script to update EXISTING live coaching sessions with the new Cal.com link
-- Paste this into the Supabase SQL Editor and click "Run"

UPDATE public.instructor_sessions
SET calendly_url = 'https://cal.com/tanay-sahajwalla-15zm9b/spanish-basics-sessions?overlayCalendar=true&month=2026-04';
