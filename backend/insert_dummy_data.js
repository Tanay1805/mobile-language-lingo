const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

const supabase = createClient(supabaseUrl, supabaseKey);

async function insertDummyData() {
  const { data, error } = await supabase
    .from('instructor_sessions')
    .insert([
      {
        language: 'English',
        level: 'Beginner',
        title: 'Learn English Basics & Conversation',
        mentor_name: 'Isabella Rodriguez',
        calendly_url: 'https://calendly.com/english-test-link',
        time_slot: '10:00 - 11:00',
        is_active: false
      },
      {
        language: 'Spanish',
        level: 'Advanced',
        title: 'Master Advanced Spanish Grammar',
        mentor_name: 'Santiago Fernandez',
        calendly_url: 'https://calendly.com/spanish-test-link',
        time_slot: '13:00 - 14:00',
        is_active: true
      },
      {
        language: 'Japanese',
        level: 'Intermediate',
        title: 'Conversational Japanese & Kanji',
        mentor_name: 'Yuki Takahashi',
        calendly_url: 'https://calendly.com/japanese-test-link',
        time_slot: '16:00 - 17:00',
        is_active: false
      }
    ]);

  if (error) {
    console.error('Error inserting data:', error);
  } else {
    console.log('Successfully inserted dummy instructor sessions!');
  }
}

insertDummyData();
