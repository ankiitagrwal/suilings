# Suilings Web App

Interactive learning platform for Move programming language on Sui blockchain.

## 🚀 Quick Start

### 1. Install Dependencies

```bash
npm install
```

### 2. Setup Environment Variables

Copy the example environment file:

```bash
cp env.example .env
```

> **Note:** Next.js loads environment variables from `.env` (which is git-ignored). Either `.env` or `.env.local` works - both are safe!

### 3. Configure Required Variables

**Required - Gemini API Key (FREE):**

Get your free API key from [Google AI Studio](https://aistudio.google.com/app/apikey)

```env
GEMINI_API_KEY=AIza...your_key_here
```

**Optional - Supabase (for authentication):**

If you want user accounts and progress saving:

```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
```

> **Note:** The app works without Supabase, but progress won't be saved across sessions.

### 4. Run Development Server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) 🎉

## 📝 Environment Files Explained

Next.js loads environment variables in this order:
1. `.env.local` (highest priority, git-ignored)
2. `.env` (git-ignored)
3. `.env.production` or `.env.development` (committed to git)

**For local development:** Use either `.env` or `.env.local` - both work!

## 🛠️ Available Scripts

```bash
npm run dev              # Start dev server with hot reload
npm run dev:watch        # Watch exercises folder for changes
npm run build            # Build for production
npm run start            # Start production server
npm run lint             # Run ESLint
npm run seed:exercises   # Seed exercises to Supabase
```

## 🔑 Getting API Keys

### Google Gemini (Required for AI features)

1. Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Click "Create API Key"
3. Copy the key (starts with `AIza...`)
4. Add to `.env` file

**Cost:** FREE! 🎉
- 60 requests per minute
- 1,500 requests per day

### Supabase (Optional for auth)

1. Create account at [Supabase](https://supabase.com)
2. Create new project
3. Go to Settings > API
4. Copy URL and anon key
5. Add to `.env` file

## 🏗️ Project Structure

```
suilings-web/
├── app/                 # Next.js App Router pages
├── components/          # React components
├── lib/                 # Utilities and helpers
├── public/              # Static assets
├── env.example          # Environment template
└── package.json
```

## 🐛 Troubleshooting

### AI not working?

1. Check `.env` file has `GEMINI_API_KEY`
2. Restart dev server: `npm run dev`
3. Check console for errors

### Authentication not working?

1. Verify Supabase keys in `.env`
2. Check Supabase dashboard is accessible
3. Auth is optional - app works without it

## 📚 Learn More

- [Next.js Documentation](https://nextjs.org/docs)
- [Move Language](https://move-language.github.io/move/)
- [Sui Documentation](https://docs.sui.io/)
- [Google Gemini](https://ai.google.dev/)

## 🤝 Contributing

When sharing your setup with other developers:
1. Never commit `.env` or `.env.local` files (they're in `.gitignore`)
2. Update `env.example` with new variables
3. Document any new environment requirements in this README

---

Built with ❤️ for the Sui community
