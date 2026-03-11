-- Supabase SQL Schema for LanguageLearnerApplication
-- Paste this entire file into the Supabase SQL Editor and click "Run"

-- 1. Courses Table (Netflix Series)
CREATE TABLE public.courses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  netflix_series_id TEXT NOT NULL,
  series_name TEXT NOT NULL,
  target_language TEXT NOT NULL,
  thumbnail_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. User Courses Table (Enrollment/Tracking)
CREATE TABLE public.user_courses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
  progress_percentage INTEGER DEFAULT 0,
  last_accessed TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(user_id, course_id)
);

-- 3. Quizzes Table
CREATE TABLE public.quizzes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_course_id UUID REFERENCES public.user_courses(id) ON DELETE CASCADE,
  episode_reference TEXT NOT NULL,
  score INTEGER DEFAULT 0,
  total_questions INTEGER NOT NULL,
  completed_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. Quiz Questions Table
CREATE TABLE public.quiz_questions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  quiz_id UUID REFERENCES public.quizzes(id) ON DELETE CASCADE,
  question_text TEXT NOT NULL,
  options JSONB NOT NULL,
  correct_answer TEXT NOT NULL,
  user_answer TEXT,
  is_correct BOOLEAN DEFAULT false
);

-- 5. Flashcards Table (Generated from Quiz Mistakes)
CREATE TABLE public.flashcards (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
  front_text TEXT NOT NULL,
  back_text TEXT NOT NULL,
  context_sentence TEXT,
  next_review_date TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  mastery_level INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable Row Level Security (RLS) for security best practices
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.flashcards ENABLE ROW LEVEL SECURITY;

-- Optional: Create basic RLS policies allowing authenticated users to read/write their own data
CREATE POLICY "Users can manage their own courses" ON public.user_courses FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own flashcards" ON public.flashcards FOR ALL USING (auth.uid() = user_id);
-- (Add more granular policies as needed for quizzes and courses, but the node backend using the Service Key will bypass these anyway).

-- 6. Profiles Table (Linked to Supabase Auth)
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT NOT NULL,
  email TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public profiles are viewable by everyone" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can insert their own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update their own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- 7. Automated Trigger to create a profile when a new user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, username, email, avatar_url)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'username', 'New Learner'),
    new.email,
    new.raw_user_meta_data->>'avatar_url'
  );
  RETURN new;
END;
$$;

-- Trigger the function every time a user is created
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

/*
  IMPORTANT: Storage Bucket Instructions
  Because Supabase Storage isn't created automatically via SQL, you must:
  1. Go to your Supabase Dashboard -> Storage
  2. Create a new bucket named: 'avatars'
  3. Set it to 'Public'
  4. Add an RLS policy to the 'avatars' bucket allowing all operations (or just authenticated insert/selects).
*/

/* 
  STORAGE POLICY FIX (403 Error Resolution):
  If you received a "Row-level security policy, statusCode: 403" when uploading, 
  your database requires explicit authentication declarations.
  
  Run this command instead in your Supabase SQL Editor:
  
  -- Drop the previous loose policy if it exists
  DROP POLICY IF EXISTS "Allow public uploads" ON storage.objects;

  -- Create a strictly Authenticated policy for avatar uploads
  CREATE POLICY "Allow authenticated uploads"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'avatars');

  -- Ensure public views are still allowed
  CREATE POLICY "Allow public views" 
  ON storage.objects FOR SELECT TO public
  USING (bucket_id = 'avatars');
*/

-- ==========================================
-- Calendly Integration / Instructor Scheduling
-- ==========================================

-- 8. Instructor Sessions Table (Master list of classes available to book)
CREATE TABLE public.instructor_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  language TEXT NOT NULL,
  level TEXT NOT NULL,
  title TEXT NOT NULL,
  mentor_name TEXT NOT NULL,
  calendly_url TEXT NOT NULL,
  time_slot TEXT NOT NULL,
  is_active BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.instructor_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view instructor sessions" ON public.instructor_sessions FOR SELECT USING (true);


-- 9. User Sessions Table (Tracking which user booked which specific class)
CREATE TABLE public.user_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  session_id UUID REFERENCES public.instructor_sessions(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'upcoming',
  booked_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(user_id, session_id) -- A user can only book a specific class type once for simplicity right now
);

ALTER TABLE public.user_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own booked sessions" ON public.user_sessions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can book their own sessions" ON public.user_sessions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own booked sessions" ON public.user_sessions FOR UPDATE USING (auth.uid() = user_id);
