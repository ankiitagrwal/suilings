import { useEffect, useState } from 'react';
import { useExerciseStore } from '@/lib/store/exerciseStore';
import { loadExercises } from '@/lib/exerciseLoader';

interface UseExerciseInitOptions {
  autoSelectFirst?: boolean;
  onComplete?: () => void;
}

/**
 * Shared hook for initializing exercises across pages
 * Handles loading exercises and fetching user progress
 */
export function useExerciseInit(options: UseExerciseInitOptions = {}) {
  const { autoSelectFirst = false, onComplete } = options;
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  
  const { 
    exercises, 
    setExercises, 
    setCurrentExercise, 
    currentExerciseIndex,
    fetchProgress 
  } = useExerciseStore();

  useEffect(() => {
    let mounted = true;
    
    const init = async () => {
      if (!mounted) return;
      
      try {
        setIsLoading(true);
        setError(null);
        
        // Load exercises if not already loaded
        if (exercises.length === 0) {
          const loadedExercises = await loadExercises();
          if (!mounted) return;
          
          setExercises(loadedExercises);
          
          // Auto-select first exercise if requested and none selected
          if (autoSelectFirst && loadedExercises.length > 0 && currentExerciseIndex === -1) {
            setCurrentExercise(0);
          }
        }
        
        // Fetch user progress to update exercise statuses
        await fetchProgress();
        
        if (mounted) {
          setIsLoading(false);
          onComplete?.();
        }
      } catch (err) {
        if (mounted) {
          console.error('Failed to initialize exercises:', err);
          setError(err instanceof Error ? err.message : 'Failed to load exercises');
          setIsLoading(false);
        }
      }
    };
    
    init();
    
    return () => {
      mounted = false;
    };
  }, []); // Run once on mount

  return { isLoading, error, exercises };
}

