# Suilings Browser Version - Plan & Design Document

## 📋 Executive Summary

Transform Suilings from a CLI-based interactive Move learning platform into a full-featured web application that allows users to learn Move programming for Sui blockchain directly in their browser, without installing any local dependencies.

---

## 🎯 Project Goals

1. **Zero-Installation Learning**: Users can start learning Move without installing Rust, Sui CLI, or any local tooling
2. **Interactive Code Editor**: Real-time code editing with syntax highlighting for Move language
3. **Live Compilation & Testing**: Compile and test Move code in the browser with instant feedback
4. **Progress Tracking**: Save user progress across sessions
5. **Beautiful UI/UX**: Modern, responsive interface with excellent user experience
6. **Feature Parity**: Maintain all CLI features (watch mode, hints, reset, progress tracking)

---

## 🏗️ Architecture Overview

### **Option A: Full Cloud Backend (Recommended)**
```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│   React/Next.js │◄───────►│  Backend API     │◄───────►│  Sui Compiler   │
│   Frontend      │   HTTPS │  (Rust/Node.js)  │   IPC   │  Service        │
│                 │         │                  │         │                 │
│  - Code Editor  │         │  - Exercise Mgmt │         │  - sui build    │
│  - UI/UX        │         │  - User Auth     │         │  - sui test     │
│  - Progress Bar │         │  - Code Compile  │         │  - Sandboxed    │
└─────────────────┘         └──────────────────┘         └─────────────────┘
                                     │
                                     ▼
                            ┌──────────────────┐
                            │   PostgreSQL/    │
                            │   MongoDB        │
                            │  - User Progress │
                            │  - Exercise Data │
                            └──────────────────┘
```

### **Option B: Hybrid (WASM + Backend)**
```
┌─────────────────────────────────────────────┐
│         React/Next.js Frontend              │
│  ┌────────────────┐   ┌──────────────────┐ │
│  │  Monaco Editor │   │  Move Parser     │ │
│  │  (Code Edit)   │   │  (WASM Module)   │ │
│  └────────────────┘   └──────────────────┘ │
└──────────────┬──────────────────────────────┘
               │ HTTPS
               ▼
    ┌──────────────────┐
    │  Backend API     │
    │  - Compilation   │
    │  - User Data     │
    └──────────────────┘
```

### **Option C: Full Client-Side (Future/Advanced)**
```
┌─────────────────────────────────────────────┐
│         Progressive Web App (PWA)           │
│  ┌────────────────┐   ┌──────────────────┐ │
│  │  Monaco Editor │   │  Move Compiler   │ │
│  │                │   │  (WASM)          │ │
│  └────────────────┘   └──────────────────┘ │
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │   IndexedDB (Local Storage)          │  │
│  └──────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

**Recommendation**: Start with **Option A** for reliability and security, gradually add WASM optimizations.

---

## 💻 Technology Stack

### **Frontend**
- **Framework**: Next.js 14+ (React with App Router)
- **Language**: TypeScript
- **Code Editor**: Monaco Editor (VSCode's editor)
- **Styling**: Tailwind CSS + shadcn/ui components
- **State Management**: Zustand or React Context
- **Animations**: Framer Motion
- **Icons**: Lucide React

### **Backend**
- **Option 1 (Recommended)**: Rust with Axum
  - Native Sui integration
  - High performance
  - Type safety
  - Easy to integrate existing Rust code
  
- **Option 2**: Node.js with Express/Fastify
  - Easier for web developers
  - Rich npm ecosystem
  - Child process to call `sui` CLI

- **Option 3**: Go with Gin/Fiber
  - Good performance
  - Easy deployment
  - Strong concurrency

### **Database**
- **PostgreSQL** (structured data, user accounts)
- **Redis** (session management, caching)

### **Infrastructure**
- **Hosting**: Vercel (Frontend) + Railway/Fly.io/AWS (Backend)
- **CI/CD**: GitHub Actions
- **Monitoring**: Sentry + Posthog/Mixpanel
- **Authentication**: NextAuth.js or Clerk

### **Code Compilation Service**
- Containerized Sui CLI (Docker)
- Queue system for compilation jobs (BullMQ/RabbitMQ)
- Rate limiting and sandboxing for security
- Timeout mechanisms

---

## 🎨 UI/UX Design

### **Layout Structure**

```
┌─────────────────────────────────────────────────────────────────┐
│  Header: [Suilings Logo] [Progress: 1/10] [User] [Theme Toggle] │
├──────────────────┬──────────────────────────────────────────────┤
│                  │                                              │
│  Sidebar         │         Main Content Area                   │
│                  │                                              │
│  ✓ intro1       │  ┌────────────────────────────────────────┐  │
│  → variables1   │  │  Exercise: variables1                  │  │
│  ○ module1      │  │  ───────────────────────────────────   │  │
│  ○ module2      │  │                                        │  │
│                  │  │  Learn about variable declaration in  │  │
│  [Run Code]     │  │  Move...                               │  │
│  [Reset]        │  │                                        │  │
│  [Show Hint]    │  │  Your task:                            │  │
│                  │  │  - Fix the variable declaration       │  │
│                  │  └────────────────────────────────────────┘  │
│                  │                                              │
│                  │  ┌────────────────────────────────────────┐  │
│                  │  │  Code Editor (Monaco)                  │  │
│                  │  │  ─────────────────────────────────     │  │
│                  │  │   1 | module suilings::variables1 {   │  │
│                  │  │   2 |   public fun test() {           │  │
│                  │  │   3 |     let x = 10;                 │  │
│                  │  │   4 |   }                             │  │
│                  │  │   5 | }                               │  │
│                  │  └────────────────────────────────────────┘  │
│                  │                                              │
│                  │  ┌────────────────────────────────────────┐  │
│                  │  │  Output Console                        │  │
│                  │  │  ──────────────────────────────────    │  │
│                  │  │  ✓ Build successful!                  │  │
│                  │  │  ✓ All tests passed!                  │  │
│                  │  │                                        │  │
│                  │  │  🎉 Great job! Remove // I AM NOT    │  │
│                  │  │  DONE to proceed to the next exercise │  │
│                  │  └────────────────────────────────────────┘  │
└──────────────────┴──────────────────────────────────────────────┘
```

### **Key Pages**

1. **Landing Page** (`/`)
   - Hero section with "Start Learning" CTA
   - Features overview
   - Testimonials
   - Quick preview of the interface

2. **Dashboard** (`/dashboard`)
   - Progress overview
   - Recently worked exercises
   - Quick access to continue learning
   - Statistics (exercises completed, time spent, etc.)

3. **Exercise Page** (`/exercise/[name]`)
   - Split view: Instructions + Code Editor + Output
   - Resizable panels
   - Auto-save functionality
   - Real-time syntax highlighting

4. **Profile Page** (`/profile`)
   - User statistics
   - Achievements/badges
   - Learning streak
   - Reset progress option

5. **About/Help Page** (`/about`)
   - Getting started guide
   - Move language resources
   - FAQ
   - Community links

### **Design Principles**

1. **Clean & Minimal**: Focus on learning, not distractions
2. **Dark Mode First**: Comfortable for long coding sessions
3. **Responsive**: Mobile-friendly (at least for viewing, editing on desktop recommended)
4. **Accessible**: WCAG 2.1 AA compliant
5. **Fast**: Optimistic UI updates, instant feedback
6. **Gamified**: Progress bars, achievements, streaks

---

## 🔑 Core Features

### **Phase 1: MVP (Minimum Viable Product)**

1. ✅ **Exercise Navigation**
   - List all exercises from `info.toml`
   - Navigate between exercises
   - Show completion status

2. ✅ **Code Editor**
   - Monaco editor with Move syntax highlighting
   - Auto-save to localStorage
   - Line numbers, folding, bracket matching

3. ✅ **Compilation & Testing**
   - "Run" button to compile code
   - Display compilation errors
   - Show test results
   - Parse `// I AM NOT DONE` marker

4. ✅ **Progress Tracking**
   - Track which exercises are completed
   - Progress bar
   - Save to localStorage (no account needed for MVP)

5. ✅ **Basic UI**
   - Sidebar with exercise list
   - Main editor area
   - Output console
   - Hint display

### **Phase 2: Enhanced Features**

6. ✅ **User Authentication**
   - Sign up / Sign in
   - OAuth (Google, GitHub)
   - Save progress to database

7. ✅ **Improved Editor**
   - Move language IntelliSense (autocomplete)
   - Error highlighting inline
   - Code formatting
   - Keyboard shortcuts

8. ✅ **Watch Mode (Auto-run)**
   - Toggle to auto-compile on save
   - Debounced to avoid excessive requests
   - Visual indicator of compilation status

9. ✅ **Reset Exercise**
   - Reset to original state
   - Confirmation dialog

10. ✅ **Exercise Statistics**
    - Time spent on each exercise
    - Number of attempts
    - Completion time

### **Phase 3: Advanced Features**

11. ✅ **Social Features**
    - Share solutions (optional, with privacy controls)
    - Leaderboard
    - Discussion forums per exercise

12. ✅ **Improved Learning**
    - Video tutorials (embedded)
    - Interactive explanations
    - Quizzes after sections
    - Achievement badges

13. ✅ **Code Playground**
    - Blank canvas to experiment
    - Save custom snippets
    - Fork exercises

14. ✅ **Mobile App**
    - React Native or Progressive Web App
    - View exercises and hints on mobile
    - Code on desktop, review on mobile

15. ✅ **AI Assistant** (Optional)
    - ChatGPT/Claude integration for hints
    - Explain errors in plain English
    - Suggest fixes (with toggle to disable)

---

## 🔐 Security Considerations

### **Code Execution Sandboxing**
- **Docker Containers**: Each compilation runs in isolated container
- **Resource Limits**: CPU, memory, disk usage limits
- **Timeout**: Max execution time (e.g., 30 seconds)
- **Network Isolation**: No internet access from compilation environment
- **Input Validation**: Sanitize all code inputs

### **Rate Limiting**
- Per user: 10 compilations per minute
- Per IP: 50 compilations per minute
- Gradual backoff for repeated failures

### **Authentication & Authorization**
- JWT tokens with short expiry
- HTTPS only
- CORS configured properly
- SQL injection prevention (parameterized queries)
- XSS protection (sanitize outputs)

### **Monitoring**
- Log all compilation requests
- Alert on suspicious patterns
- Track resource usage
- Automatic banning for abuse

---

## 📊 Database Schema

### **Users Table**
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  username VARCHAR(50) UNIQUE NOT NULL,
  password_hash VARCHAR(255), -- nullable for OAuth users
  oauth_provider VARCHAR(50),
  oauth_id VARCHAR(255),
  created_at TIMESTAMP DEFAULT NOW(),
  last_login TIMESTAMP,
  avatar_url TEXT
);
```

### **Exercise Progress Table**
```sql
CREATE TABLE exercise_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  exercise_name VARCHAR(100) NOT NULL,
  status VARCHAR(20) DEFAULT 'pending', -- pending, completed
  code TEXT, -- user's current code
  attempts INT DEFAULT 0,
  time_spent INT DEFAULT 0, -- seconds
  completed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, exercise_name)
);
```

### **Exercises Table** (Cache from info.toml)
```sql
CREATE TABLE exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) UNIQUE NOT NULL,
  path TEXT NOT NULL,
  mode VARCHAR(20) NOT NULL, -- build, test
  hint TEXT,
  description TEXT,
  initial_code TEXT NOT NULL,
  order_index INT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### **Compilation Logs** (Optional, for monitoring)
```sql
CREATE TABLE compilation_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  exercise_name VARCHAR(100),
  success BOOLEAN,
  duration_ms INT,
  error_message TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

---

## 🚀 API Endpoints

### **Authentication**
- `POST /api/auth/signup` - Register new user
- `POST /api/auth/login` - Login
- `POST /api/auth/logout` - Logout
- `GET /api/auth/me` - Get current user

### **Exercises**
- `GET /api/exercises` - List all exercises
- `GET /api/exercises/:name` - Get specific exercise
- `POST /api/exercises/:name/reset` - Reset to original code

### **Code Execution**
- `POST /api/compile` - Compile Move code
  ```json
  {
    "exercise_name": "intro1",
    "code": "module suilings::intro1 { ... }",
    "mode": "test"
  }
  ```
  Response:
  ```json
  {
    "success": true,
    "output": "Build successful!",
    "errors": [],
    "is_done": false // based on "I AM NOT DONE" check
  }
  ```

### **Progress**
- `GET /api/progress` - Get user's progress
- `PUT /api/progress/:exercise_name` - Update exercise progress
  ```json
  {
    "code": "...",
    "status": "completed"
  }
  ```

### **User Stats**
- `GET /api/stats` - Get user statistics
  ```json
  {
    "total_exercises": 10,
    "completed": 3,
    "in_progress": 1,
    "time_spent": 3600,
    "streak_days": 5
  }
  ```

---

## 🛠️ Development Roadmap

### **Week 1-2: Setup & Infrastructure**
- [ ] Initialize Next.js project with TypeScript
- [ ] Setup Tailwind CSS + shadcn/ui
- [ ] Create basic layout and routing
- [ ] Setup backend project (choose tech stack)
- [ ] Setup PostgreSQL database
- [ ] Create Docker image for Sui compilation

### **Week 3-4: Core Features**
- [ ] Implement exercise listing from info.toml
- [ ] Integrate Monaco editor
- [ ] Build API for code compilation
- [ ] Implement exercise navigation
- [ ] Add progress tracking (localStorage)

### **Week 5-6: Compilation & Testing**
- [ ] Sandbox Sui CLI execution
- [ ] Parse compilation errors
- [ ] Parse test results
- [ ] Display output in UI
- [ ] Handle "I AM NOT DONE" logic

### **Week 7-8: User Experience**
- [ ] Add hints functionality
- [ ] Implement reset exercise
- [ ] Add auto-save
- [ ] Improve error display
- [ ] Add loading states & animations

### **Week 9-10: Authentication & Database**
- [ ] Implement user authentication
- [ ] Migrate progress to database
- [ ] Add user profile page
- [ ] Implement save/load code functionality

### **Week 11-12: Polish & Deploy**
- [ ] Add dark/light theme toggle
- [ ] Responsive design improvements
- [ ] SEO optimization
- [ ] Performance optimization
- [ ] Deploy to production
- [ ] Setup monitoring & analytics

### **Post-Launch: Enhancements**
- [ ] Watch mode (auto-run)
- [ ] Advanced editor features (IntelliSense)
- [ ] Social features (share, leaderboard)
- [ ] Mobile optimization
- [ ] Additional exercises

---

## 📈 Success Metrics

### **User Engagement**
- Number of registered users
- Daily active users (DAU)
- Exercises completed per user
- Average session duration
- Return rate (7-day, 30-day)

### **Technical Performance**
- Page load time < 2 seconds
- API response time < 500ms
- Compilation time < 5 seconds
- Uptime > 99.5%

### **Learning Outcomes**
- Exercise completion rate
- Time to complete each exercise
- User feedback/ratings
- Number of hint requests

---

## 🎯 Competitive Analysis

### **Similar Platforms**
1. **Rustlings** (CLI only)
2. **Codecademy** (Web-based, proprietary)
3. **Exercism.io** (Web + CLI)
4. **LeetCode** (Algorithm focus)
5. **CryptoZombies** (Solidity, gamified)

### **Suilings Browser Differentiators**
- ✅ First browser-based Move learning platform
- ✅ Sui-specific smart contract focus
- ✅ Open-source
- ✅ No installation required
- ✅ Real Sui compiler, not a mock
- ✅ Beautiful, modern UI
- ✅ Gamification elements

---

## 💰 Monetization (Optional, Future)

1. **Freemium Model**
   - Basic exercises: Free
   - Advanced exercises: Paid
   - Pro features: $9/month

2. **Sponsored Content**
   - Partner with Sui ecosystem projects
   - Featured exercises from partners

3. **Enterprise License**
   - Custom exercises
   - Team management
   - Analytics dashboard

4. **Donations**
   - GitHub Sponsors
   - Buy Me a Coffee
   - Cryptocurrency donations

---

## 🤝 Contributing & Community

- GitHub repository (open-source)
- Discord community
- Monthly contributor calls
- Issue templates
- Contributing guidelines
- Code of conduct

---

## 🚧 Challenges & Mitigations

### **Challenge 1: Sui CLI Compilation Time**
- **Issue**: Compilation can be slow (5-10 seconds)
- **Mitigation**: 
  - Show progress indicators
  - Cache compiled dependencies
  - Use faster machines for backend
  - Consider WASM in future

### **Challenge 2: Server Costs**
- **Issue**: Running Sui CLI for every user can be expensive
- **Mitigation**:
  - Rate limiting
  - Efficient resource allocation
  - Caching results for identical code
  - Gradual scaling

### **Challenge 3: Security**
- **Issue**: User code execution is risky
- **Mitigation**:
  - Docker sandboxing
  - Resource limits
  - Input validation
  - Monitoring & alerts

### **Challenge 4: Move Syntax Highlighting**
- **Issue**: Monaco doesn't have built-in Move support
- **Mitigation**:
  - Create custom Move language definition
  - Leverage existing Move tree-sitter grammar
  - Community contributions

---

## 📚 Resources Needed

### **Team**
- 1 Full-stack Developer
- 1 UI/UX Designer (part-time)
- 1 DevOps Engineer (part-time)
- Optional: 1 Technical Writer

### **Infrastructure**
- Frontend hosting: Vercel ($0-20/month)
- Backend hosting: Railway/Fly.io ($20-100/month)
- Database: PostgreSQL managed service ($15-50/month)
- Redis: Upstash ($0-25/month)
- Domain: $10-20/year
- **Total**: ~$50-200/month depending on traffic

### **Tools & Services**
- GitHub (free)
- Figma (free tier)
- Sentry ($0-26/month)
- Posthog ($0+, based on usage)

---

## 🎉 Conclusion

This browser-based version of Suilings will democratize Move programming education by removing installation barriers and providing an engaging, interactive learning experience. With a phased approach, we can deliver an MVP quickly while building toward a feature-rich platform.

**Next Steps:**
1. Review and approve this plan
2. Choose specific technologies for backend
3. Create detailed wireframes/mockups
4. Set up development environment
5. Begin Phase 1 implementation

---

**Document Version**: 1.0  
**Last Updated**: October 29, 2025  
**Author**: Suilings Development Team  

