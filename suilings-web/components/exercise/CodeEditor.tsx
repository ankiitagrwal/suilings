"use client";

import { useEffect, useRef } from "react";
import Editor from "@monaco-editor/react";
import { useExerciseStore } from "@/lib/store/exerciseStore";
import { useTheme } from "next-themes";
import { Loader2 } from "lucide-react";

export function CodeEditor() {
  const { currentCode, setCurrentCode } = useExerciseStore();
  const { theme } = useTheme();
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const editorRef = useRef<any>(null);
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const monacoRef = useRef<any>(null);

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const handleEditorDidMount = (editor: any, monaco: any) => {
    editorRef.current = editor;
    monacoRef.current = monaco;

    // Define Move language syntax highlighting
    monaco.languages.register({ id: "move" });

    monaco.languages.setMonarchTokensProvider("move", {
      keywords: [
        "module",
        "public",
        "fun",
        "struct",
        "has",
        "copy",
        "drop",
        "store",
        "key",
        "let",
        "mut",
        "return",
        "if",
        "else",
        "while",
        "loop",
        "break",
        "continue",
        "abort",
        "assert",
        "move",
        "copy",
        "use",
        "as",
        "const",
        "native",
        "friend",
        "acquires",
        "script",
        "entry",
      ],
      typeKeywords: ["bool", "u8", "u16", "u32", "u64", "u128", "u256", "address", "vector"],
      operators: ["=", ">", "<", "!", "~", "?", ":", "==", "<=", ">=", "!=", "&&", "||", "+", "-", "*", "/", "&", "|", "^", "%", "<<", ">>"],
      symbols: /[=><!~?:&|+\-*\/\^%]+/,
      tokenizer: {
        root: [
          // identifiers and keywords
          [
            /[a-z_$][\w$]*/,
            {
              cases: {
                "@typeKeywords": "type.identifier",
                "@keywords": "keyword",
                "@default": "identifier",
              },
            },
          ],
          [/[A-Z][\w\$]*/, "type.identifier"],
          // whitespace
          { include: "@whitespace" },
          // delimiters and operators
          [/[{}()\[\]]/, "@brackets"],
          [/[<>](?!@symbols)/, "@brackets"],
          [/@symbols/, { cases: { "@operators": "operator", "@default": "" } }],
          // numbers
          [/\d*\.\d+([eE][\-+]?\d+)?/, "number.float"],
          [/0[xX][0-9a-fA-F]+/, "number.hex"],
          [/\d+/, "number"],
          // delimiter: after number because of .\d floats
          [/[;,.]/, "delimiter"],
          // strings
          [/"([^"\\]|\\.)*$/, "string.invalid"],
          [/"/, { token: "string.quote", bracket: "@open", next: "@string" }],
          // byte strings
          [/b"([^"\\]|\\.)*$/, "string.invalid"],
          [/b"/, { token: "string.quote", bracket: "@open", next: "@string" }],
        ],
        string: [
          [/[^\\"]+/, "string"],
          [/\\./, "string.escape.invalid"],
          [/"/, { token: "string.quote", bracket: "@close", next: "@pop" }],
        ],
        whitespace: [
          [/[ \t\r\n]+/, "white"],
          [/\/\*/, "comment", "@comment"],
          [/\/\/.*$/, "comment"],
        ],
        comment: [
          [/[^\/*]+/, "comment"],
          [/\/\*/, "comment", "@push"],
          ["\\*/", "comment", "@pop"],
          [/[\/*]/, "comment"],
        ],
      },
    });

    // Configure dark theme
    monaco.editor.defineTheme("move-dark", {
      base: "vs-dark",
      inherit: true,
      rules: [
        { token: "keyword", foreground: "C586C0" },
        { token: "type.identifier", foreground: "4EC9B0" },
        { token: "identifier", foreground: "9CDCFE" },
        { token: "string", foreground: "CE9178" },
        { token: "number", foreground: "B5CEA8" },
        { token: "comment", foreground: "6A9955", fontStyle: "italic" },
      ],
      colors: {
        "editor.background": "#0A0E1A",
        "editor.foreground": "#E6E8F0",
        "editor.lineHighlightBackground": "#1E2433",
        "editorCursor.foreground": "#6366F1",
        "editor.selectionBackground": "#2A3142",
      },
    });

    // Configure light theme
    monaco.editor.defineTheme("move-light", {
      base: "vs",
      inherit: true,
      rules: [
        { token: "keyword", foreground: "AF00DB" },
        { token: "type.identifier", foreground: "267F99" },
        { token: "identifier", foreground: "001080" },
        { token: "string", foreground: "A31515" },
        { token: "number", foreground: "098658" },
        { token: "comment", foreground: "008000", fontStyle: "italic" },
      ],
      colors: {
        "editor.background": "#FFFFFF",
        "editor.foreground": "#000000",
        "editor.lineHighlightBackground": "#F0F0F0",
        "editorCursor.foreground": "#6366F1",
        "editor.selectionBackground": "#ADD6FF",
      },
    });

    // Set initial theme
    const initialTheme = theme === "dark" ? "move-dark" : "move-light";
    monaco.editor.setTheme(initialTheme);
  };

  // Update editor theme when app theme changes
  useEffect(() => {
    if (monacoRef.current && editorRef.current) {
      const editorTheme = theme === "dark" ? "move-dark" : "move-light";
      monacoRef.current.editor.setTheme(editorTheme);
    }
  }, [theme]);

  const handleEditorChange = (value: string | undefined) => {
    if (value !== undefined) {
      setCurrentCode(value);
    }
  };

  return (
    <div className="h-full w-full bg-background">
      <Editor
        height="100%"
        defaultLanguage="move"
        value={currentCode}
        onChange={handleEditorChange}
        onMount={handleEditorDidMount}
        theme={theme === "dark" ? "move-dark" : "move-light"}
        loading={
          <div className="flex items-center justify-center h-full">
            <Loader2 className="h-8 w-8 animate-spin text-primary" />
          </div>
        }
        options={{
          fontSize: 14,
          fontFamily: "'JetBrains Mono', 'Fira Code', monospace",
          lineNumbers: "on",
          minimap: { enabled: true },
          scrollBeyondLastLine: false,
          wordWrap: "on",
          automaticLayout: true,
          bracketPairColorization: { enabled: true },
          tabSize: 4,
          insertSpaces: true,
          formatOnPaste: true,
          formatOnType: true,
        }}
      />
    </div>
  );
}

