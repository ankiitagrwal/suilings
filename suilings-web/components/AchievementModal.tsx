"use client";

import { useState, useEffect, useMemo } from 'react';
import { Dialog, DialogContent, DialogTitle, DialogDescription } from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { X as XIcon } from 'lucide-react';
import { Achievement } from '@/lib/achievements';

interface AchievementModalProps {
  achievement: Achievement | null;
  onClose: () => void;
}

export function AchievementModal({ achievement, onClose }: AchievementModalProps) {
  const [showConfetti, setShowConfetti] = useState(false);

  useEffect(() => {
    if (achievement) {
      setShowConfetti(true);
      const confettiTimer = setTimeout(() => setShowConfetti(false), 3000);
      
      return () => {
        clearTimeout(confettiTimer);
      };
    }
  }, [achievement]);

  if (!achievement) return null;

  const handleShareToX = () => {
    const url = `https://twitter.com/intent/tweet?text=${encodeURIComponent(achievement.shareText)}`;
    window.open(url, '_blank', 'width=550,height=420');
  };

  return (
    <>
      {showConfetti && <Confetti />}
      
      <Dialog open={!!achievement} onOpenChange={(open) => !open && onClose()}>
        <DialogContent className="sm:max-w-md border-0 bg-transparent shadow-none p-0">
          <DialogTitle className="sr-only">Achievement Unlocked</DialogTitle>
          <DialogDescription className="sr-only">
            You've earned a new achievement: {achievement.title}
          </DialogDescription>
          
          <div className="relative bg-background border-2 border-primary/20 rounded-2xl p-8 text-center shadow-2xl">
            <div className="absolute top-0 left-0 right-0 h-1 bg-linear-to-r from-primary/20 via-primary to-primary/20 rounded-t-2xl" />
            
            <div className="mb-4">
              <div className="inline-block p-4 bg-primary/10 rounded-full">
                <span className="text-6xl">{achievement.badge}</span>
              </div>
            </div>

            <h2 className="mb-2 text-2xl font-bold text-foreground">
              Achievement Unlocked!
            </h2>
            
            <h3 className="mb-1 text-xl font-semibold text-primary">
              {achievement.title}
            </h3>

            <p className="mb-6 text-sm text-muted-foreground">
              {achievement.description}
            </p>

            <Button
              onClick={handleShareToX}
              size="lg"
              className="w-full bg-black hover:bg-gray-800 text-white gap-2 font-semibold"
            >
              <XIcon className="h-5 w-5" />
              Share on X
            </Button>

            <p className="mt-4 text-xs text-muted-foreground">
              Keep learning to unlock more achievements 🚀
            </p>
          </div>
        </DialogContent>
      </Dialog>
    </>
  );
}

function Confetti() {
  const colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A', '#98D8C8', '#F7DC6F', '#BB8FCE', '#85C1E2'];
  
  const confettiItems = useMemo(() => 
    Array.from({ length: 50 }, (_, i) => ({
      id: i,
      left: Math.random() * 100,
      delay: Math.random() * 3,
      duration: 3 + Math.random() * 2,
      color: colors[Math.floor(Math.random() * colors.length)]
    })),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    []
  );
  
  return (
    <div className="fixed inset-0 pointer-events-none z-50">
      {confettiItems.map((item) => (
        <div
          key={item.id}
          className="absolute animate-confetti"
          style={{
            left: `${item.left}%`,
            top: '-10%',
            animationDelay: `${item.delay}s`,
            animationDuration: `${item.duration}s`,
          }}
        >
          <div
            className="w-2 h-2 rounded-full"
            style={{ backgroundColor: item.color }}
          />
        </div>
      ))}
    </div>
  );
}
