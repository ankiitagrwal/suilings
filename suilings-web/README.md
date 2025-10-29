# Suilings Web

> Learn Move on Sui — interactively, in your browser.

A modern web-based learning platform for Move programming on the Sui blockchain. Built with Next.js 14, TypeScript, and Monaco Editor.

## 🚀 Features

- **No Setup Required**: Start learning immediately in your browser
- **Interactive Code Editor**: Full-featured Monaco editor with Move syntax highlighting
- **Real-time Feedback**: Instant compilation and test results
- **Progress Tracking**: Save your progress with localStorage (Zustand)
- **Responsive Layout**: Horizontal split design for better code visibility
- **Dark Mode First**: Beautiful dark theme optimized for coding

## 🛠️ Tech Stack

- **Frontend**: Next.js 14 (App Router) + TypeScript
- **Styling**: Tailwind CSS + shadcn/ui
- **Code Editor**: Monaco Editor
- **State Management**: Zustand
- **UI Components**: shadcn/ui (Radix UI)
- **Icons**: Lucide React
- **Toasts**: Sonner

## 📦 Installation

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Start production server
npm start
```

## 🏗️ Project Structure

```
suilings-web/
├── app/
│   ├── page.tsx              # Landing page
│   ├── exercise/
│   │   └── page.tsx          # Main exercise page
│   ├── layout.tsx            # Root layout
│   └── globals.css           # Global styles
├── components/
│   ├── layout/
│   │   ├── Header.tsx        # Header with actions
│   │   └── Sidebar.tsx       # Exercise list sidebar
│   ├── exercise/
│   │   ├── CodeEditor.tsx    # Monaco code editor
│   │   ├── ExerciseInstructions.tsx
│   │   ├── OutputConsole.tsx # Compilation output
│   │   └── HintDialog.tsx    # Hint modal
│   └── ui/                   # shadcn/ui components
├── lib/
│   ├── store/
│   │   └── exerciseStore.ts  # Zustand store
│   ├── exerciseLoader.ts     # Load exercises
│   └── utils.ts              # Utility functions
└── types/
    └── exercise.ts           # TypeScript types
```

## 🎨 Layout

The application uses a horizontal split layout:

```
┌────────────────────────────────────────────────────┐
│ Header: [Logo] [Actions] [Progress]               │
├──────────┬──────────────────┬──────────────────────┤
│          │   Exercise       │   Code Editor        │
│ Sidebar  │   Instructions   │   (60%)              │
│          │   (30%)          ├──────────────────────┤
│          │                  │   Output Console     │
│          │                  │   (40%)              │
└──────────┴──────────────────┴──────────────────────┘
```

## 🔧 Key Features

### Auto-Complete on Success
- Automatically marks exercises as complete when code compiles/tests pass
- Clean code editor without manual markers or comments

### Resizable Panels
- Drag panel dividers to resize sections
- Horizontal and vertical splits for optimal workflow

### Monaco Editor
- Move language syntax highlighting
- Custom dark theme matching the app design
- Line numbers, minimap, and bracket matching
- Auto-save functionality

### State Persistence
- Progress saved to localStorage
- Code changes persist across sessions
- Resume where you left off

## 🎯 Next Steps

### Phase 1: Current Implementation ✅
- [x] Basic UI layout
- [x] Exercise navigation
- [x] Code editor with Move highlighting
- [x] Mock compilation results
- [x] Progress tracking

### Phase 2: Backend Integration (TODO)
- [ ] Node.js/Express backend
- [ ] Real Sui CLI integration
- [ ] Docker-based code compilation
- [ ] User authentication (optional)
- [ ] Database integration (Supabase)

### Phase 3: Advanced Features (TODO)
- [ ] Real-time collaboration
- [ ] Code sharing
- [ ] Leaderboards
- [ ] Additional exercises
- [ ] Video tutorials
- [ ] AI-powered hints

## 📝 Development

### Adding New Exercises

1. Edit `lib/exerciseLoader.ts`
2. Add exercise object with:
   - name
   - path
   - mode (build/test)
   - hint
   - description
   - initialCode

Example:
```typescript
{
  name: "structs1",
  path: "exercises/structs/structs1.move",
  mode: "test",
  hint: "Structs define custom types...",
  description: "Learn about struct definitions in Move",
  initialCode: `module suilings::structs1 { ... }`,
  status: "pending",
}
```

### Customizing Theme

Edit `app/globals.css` to customize colors:
- Dark theme variables under `.dark`
- Adjust `--background`, `--foreground`, `--primary`, etc.

## 🐛 Known Issues

- Mock compilation results (backend integration needed)
- No real Sui CLI integration yet
- Limited to 4 sample exercises

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

MIT License - see the LICENSE file for details.

## 🔗 Links

- [Sui Blockchain](https://sui.io/)
- [Move Language](https://github.com/move-language/move)
- [Next.js](https://nextjs.org/)
- [Monaco Editor](https://microsoft.github.io/monaco-editor/)

---

Made with ❤️ for the Sui community
