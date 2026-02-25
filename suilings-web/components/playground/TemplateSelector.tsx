"use client";

import { useState } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Card } from "@/components/ui/card";
import { FileCode, Check } from "lucide-react";
import { PLAYGROUND_TEMPLATES, TEMPLATE_CATEGORIES, PlaygroundTemplate } from "@/lib/playground-templates";

interface TemplateSelectorProps {
  onSelectTemplate: (code: string, title: string) => void;
}

export function TemplateSelector({ onSelectTemplate }: TemplateSelectorProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [selectedCategory, setSelectedCategory] = useState("All");

  const filteredTemplates = selectedCategory === "All" 
    ? PLAYGROUND_TEMPLATES 
    : PLAYGROUND_TEMPLATES.filter(t => t.category === selectedCategory);

  const getDifficultyColor = (difficulty: PlaygroundTemplate['difficulty']) => {
    switch (difficulty) {
      case 'beginner':
        return 'bg-green-500/10 text-green-500 border-green-500/20';
      case 'intermediate':
        return 'bg-yellow-500/10 text-yellow-500 border-yellow-500/20';
      case 'advanced':
        return 'bg-red-500/10 text-red-500 border-red-500/20';
    }
  };

  const handleSelectTemplate = (template: PlaygroundTemplate) => {
    onSelectTemplate(template.code, template.title);
    setIsOpen(false);
  };

  return (
    <Dialog open={isOpen} onOpenChange={setIsOpen}>
      <DialogTrigger asChild>
        <Button variant="outline" size="sm" className="gap-2">
          <FileCode className="h-4 w-4" />
          Templates
        </Button>
      </DialogTrigger>
      <DialogContent className="max-w-4xl max-h-[80vh] overflow-hidden flex flex-col">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <FileCode className="h-5 w-5" />
            Choose a Template
          </DialogTitle>
        </DialogHeader>

        {/* Category Filter */}
        <div className="flex gap-2 flex-wrap pb-4 border-b">
          {TEMPLATE_CATEGORIES.map((category) => (
            <Button
              key={category}
              variant={selectedCategory === category ? "default" : "outline"}
              size="sm"
              onClick={() => setSelectedCategory(category)}
            >
              {category}
            </Button>
          ))}
        </div>

        {/* Templates Grid */}
        <div className="flex-1 overflow-y-auto pr-2">
          <div className="grid gap-3">
            {filteredTemplates.map((template) => (
              <Card
                key={template.id}
                className="p-4 cursor-pointer hover:border-primary transition-all"
                onClick={() => handleSelectTemplate(template)}
              >
                <div className="flex items-start justify-between gap-4">
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-2">
                      <h3 className="font-semibold text-base">{template.title}</h3>
                      <Badge 
                        variant="outline" 
                        className={getDifficultyColor(template.difficulty)}
                      >
                        {template.difficulty}
                      </Badge>
                    </div>
                    <p className="text-sm text-muted-foreground mb-2">
                      {template.description}
                    </p>
                    <div className="flex gap-2">
                      <Badge variant="secondary" className="text-xs">
                        {template.category}
                      </Badge>
                      {template.tags.slice(0, 2).map(tag => (
                        <Badge key={tag} variant="outline" className="text-xs">
                          {tag}
                        </Badge>
                      ))}
                    </div>
                  </div>
                  <Check className="h-5 w-5 text-muted-foreground opacity-0 group-hover:opacity-100" />
                </div>
              </Card>
            ))}
          </div>
        </div>

        <div className="pt-4 border-t text-sm text-muted-foreground">
          Showing {filteredTemplates.length} template{filteredTemplates.length === 1 ? '' : 's'}
        </div>
      </DialogContent>
    </Dialog>
  );
}
