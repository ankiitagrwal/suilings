# Suilings Browser - UI/UX Wireframes & Design Specs

## 🎨 Design System

### Color Palette

#### Dark Theme (Primary)
```css
/* Background Colors */
--bg-primary: #0A0E1A;      /* Main background */
--bg-secondary: #141827;    /* Elevated surfaces */
--bg-tertiary: #1E2433;     /* Cards, panels */
--bg-hover: #2A3142;        /* Hover states */

/* Text Colors */
--text-primary: #E6E8F0;    /* Main text */
--text-secondary: #A0A8C5;  /* Secondary text */
--text-muted: #6B7394;      /* Muted text */

/* Accent Colors */
--accent-primary: #6366F1;   /* Indigo - Primary CTA */
--accent-secondary: #8B5CF6; /* Purple - Highlights */
--accent-success: #10B981;   /* Green - Success */
--accent-warning: #F59E0B;   /* Orange - Warning */
--accent-error: #EF4444;     /* Red - Errors */
--accent-info: #3B82F6;      /* Blue - Info */

/* Sui Branding */
--sui-blue: #4DA2FF;
--sui-cyan: #6FBCF0;
```

#### Light Theme (Optional)
```css
--bg-primary: #FFFFFF;
--bg-secondary: #F8FAFC;
--bg-tertiary: #F1F5F9;
--text-primary: #0F172A;
--text-secondary: #475569;
```

### Typography
```css
/* Font Family */
--font-display: 'Inter', system-ui, sans-serif;
--font-code: 'JetBrains Mono', 'Fira Code', monospace;

/* Font Sizes */
--text-xs: 0.75rem;    /* 12px */
--text-sm: 0.875rem;   /* 14px */
--text-base: 1rem;     /* 16px */
--text-lg: 1.125rem;   /* 18px */
--text-xl: 1.25rem;    /* 20px */
--text-2xl: 1.5rem;    /* 24px */
--text-3xl: 1.875rem;  /* 30px */
--text-4xl: 2.25rem;   /* 36px */

/* Font Weights */
--font-normal: 400;
--font-medium: 500;
--font-semibold: 600;
--font-bold: 700;
```

### Spacing
```css
--space-1: 0.25rem;   /* 4px */
--space-2: 0.5rem;    /* 8px */
--space-3: 0.75rem;   /* 12px */
--space-4: 1rem;      /* 16px */
--space-5: 1.25rem;   /* 20px */
--space-6: 1.5rem;    /* 24px */
--space-8: 2rem;      /* 32px */
--space-10: 2.5rem;   /* 40px */
--space-12: 3rem;     /* 48px */
```

### Border Radius
```css
--radius-sm: 0.375rem;  /* 6px */
--radius-md: 0.5rem;    /* 8px */
--radius-lg: 0.75rem;   /* 12px */
--radius-xl: 1rem;      /* 16px */
--radius-full: 9999px;  /* Circular */
```

---

## 📱 Page Wireframes

### 1. Landing Page (`/`)

```
┌──────────────────────────────────────────────────────────────────┐
│ HEADER                                                           │
│ ┌────────┐                        [Sign In] [Get Started →]     │
│ │ LOGO   │  Exercises  About  Docs  Community                   │
│ └────────┘                                                       │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│                         HERO SECTION                             │
│                                                                  │
│              Learn Move on Sui — In Your Browser                │
│                                                                  │
│       Master smart contract development with interactive         │
│              exercises. No installation required.                │
│                                                                  │
│                    [Start Learning →] [View Demo]                │
│                                                                  │
│                 ┌────────────────────────────┐                   │
│                 │                            │                   │
│                 │   [Code Editor Preview]    │                   │
│                 │   Animated typing demo     │                   │
│                 │                            │                   │
│                 └────────────────────────────┘                   │
│                                                                  │
├──────────────────────────────────────────────────────────────────┤
│                      FEATURES SECTION                            │
│                                                                  │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐   │
│  │   🚀 No Setup  │  │  ✅ Real-Time  │  │  🎯 Progress   │   │
│  │                │  │                │  │                │   │
│  │  Start coding  │  │  Instant       │  │  Track your    │   │
│  │  in seconds    │  │  feedback      │  │  learning      │   │
│  └────────────────┘  └────────────────┘  └────────────────┘   │
│                                                                  │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐   │
│  │  📚 Guided     │  │  💡 Hints      │  │  🏆 Gamified   │   │
│  │                │  │                │  │                │   │
│  │  Step-by-step  │  │  Stuck? Get    │  │  Earn badges   │   │
│  │  tutorials     │  │  hints         │  │  & rewards     │   │
│  └────────────────┘  └────────────────┘  └────────────────┘   │
│                                                                  │
├──────────────────────────────────────────────────────────────────┤
│                    HOW IT WORKS SECTION                          │
│                                                                  │
│   ① Choose Exercise  →  ② Write Code  →  ③ Get Feedback        │
│                                                                  │
├──────────────────────────────────────────────────────────────────┤
│                    TESTIMONIALS (Optional)                       │
├──────────────────────────────────────────────────────────────────┤
│                         FOOTER                                   │
│                                                                  │
│  Suilings © 2025  |  GitHub  |  Discord  |  Twitter  |  Docs   │
└──────────────────────────────────────────────────────────────────┘
```

---

### 2. Dashboard Page (`/dashboard`)

```
┌──────────────────────────────────────────────────────────────────┐
│ HEADER                                                           │
│ [LOGO] Dashboard  Exercises            [🔔] [👤 User Menu ▼]   │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Welcome back, John! 👋                                          │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │               YOUR PROGRESS                              │   │
│  │                                                          │   │
│  │  [████████░░░░░░░░░░░░] 8 / 25 exercises (32%)         │   │
│  │                                                          │   │
│  │  🔥 5-day streak    ⏱️ 12h total    ⭐ 3 badges earned  │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌──────────────────────────┐  ┌─────────────────────────────┐ │
│  │   CONTINUE LEARNING      │  │    RECENT ACTIVITY          │ │
│  │                          │  │                             │ │
│  │   📝 variables2          │  │  ✓ Completed intro1         │ │
│  │   "Variable scope..."    │  │  ✓ Completed variables1     │ │
│  │                          │  │  📝 Started variables2       │ │
│  │   [Continue →]           │  │  💡 Viewed hint for module1 │ │
│  └──────────────────────────┘  └─────────────────────────────┘ │
│                                                                  │
│  EXERCISES BY CATEGORY                                           │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Introduction (3/3) ✅                                   │   │
│  │  [✓] intro1    [✓] intro2    [✓] intro3                │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Variables (2/4)                                         │   │
│  │  [✓] variables1    [→] variables2    [ ] variables3     │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Modules (0/5)                                           │   │
│  │  [ ] module1    [ ] module2    [ ] module3  ...         │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

### 3. Exercise Page (`/exercise/[name]`) - Main View

```
┌──────────────────────────────────────────────────────────────────────────────┐
│ HEADER                                                                       │
│ [LOGO]  Exercise: variables1          [▶ Run] [💡 Hint] [🔄 Reset]  [User]│
├──────────────────────────────────────────────────────────────────────────────┤
│ [Progress: 2/25 ████░░░░░░░░░░░░░░░░░░░ 8%]   [← Prev] [Next →]           │
├─────────────────────────┬────────────────────────────────────────────────────┤
│                         │                                                    │
│  SIDEBAR (20%)          │         MAIN CONTENT AREA (80%)                   │
│                         │                                                    │
│  All Exercises ▼        │  ┌─────────────────────────────────────────────┐  │
│                         │  │  INSTRUCTIONS PANEL (Collapsible)           │  │
│  Introduction           │  │                                             │  │
│  ✓ intro1               │  │  Exercise: Variable Declaration             │  │
│  ✓ intro2               │  │                                             │  │
│  ✓ intro3               │  │  In Move, variables are declared using the  │  │
│                         │  │  'let' keyword. They are immutable by       │  │
│  Variables              │  │  default.                                   │  │
│  ✓ variables1           │  │                                             │  │
│  → variables2 ⚡        │  │  Your Task:                                 │  │
│  ○ variables3           │  │  • Fix the variable declaration on line 3   │  │
│  ○ variables4           │  │  • Make the variable mutable                │  │
│                         │  │  • Remove the "I AM NOT DONE" comment       │  │
│  Modules                │  │                                             │  │
│  ○ module1              │  └─────────────────────────────────────────────┘  │
│  ○ module2              │                                                    │
│  ○ module3              │  ┌─────────────────────────────────────────────┐  │
│                         │  │  CODE EDITOR (Monaco)                       │  │
│  [Keyboard Shortcuts]   │  │  ─────────────────────────────────────      │  │
│  [Settings]             │  │   1 │ // I AM NOT DONE                     │  │
│  [Help & Docs]          │  │   2 │                                      │  │
│                         │  │   3 │ module suilings::variables2 {        │  │
│                         │  │   4 │   public fun test_variables() {      │  │
│                         │  │   5 │     let x = 10; // Fix this          │  │
│                         │  │   6 │     x = 20;     // Should work       │  │
│                         │  │   7 │   }                                  │  │
│                         │  │   8 │ }                                    │  │
│                         │  │       [Auto-save: saved 2s ago]            │  │
│                         │  └─────────────────────────────────────────────┘  │
│                         │                                                    │
│                         │  ┌─────────────────────────────────────────────┐  │
│                         │  │  OUTPUT CONSOLE                             │  │
│                         │  │  ─────────────────────────────────          │  │
│                         │  │  ⚡ Building exercise...                    │  │
│                         │  │                                             │  │
│                         │  │  ❌ Build failed!                           │  │
│                         │  │                                             │  │
│                         │  │  error[E05001]: cannot assign to immutable │  │
│                         │  │     variable                                │  │
│                         │  │    ┌─ main.move:6:5                         │  │
│                         │  │    │                                        │  │
│                         │  │  6 │     x = 20;                            │  │
│                         │  │    │     ^^^^^^ Invalid assignment          │  │
│                         │  │                                             │  │
│                         │  │  💡 Hint: Try making the variable mutable  │  │
│                         │  │                                             │  │
│                         │  │  [Clear Console]                            │  │
│                         │  └─────────────────────────────────────────────┘  │
│                         │                                                    │
└─────────────────────────┴────────────────────────────────────────────────────┘
```

---

### 4. Exercise Success State

```
┌──────────────────────────────────────────────────────────────────┐
│                     OUTPUT CONSOLE                               │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                                                            │ │
│  │  ✅ Building exercise...                                   │ │
│  │  ✓ Build successful!                                       │ │
│  │                                                            │ │
│  │  ✅ Running tests...                                       │ │
│  │  ✓ test_variables ... ok                                   │ │
│  │  ✓ All tests passed!                                       │ │
│  │                                                            │ │
│  │  ┌──────────────────────────────────────────────────────┐ │ │
│  │  │                                                      │ │ │
│  │  │  🎉 Congratulations! 🎉                              │ │ │
│  │  │                                                      │ │ │
│  │  │  You've successfully completed variables2!          │ │ │
│  │  │                                                      │ │ │
│  │  │  You can keep working on this exercise, or           │ │ │
│  │  │  jump to the next one by removing the                │ │ │
│  │  │  // I AM NOT DONE comment                            │ │ │
│  │  │                                                      │ │ │
│  │  │     3 │ // I AM NOT DONE                             │ │ │
│  │  │                                                      │ │ │
│  │  │  [Continue to Next Exercise →]                       │ │ │
│  │  │                                                      │ │ │
│  │  └──────────────────────────────────────────────────────┘ │ │
│  │                                                            │ │
│  └────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
```

---

### 5. Hint Modal

```
┌──────────────────────────────────────────────────────────────────┐
│                                                                  │
│                    ╔════════════════════════╗                    │
│                    ║                        ║                    │
│                    ║  💡 Exercise Hint      ║                    │
│                    ║                        ║                    │
│                    ╠════════════════════════╣                    │
│                    ║                        ║                    │
│                    ║  In Move, variables    ║                    │
│                    ║  are immutable by      ║                    │
│                    ║  default.              ║                    │
│                    ║                        ║                    │
│                    ║  To make a variable    ║                    │
│                    ║  mutable, use the      ║                    │
│                    ║  'mut' keyword:        ║                    │
│                    ║                        ║                    │
│                    ║  let mut x = 10;       ║                    │
│                    ║                        ║                    │
│                    ║  [View Documentation]  ║                    │
│                    ║                        ║                    │
│                    ║       [Close]          ║                    │
│                    ║                        ║                    │
│                    ╚════════════════════════╝                    │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

### 6. User Profile Page

```
┌──────────────────────────────────────────────────────────────────┐
│ HEADER                                                           │
│ [LOGO]  Profile                            [User Menu ▼]        │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────┐  John Doe                                  │
│  │                 │  john@example.com                           │
│  │   [Avatar]      │  Joined Oct 2025                            │
│  │                 │  [Edit Profile]                             │
│  └─────────────────┘                                             │
│                                                                  │
│  ═══════════════════════════════════════════════════════════     │
│                                                                  │
│  STATISTICS                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Total      │  │  Completion  │  │  Time Spent  │          │
│  │  Exercises   │  │     Rate     │  │              │          │
│  │              │  │              │  │              │          │
│  │     25       │  │     32%      │  │    12.5h     │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Current    │  │    Longest   │  │   Exercises  │          │
│  │    Streak    │  │    Streak    │  │   This Week  │          │
│  │              │  │              │  │              │          │
│  │   🔥 5 days  │  │   🔥 12 days │  │      7       │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                  │
│  ACHIEVEMENTS                                                    │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  🏆 First Steps        ⭐ Week Warrior      🎯 Perfect 10 │   │
│  │  Complete first ex     7 days streak        10 exercises  │   │
│  │                                                            │   │
│  │  🚀 Speed Runner       💯 Perfectionist     🔥 On Fire    │   │
│  │  (Locked)              (Locked)             (Locked)      │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  RECENT ACTIVITY                                                 │
│  • Completed variables2 - 2 hours ago                            │
│  • Completed variables1 - 1 day ago                              │
│  • Earned badge "First Steps" - 3 days ago                       │
│                                                                  │
│  ACCOUNT SETTINGS                                                │
│  [Change Email]  [Change Password]  [Delete Account]            │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Component Specifications

### Button Components

```tsx
// Primary Button
<Button variant="primary" size="md">
  Start Learning
</Button>

// Styles:
- Background: var(--accent-primary)
- Hover: brightness(110%)
- Active: scale(0.98)
- Padding: 0.75rem 1.5rem
- Border-radius: var(--radius-md)
- Font-weight: var(--font-semibold)
- Transition: all 0.2s ease

// Secondary Button
<Button variant="secondary" size="md">
  View Hint
</Button>

// Styles:
- Background: var(--bg-tertiary)
- Border: 1px solid var(--bg-hover)
- Hover: background var(--bg-hover)

// Icon Button
<Button variant="icon" size="sm">
  <PlayIcon />
</Button>

// Sizes: xs, sm, md, lg
```

### Progress Bar

```tsx
<ProgressBar current={8} total={25} />

// Visual:
┌─────────────────────────────────────────────────────┐
│ [████████░░░░░░░░░░░░░░░] 8 / 25 exercises (32%)   │
└─────────────────────────────────────────────────────┘

// Features:
- Smooth animations
- Gradient fill
- Percentage label
- Responsive
```

### Exercise Card

```tsx
<ExerciseCard 
  name="variables1"
  status="completed"
  description="Learn about variable declaration"
/>

// States:
- pending: Gray, locked icon
- in-progress: Yellow, lightning icon
- completed: Green, checkmark icon

// Hover effect: Lift animation
```

### Code Editor Settings

```typescript
const editorOptions = {
  theme: 'vs-dark',  // Custom theme based on design system
  language: 'move',   // Custom Move language definition
  fontSize: 14,
  fontFamily: 'JetBrains Mono',
  lineNumbers: 'on',
  minimap: { enabled: true },
  scrollBeyondLastLine: false,
  wordWrap: 'on',
  automaticLayout: true,
  bracketPairColorization: { enabled: true },
  suggest: {
    showKeywords: true,
    showSnippets: true,
  },
}
```

---

## 📱 Responsive Design

### Breakpoints
```css
--screen-sm: 640px;   /* Mobile */
--screen-md: 768px;   /* Tablet */
--screen-lg: 1024px;  /* Desktop */
--screen-xl: 1280px;  /* Large Desktop */
```

### Mobile Layout (< 768px)

```
┌─────────────────────────┐
│ [☰] SUILINGS    [User] │
├─────────────────────────┤
│                         │
│  Exercise: variables1   │
│  ═════════════════════  │
│                         │
│  [Tabs: Desc | Code | Output]
│                         │
│  Tab Content Area       │
│  (Full width)           │
│                         │
│  [▶ Run]  [💡]  [🔄]   │
│                         │
└─────────────────────────┘
```

### Tablet Layout (768px - 1024px)

```
┌──────────────────────────────────────┐
│ [LOGO] Dashboard  [User Menu]       │
├──────────────────────────────────────┤
│                                      │
│  ┌────────────────────────────────┐ │
│  │   Instructions (Collapsible)   │ │
│  └────────────────────────────────┘ │
│                                      │
│  ┌────────────────────────────────┐ │
│  │   Code Editor                  │ │
│  │                                │ │
│  └────────────────────────────────┘ │
│                                      │
│  ┌────────────────────────────────┐ │
│  │   Output                       │ │
│  └────────────────────────────────┘ │
│                                      │
└──────────────────────────────────────┘
```

---

## 🎬 Animations & Micro-interactions

### Page Transitions
```tsx
// Framer Motion variants
const pageVariants = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  exit: { opacity: 0, y: -20 }
}

// Timing: 0.3s ease-out
```

### Button Hover
- Scale: 1.02
- Brightness: 110%
- Duration: 0.2s

### Exercise Completion
- Confetti animation
- Scale pulse effect
- Success sound (optional)

### Code Compilation
- Loading spinner in Run button
- Pulsing border around editor
- Progress indicator

### Auto-save Indicator
```
┌──────────────────────┐
│ ✓ Saved 2s ago       │
└──────────────────────┘

// Fade in/out animation
// Duration: 0.5s
```

---

## ♿ Accessibility

### WCAG 2.1 AA Compliance

1. **Color Contrast**
   - Text: Minimum 4.5:1 ratio
   - Large text: Minimum 3:1 ratio
   - Interactive elements: Minimum 3:1 ratio

2. **Keyboard Navigation**
   - All interactive elements focusable
   - Clear focus indicators
   - Logical tab order
   - Keyboard shortcuts (with hints)

3. **Screen Reader Support**
   - Semantic HTML
   - ARIA labels where needed
   - Alt text for images
   - Status announcements for async actions

4. **Reduced Motion**
   ```css
   @media (prefers-reduced-motion: reduce) {
     * {
       animation-duration: 0.01ms !important;
       transition-duration: 0.01ms !important;
     }
   }
   ```

---

## 🔧 Keyboard Shortcuts

```
Global:
  Ctrl/Cmd + K      → Open command palette
  Ctrl/Cmd + B      → Toggle sidebar
  /                 → Focus search
  ?                 → Show shortcuts help

Exercise Page:
  Ctrl/Cmd + Enter  → Run code
  Ctrl/Cmd + S      → Save (already auto-saves)
  Ctrl/Cmd + /      → Toggle comment
  Alt + H           → Show hint
  Alt + R           → Reset exercise
  Alt + N           → Next exercise
  Alt + P           → Previous exercise

Editor:
  (All Monaco default shortcuts)
  Ctrl/Cmd + F      → Find
  Ctrl/Cmd + H      → Replace
  Ctrl/Cmd + D      → Add selection to next match
  Alt + Up/Down     → Move line up/down
```

---

## 🎨 Loading States

### Skeleton Screens
```
Exercise List Loading:
┌─────────────────────────┐
│ ░░░░░░░░░░░░░░░░░░░░   │
│ ░░░░░░░░░░░░░░░░░░░░   │
│ ░░░░░░░░░░░░░░░░░░░░   │
│ ░░░░░░░░░░░░░░░░░░░░   │
└─────────────────────────┘

Code Compilation:
┌─────────────────────────┐
│ ⚡ Compiling...         │
│ [▓▓▓▓▓▓▓▓░░░░] 60%     │
└─────────────────────────┘
```

---

## 📊 Empty States

### No Exercises Started
```
┌─────────────────────────────────┐
│                                 │
│          📚                     │
│                                 │
│   Ready to Start Learning?      │
│                                 │
│   Choose your first exercise    │
│   from the sidebar.             │
│                                 │
│   [View All Exercises →]        │
│                                 │
└─────────────────────────────────┘
```

### No Recent Activity
```
┌─────────────────────────────────┐
│   📊 No activity yet            │
│                                 │
│   Start solving exercises to    │
│   see your progress here.       │
└─────────────────────────────────┘
```

---

## 🎯 Call-to-Action Hierarchy

1. **Primary CTA**: "Run Code" button
   - Most prominent
   - Always visible
   - Clear affordance

2. **Secondary CTA**: "Show Hint", "Reset"
   - Less prominent but accessible
   - Secondary styling

3. **Tertiary CTA**: Navigation, settings
   - Subtle, contextual

---

## 💬 Toast Notifications

```tsx
// Success
<Toast variant="success">
  ✓ Code compiled successfully!
</Toast>

// Error
<Toast variant="error">
  ✗ Compilation failed. Check errors below.
</Toast>

// Info
<Toast variant="info">
  💾 Progress saved automatically
</Toast>

// Warning
<Toast variant="warning">
  ⚠️ You have unsaved changes
</Toast>

// Position: Bottom right
// Duration: 3-5 seconds
// Dismissible: Yes
// Stack: Yes (max 3)
```

---

This design system provides a complete foundation for implementing the Suilings browser interface. The dark-first theme, clear hierarchy, and smooth animations will create an engaging learning experience while maintaining excellent usability and accessibility.

**Next step**: Create high-fidelity mockups in Figma based on these wireframes! 🎨

