"use client";

import { useState, useEffect } from "react";
import Editor from "@monaco-editor/react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Switch } from "@/components/ui/switch";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { 
  Play, 
  Save, 
  Share2, 
  GitFork,
  Download,
  Loader2,
  Check,
  FileCode,
} from "lucide-react";
import { useTheme } from "next-themes";
import { toast } from "sonner";
import { SimpleHeader } from "@/components/layout/SimpleHeader";
import { TemplateSelector } from "@/components/playground/TemplateSelector";
import { Badge } from "@/components/ui/badge";

const AVAILABLE_TAGS = [
  "nft",
  "defi",
  "beginner",
  "intermediate",
  "advanced",
  "marketplace",
  "coin",
  "collection",
  "game",
  "dao",
];

interface PlaygroundEditorProps {
  initialCode?: string;
  snippetId?: string;
  snippetTitle?: string;
  isReadOnly?: boolean;
  showFork?: boolean;
}

const DEFAULT_CODE = `module 0x0::example;

use sui::object::{UID};
use sui::tx_context::TxContext;
use sui::transfer;

/// A simple counter object
public struct Counter has key {
    id: UID,
    value: u64,
}

/// Create a new counter
public fun create(ctx: &mut TxContext) {
    let counter = Counter {
        id: object::new(ctx),
        value: 0,
    };
    transfer::share_object(counter);
}

/// Increment the counter
public fun increment(counter: &mut Counter) {
    counter.value = counter.value + 1;
}

/// Get the current value
public fun value(counter: &Counter): u64 {
    counter.value
}

#[test]
fun test_counter() {
    use sui::test_scenario;
    
    let user = @0xCAFE;
    let mut scenario = test_scenario::begin(user);
    
    // Create counter
    {
        let ctx = test_scenario::ctx(&mut scenario);
        create(ctx);
    };
    
    // Test increment
    test_scenario::next_tx(&mut scenario, user);
    {
        let mut counter = test_scenario::take_shared<Counter>(&scenario);
        increment(&mut counter);
        assert!(value(&counter) == 1, 0);
        test_scenario::return_shared(counter);
    };
    
    test_scenario::end(scenario);
}
`;

export function PlaygroundEditor({
  initialCode,
  snippetId,
  snippetTitle,
  isReadOnly = false,
  showFork = false,
}: PlaygroundEditorProps) {
  const [code, setCode] = useState(initialCode || DEFAULT_CODE);
  const [output, setOutput] = useState("");
  const [isCompiling, setIsCompiling] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [hasUnsavedChanges, setHasUnsavedChanges] = useState(false);
  const [showSaveDialog, setShowSaveDialog] = useState(false);
  const [saveForm, setSaveForm] = useState({
    title: "",
    description: "",
    tags: [] as string[],
    isPublic: true,
  });
  const [currentSnippetId, setCurrentSnippetId] = useState(snippetId);
  const { theme } = useTheme();

  useEffect(() => {
    if (initialCode) {
      setCode(initialCode);
    }
  }, [initialCode]);

  useEffect(() => {
    // Warn user about unsaved changes
    const handleBeforeUnload = (e: BeforeUnloadEvent) => {
      if (hasUnsavedChanges) {
        e.preventDefault();
        e.returnValue = "";
      }
    };

    window.addEventListener("beforeunload", handleBeforeUnload);
    return () => window.removeEventListener("beforeunload", handleBeforeUnload);
  }, [hasUnsavedChanges]);

  // Auto-save to localStorage
  useEffect(() => {
    const autoSaveKey = `playground-autosave-${currentSnippetId || "new"}`;
    const timer = setTimeout(() => {
      if (code && code !== (initialCode || DEFAULT_CODE)) {
        localStorage.setItem(autoSaveKey, JSON.stringify({
          code,
          timestamp: Date.now(),
        }));
      }
    }, 5000); // Auto-save after 5 seconds of inactivity

    return () => clearTimeout(timer);
  }, [code, currentSnippetId, initialCode]);

  // Restore from auto-save on mount
  useEffect(() => {
    const autoSaveKey = `playground-autosave-${currentSnippetId || "new"}`;
    const saved = localStorage.getItem(autoSaveKey);
    
    if (saved && !initialCode) {
      try {
        const { code: savedCode, timestamp } = JSON.parse(saved);
        const hoursSinceAutoSave = (Date.now() - timestamp) / (1000 * 60 * 60);
        
        // Only restore if less than 24 hours old
        if (hoursSinceAutoSave < 24) {
          setCode(savedCode);
          toast.info("Restored from auto-save");
        }
      } catch (e) {
        console.error("Failed to restore auto-save:", e);
      }
    }
  }, []);

  const handleCompile = async () => {
    setIsCompiling(true);
    setOutput("🔨 Compiling and running tests...\n");
    
    try {
      const response = await fetch("/api/playground/compile", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ code }),
      });
      
      const data = await response.json();
      
      if (data.success) {
        setOutput("✅ " + (data.output || "Compilation successful!"));
      } else {
        setOutput("❌ " + (data.output || data.error || "Compilation failed"));
      }
    } catch (error) {
      setOutput("❌ Failed to compile: " + (error instanceof Error ? error.message : "Unknown error"));
    } finally {
      setIsCompiling(false);
    }
  };

  const handleSave = async () => {
    // If new snippet, show dialog first
    if (!currentSnippetId) {
      setShowSaveDialog(true);
      return;
    }

    // Update existing snippet
    await performSave();
  };

  const performSave = async () => {
    setIsSaving(true);
    
    try {
      if (currentSnippetId && !isReadOnly) {
        // Update existing snippet
        const response = await fetch(`/api/playground/${currentSnippetId}`, {
          method: "PATCH",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ 
            code,
            title: snippetTitle || saveForm.title || "Untitled",
            description: saveForm.description,
          }),
        });
        
        const data = await response.json();
        
        if (data.success) {
          toast.success("Snippet updated!");
          setHasUnsavedChanges(false);
        } else {
          toast.error(data.message || "Failed to update snippet");
        }
      } else {
        // Create new snippet
        const response = await fetch("/api/playground/save", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            title: saveForm.title || "Untitled Snippet",
            description: saveForm.description,
            code,
            tags: saveForm.tags,
            is_public: saveForm.isPublic,
          }),
        });
        
        const data = await response.json();
        
        if (data.success && data.id) {
          toast.success("Snippet saved!");
          setCurrentSnippetId(data.id);
          setHasUnsavedChanges(false);
          setShowSaveDialog(false);
          // Update URL without reload
          window.history.pushState({}, "", `/playground/${data.id}`);
        } else {
          toast.error(data.message || "Failed to save snippet");
        }
      }
    } catch (error) {
      console.error("Failed to save:", error);
      toast.error("Failed to save snippet");
    } finally {
      setIsSaving(false);
    }
  };

  const handleShare = () => {
    const url = window.location.href;
    navigator.clipboard.writeText(url);
    toast.success("Link copied to clipboard!");
  };

  const handleFork = async () => {
    if (!currentSnippetId) {
      toast.error("Save the snippet first before forking");
      return;
    }

    try {
      const response = await fetch(`/api/playground/${currentSnippetId}/fork`, {
        method: "POST",
      });

      const data = await response.json();

      if (data.success && data.snippet?.id) {
        toast.success("Snippet forked!");
        // Navigate to forked snippet
        window.location.href = `/playground/${data.snippet.id}`;
      } else {
        toast.error(data.message || "Failed to fork snippet");
      }
    } catch (error) {
      console.error("Failed to fork:", error);
      toast.error("Failed to fork snippet");
    }
  };

  const handleDownload = () => {
    const blob = new Blob([code], { type: "text/plain" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = "playground.move";
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
    toast.success("Code downloaded!");
  };

  const handleLoadTemplate = (templateCode: string, templateTitle: string) => {
    setCode(templateCode);
    setHasUnsavedChanges(true);
    toast.success(`Loaded template: ${templateTitle}`);
  };

  const handleCodeChange = (value: string | undefined) => {
    setCode(value || "");
    setHasUnsavedChanges(true);
  };

  return (
    <>
      <SimpleHeader />
      <div className="h-[calc(100vh-4rem)] flex flex-col">
        {/* Toolbar */}
        <div className="border-b p-3 flex items-center justify-between bg-card">
          <div className="flex items-center gap-3">
            <div className="flex items-center gap-2">
              <FileCode className="h-5 w-5 text-muted-foreground" />
              <h2 className="font-semibold">{snippetTitle || "Untitled"}</h2>
              {hasUnsavedChanges && !isReadOnly && (
                <span className="text-xs text-muted-foreground">(unsaved)</span>
              )}
            </div>
          </div>
          
          <div className="flex items-center gap-2">
            <TemplateSelector onSelectTemplate={handleLoadTemplate} />
            
            <Button 
              onClick={handleCompile} 
              disabled={isCompiling}
              size="sm"
              className="gap-2"
            >
              {isCompiling ? (
                <Loader2 className="h-4 w-4 animate-spin" />
              ) : (
                <Play className="h-4 w-4" />
              )}
              Compile & Test
            </Button>
            
            {!isReadOnly && (
              <Button 
                variant="outline" 
                size="sm"
                onClick={handleSave}
                disabled={isSaving || !hasUnsavedChanges}
                className="gap-2"
              >
                {isSaving ? (
                  <Loader2 className="h-4 w-4 animate-spin" />
                ) : hasUnsavedChanges ? (
                  <Save className="h-4 w-4" />
                ) : (
                  <Check className="h-4 w-4" />
                )}
                {isSaving ? "Saving..." : hasUnsavedChanges ? "Save" : "Saved"}
              </Button>
            )}
            
            {showFork && currentSnippetId && (
              <Button 
                variant="outline" 
                size="sm"
                onClick={handleFork}
                className="gap-2"
              >
                <GitFork className="h-4 w-4" />
                Fork
              </Button>
            )}
            
            <Button 
              variant="outline" 
              size="sm"
              onClick={handleShare}
              disabled={!currentSnippetId}
              className="gap-2"
            >
              <Share2 className="h-4 w-4" />
              Share
            </Button>

            <Button 
              variant="outline" 
              size="sm"
              onClick={handleDownload}
              className="gap-2"
            >
              <Download className="h-4 w-4" />
            </Button>
          </div>
        </div>

        {/* Editor & Console */}
        <div className="flex-1 flex overflow-hidden">
          {/* Code Editor */}
          <div className="flex-1 border-r">
            <Editor
              height="100%"
              language="rust" // Use rust for Move syntax highlighting
              value={code}
              onChange={handleCodeChange}
              theme={theme === "dark" ? "vs-dark" : "light"}
              options={{
                minimap: { enabled: true },
                fontSize: 14,
                lineNumbers: "on",
                scrollBeyondLastLine: false,
                automaticLayout: true,
                tabSize: 4,
                wordWrap: "on",
                readOnly: isReadOnly,
              }}
            />
          </div>

          {/* Output Console */}
          <div className="w-1/3 flex flex-col bg-muted/30">
            <div className="border-b p-2 px-4 font-semibold text-sm flex items-center gap-2">
              <div className="h-2 w-2 rounded-full bg-green-500"></div>
              Output
            </div>
            <div className="flex-1 overflow-auto p-4">
              {output ? (
                <pre className="font-mono text-xs sm:text-sm whitespace-pre-wrap break-words">
                  {output}
                </pre>
              ) : (
                <div className="text-muted-foreground text-sm">
                  Click "Compile & Test" to see output here...
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Save Dialog */}
      <Dialog open={showSaveDialog} onOpenChange={setShowSaveDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Save Snippet</DialogTitle>
            <DialogDescription>
              Give your code snippet a meaningful name and description
            </DialogDescription>
          </DialogHeader>
          
          <div className="space-y-4 py-4">
            <div>
              <Label htmlFor="snippet-title">Title *</Label>
              <Input
                id="snippet-title"
                placeholder="e.g., NFT Minting Example"
                value={saveForm.title}
                onChange={(e) => setSaveForm({ ...saveForm, title: e.target.value })}
                maxLength={100}
              />
            </div>

            <div>
              <Label htmlFor="snippet-desc">Description</Label>
              <Textarea
                id="snippet-desc"
                placeholder="Briefly describe what this code does..."
                value={saveForm.description}
                onChange={(e) => setSaveForm({ ...saveForm, description: e.target.value })}
                maxLength={500}
                rows={3}
              />
              <p className="text-xs text-muted-foreground mt-1">
                {saveForm.description.length}/500 characters
              </p>
            </div>

            <div>
              <Label>Tags (optional)</Label>
              <div className="flex flex-wrap gap-2 mt-2">
                {AVAILABLE_TAGS.map((tag) => (
                  <Badge
                    key={tag}
                    variant={saveForm.tags.includes(tag) ? "default" : "outline"}
                    className="cursor-pointer"
                    onClick={() => {
                      const newTags = saveForm.tags.includes(tag)
                        ? saveForm.tags.filter((t) => t !== tag)
                        : [...saveForm.tags, tag];
                      setSaveForm({ ...saveForm, tags: newTags });
                    }}
                  >
                    {tag}
                  </Badge>
                ))}
              </div>
              <p className="text-xs text-muted-foreground mt-2">
                Select tags to help others discover your snippet
              </p>
            </div>

            <div className="flex items-center justify-between p-4 border rounded-lg">
              <div>
                <Label htmlFor="snippet-public" className="text-base">Public Snippet</Label>
                <p className="text-sm text-muted-foreground">
                  {saveForm.isPublic 
                    ? "Anyone can view and fork this snippet" 
                    : "Only you can see this snippet"}
                </p>
              </div>
              <Switch
                id="snippet-public"
                checked={saveForm.isPublic}
                onCheckedChange={(checked) => setSaveForm({ ...saveForm, isPublic: checked })}
              />
            </div>
          </div>

          <DialogFooter>
            <Button variant="outline" onClick={() => setShowSaveDialog(false)}>
              Cancel
            </Button>
            <Button 
              onClick={performSave}
              disabled={!saveForm.title.trim() || isSaving}
            >
              {isSaving ? (
                <>
                  <Loader2 className="h-4 w-4 animate-spin mr-2" />
                  Saving...
                </>
              ) : (
                <>
                  <Save className="h-4 w-4 mr-2" />
                  Save Snippet
                </>
              )}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </>
  );
}
