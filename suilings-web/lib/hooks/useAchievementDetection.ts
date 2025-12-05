"use client";

import { useState, useEffect, useCallback, useRef } from 'react';
import { checkNewAchievement, getEligibleAchievements, Achievement } from '../achievements';

interface UseAchievementDetectionProps {
  completedCount: number;
  streakDays: number;
  rank: number | null;
}

export function useAchievementDetection({
  completedCount,
  streakDays,
  rank,
}: UseAchievementDetectionProps) {
  const [unlockedAchievements, setUnlockedAchievements] = useState<string[]>(() => {
    if (typeof window !== 'undefined') {
      const stored = localStorage.getItem('suilings_unlocked_achievements');
      if (stored) {
        try {
          return JSON.parse(stored);
        } catch {
          return [];
        }
      }
    }
    return [];
  });
  
  const [currentAchievement, setCurrentAchievement] = useState<Achievement | null>(null);
  const previousCountRef = useRef(completedCount);
  const hasCheckedInitial = useRef(false);

  useEffect(() => {
    if (completedCount === 0 || hasCheckedInitial.current) return;
    
    if (unlockedAchievements.length === 0 && completedCount > 0) {
      const eligible = getEligibleAchievements(
        completedCount,
        streakDays,
        rank,
        []
      );
      
      if (eligible.length > 0) {
        const highestAchievement = eligible[eligible.length - 1];
        
        const allIds = eligible.map(a => a.id);
        setUnlockedAchievements(allIds);
        localStorage.setItem('suilings_unlocked_achievements', JSON.stringify(allIds));
        
        setTimeout(() => setCurrentAchievement(highestAchievement), 500);
      }
    }
    
    hasCheckedInitial.current = true;
  }, [completedCount, streakDays, rank, unlockedAchievements.length]);

  useEffect(() => {
    if (!hasCheckedInitial.current) return;
    if (completedCount === 0) return;

    if (completedCount > previousCountRef.current) {
      const newAchievement = checkNewAchievement(
        completedCount,
        streakDays,
        rank,
        unlockedAchievements
      );

      if (newAchievement) {
        const updated = [...unlockedAchievements, newAchievement.id];
        setUnlockedAchievements(updated);
        localStorage.setItem('suilings_unlocked_achievements', JSON.stringify(updated));
        setTimeout(() => setCurrentAchievement(newAchievement), 300);
      }
    }
    
    previousCountRef.current = completedCount;
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [completedCount, streakDays, rank]);

  const closeAchievement = useCallback(() => {
    setCurrentAchievement(null);
  }, []);

  return {
    currentAchievement,
    unlockedAchievements,
    closeAchievement,
  };
}

