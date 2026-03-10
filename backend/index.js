require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');
const { Mistral } = require('@mistralai/mistralai');

const app = express();
app.use(cors());
app.use(express.json());

// Initialize Supabase Admin Client
// Note: We use the SERVICE_ROLE_KEY here to bypass RLS and create/update users securely.
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
    console.warn("⚠️  SUPABASE_URL or SUPABASE_SERVICE_KEY is missing from .env");
}

const supabaseAdmin = supabaseUrl && supabaseServiceKey
    ? createClient(supabaseUrl, supabaseServiceKey)
    : null;

// Initialize Mistral Client
const mistralApiKey = process.env.MISTRAL_API_KEY;
if (!mistralApiKey) {
    console.warn("⚠️  MISTRAL_API_KEY is missing from .env");
}
const mistralClient = mistralApiKey ? new Mistral({ apiKey: mistralApiKey }) : null;

// Simulated Netflix OAuth Endpoint
// In a real scenario with a private API, this would exchange an auth code for an access token.
app.post('/auth/netflix/simulate', async (req, res) => {
    try {
        const { email, name, netflixId } = req.body;

        if (!email || !netflixId) {
            return res.status(400).json({ error: 'Missing required fields: email and netflixId' });
        }

        if (!supabaseAdmin) {
            return res.status(500).json({ error: 'Supabase Admin Client not configured correctly on the server.' });
        }

        // Check if the user already exists in our Supabase auth
        // Note: In Supabase, identities can be linked, or we can just create/find the user by email.

        // Attempt to create the user, assuming they might not exist
        const { data: newUser, error: createError } = await supabaseAdmin.auth.admin.createUser({
            email: email,
            email_confirm: true,
            user_metadata: { name: name, provider: 'netflix', netflix_id: netflixId }
        });

        let userId = null;

        if (createError) {
            // If user already exists (Error code 422 usually indicates this for email collisions)
            if (createError.message.includes('already been registered') || createError.status === 422) {
                console.log(`User ${email} already exists, attempting to find them.`);

                // Fetch users by email to get the ID
                // Ideally, you'd use a more robust lookup if available, or just generate a magic link.
                // For server-to-client auth, we should generate a custom JWT or use a magic link approach.

                const { data: usersData, error: usersError } = await supabaseAdmin.auth.admin.listUsers();
                if (!usersError && usersData?.users) {
                    const existingUser = usersData.users.find(u => u.email === email);
                    if (existingUser) {
                        userId = existingUser.id;
                    }
                }
            } else {
                console.error("Error creating user:", createError);
                return res.status(500).json({ error: 'Failed to create user in Auth.' });
            }
        } else {
            userId = newUser.user.id;
        }

        if (!userId) {
            return res.status(500).json({ error: 'Could not resolve user ID.' });
        }

        // Assuming we found or created the user, we want to log them into the app.
        // The most secure approach without custom JWTs (which require custom edge functions in Supabase typically) 
        // is to perform a server-side creation and respond with a status. The Flutter app might need a custom token.
        // For simplicity of this structure, we'll respond with success and the userId. 
        // In production, we would mint a custom JWT here and pass it back.

        return res.status(200).json({
            success: true,
            message: 'Netflix Auth Simulated Successfully',
            userId: userId,
            email: email
        });

    } catch (error) {
        console.error("Netflix auth error:", error);
        res.status(500).json({ error: 'Internal server error during Netflix auth simulation.' });
    }
});

// --- MISTRAL AI ENDPOINTS ---

// 1. Generate Quiz from Netflix Context
app.post('/quiz/generate', async (req, res) => {
    try {
        const { showName, targetLanguage, episode } = req.body;

        if (!showName || !targetLanguage || !episode) {
            return res.status(400).json({ error: 'Missing required fields: showName, targetLanguage, episode' });
        }
        if (!mistralClient) {
            return res.status(500).json({ error: 'Mistral API is not configured on the server.' });
        }

        const prompt = `
            Act as an expert language tutor. I am learning ${targetLanguage}.
            Generate a 5-question multiple-choice vocabulary quiz based on the likely plot, common dialogue, and themes of the Netflix show "${showName}", specifically referencing "${episode}".
            
            STRICTLY format your response as a raw JSON array of objects. Do not wrap it in markdown code blocks (\`\`\`json). Just return the array.
            Each object must have exactly these keys:
            - "question_text" (a string in English explaining the context or asking the translation)
            - "options" (an array with exactly 4 strings, which are the answers in ${targetLanguage})
            - "correct_answer" (a string matching exactly one of the options)
        `;

        const result = await mistralClient.chat.complete({
            model: "mistral-large-latest",
            messages: [{ role: "user", content: prompt }]
        });

        let rawText = result.choices[0].message.content;

        // Clean up potential markdown formatting that Mistral might mistakenly include
        rawText = rawText.replace(/```json/g, "").replace(/```/g, "").trim();

        const questionsJson = JSON.parse(rawText);

        return res.status(200).json({
            success: true,
            questions: questionsJson
        });

    } catch (error) {
        console.error("Quiz generation error:", error);
        res.status(500).json({ error: 'Internal server error while generating quiz.', details: error.message });
    }
});

// 2. Generate Flashcards from Mistakes
app.post('/flashcards/generate', async (req, res) => {
    try {
        const { mistakes, targetLanguage } = req.body;

        if (!mistakes || !Array.isArray(mistakes) || mistakes.length === 0 || !targetLanguage) {
            return res.status(400).json({ error: 'Missing required fields or mistakes array is empty.' });
        }
        if (!mistralClient) {
            return res.status(500).json({ error: 'Mistral API is not configured on the server.' });
        }

        const prompt = `
            Act as an expert ${targetLanguage} language tutor. 
            The user just took a quiz and got the following questions incorrect:
            ${JSON.stringify(mistakes)}
            
            Generate highly effective educational flashcards to help them learn from these specific mistakes.
            
            STRICTLY format your response as a raw JSON array of objects. Do not wrap it in markdown code blocks (\`\`\`json).
            Each object must have exactly these keys:
            - "front_text" (The target vocabulary word/phrase in ${targetLanguage})
            - "english_meaning" (The direct and simple English translation)
            - "mnemonic" (A short, clever memory device to remember it)
        `;

        const result = await mistralClient.chat.complete({
            model: "mistral-large-latest",
            messages: [{ role: "user", content: prompt }]
        });

        let rawText = result.choices[0].message.content;

        // Clean up formatting
        rawText = rawText.replace(/```json/g, "").replace(/```/g, "").trim();

        const flashcardsJson = JSON.parse(rawText);

        return res.status(200).json({
            success: true,
            flashcards: flashcardsJson
        });

    } catch (error) {
        console.error("Flashcard generation error:", error);
        res.status(500).json({ error: 'Internal server error while generating flashcards.', details: error.message });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`🚀 LanguageLearner Netflix Auth Backend running on port ${PORT}`);
});
