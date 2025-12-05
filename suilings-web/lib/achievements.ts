
export interface Achievement {
  id: string;
  threshold: number;
  title: string;
  description: string;
  badge: string;
  shareText: string;
  color: string;
  type: 'progress' | 'streak' | 'rank' | 'category';
}

export const ACHIEVEMENT_MILESTONES: Record<string, Achievement> = {
  FIRST_EXERCISE: {
    id: 'first_exercise',
    threshold: 1,
    title: '🎉 First Step Complete!',
    description: 'You completed your first Move exercise',
    badge: '🌱',
    shareText: '🎉 Just completed my first #Move exercise on @Suiilings!\n\nLearning to build on @SuiNetwork 🚀\n\nsuilings.xyz',
    color: 'green',
    type: 'progress'
  },
  
  BEGINNER_COMPLETE: {
    id: 'beginner_5',
    threshold: 5,
    title: '💪 Getting Started!',
    description: 'Completed 5 exercises - You\'re on fire!',
    badge: '💪',
    shareText: '💪 Just hit 5 exercises on @Suiilings!\n\nLearning #Move development on @SuiNetwork\n\nProgress: 5/57 ✅\n\nsuilings.xyz',
    color: 'blue',
    type: 'progress'
  },
  
  INTERMEDIATE: {
    id: 'intermediate_10',
    threshold: 10,
    title: '🚀 Double Digits!',
    description: '10 exercises completed - You\'re crushing it!',
    badge: '🚀',
    shareText: '🚀 Reached 10 exercises on @Suiilings!\n\nDiving deep into #Move programming\n\nProgress: 10/57 🔥\n\nsuilings.xyz',
    color: 'purple',
    type: 'progress'
  },
  
  ADVANCED_READY: {
    id: 'advanced_20',
    threshold: 20,
    title: '🔓 Advanced Ready!',
    description: 'You\'re ready for advanced challenges!',
    badge: '🔓',
    shareText: '🔓 Unlocked Advanced section on @Suiilings!\n\n20 exercises complete 💪\n\nLearning Transaction Context, Module Initializers & Capability Patterns\n\n#Move #Sui\n\nsuilings.xyz',
    color: 'gold',
    type: 'progress'
  },
  
  HALFWAY: {
    id: 'halfway_30',
    threshold: 30,
    title: '⚡ Halfway There!',
    description: 'More than halfway to mastery!',
    badge: '⚡',
    shareText: '⚡ Halfway through @Suiilings!\n\n30/57 exercises complete\n\nBecoming a #Move developer on @SuiNetwork 🎯\n\nsuilings.xyz',
    color: 'orange',
    type: 'progress'
  },
  
  ALMOST_THERE: {
    id: 'almost_50',
    threshold: 50,
    title: '🔥 Almost There!',
    description: 'Just 7 more to go!',
    badge: '🔥',
    shareText: '🔥 50/57 exercises complete on @Suiilings!\n\nSo close to mastering #Move development!\n\nBuilding on @SuiNetwork 🚀\n\nsuilings.xyz',
    color: 'red',
    type: 'progress'
  },
  
  MASTER: {
    id: 'master_all',
    threshold: 57,
    title: '🎓 Move Master!',
    description: 'All exercises complete - You\'re a Move developer!',
    badge: '🎓',
    shareText: '🎓 COMPLETED all 57 exercises on @Suiilings!\n\nOfficially a #Move developer ready to build on @SuiNetwork 🚀\n\nWhat project should I build first? 👀\n\nsuilings.xyz',
    color: 'rainbow',
    type: 'progress'
  },
  
  STREAK_7: {
    id: 'streak_7',
    threshold: 7,
    title: '🔥 Week Streak!',
    description: '7 days of consistent learning!',
    badge: '🔥',
    shareText: '🔥 7-day learning streak on @Suiilings!\n\nConsistency is key 💪\n\nLearning #Move on @SuiNetwork daily\n\nsuilings.xyz',
    color: 'orange',
    type: 'streak'
  },
  
  STREAK_30: {
    id: 'streak_30',
    threshold: 30,
    title: '🔥🔥 Month Streak!',
    description: '30 days! You\'re dedicated!',
    badge: '🔥🔥',
    shareText: '🔥 30-DAY STREAK on @Suiilings!\n\nCommitted to becoming a #Move developer\n\nConsistency > Intensity 💪\n\n#Sui #Web3\n\nsuilings.xyz',
    color: 'red',
    type: 'streak'
  },
  
  TOP_10: {
    id: 'top_10',
    threshold: 10,
    title: '🏆 Top 10!',
    description: 'You made it to the top 10!',
    badge: '🏆',
    shareText: '🏆 Entered TOP 10 on @Suiilings leaderboard!\n\nCompeting with the best #Move developers\n\n#Sui #Web3\n\nsuilings.xyz',
    color: 'gold',
    type: 'rank'
  },
  
  TOP_3: {
    id: 'top_3',
    threshold: 3,
    title: '🥇 Top 3!',
    description: 'Elite developer status!',
    badge: '🥇',
    shareText: '🥇 Reached TOP 3 on @Suiilings leaderboard!\n\nOne of the elite #Move developers 🚀\n\n#Sui #Web3\n\nsuilings.xyz',
    color: 'rainbow',
    type: 'rank'
  }
};

export function getNextAchievement(completedCount: number): Achievement | null {
  const progressThresholds = [1, 5, 10, 20, 30, 50, 57];
  const nextThreshold = progressThresholds.find(t => t > completedCount);
  
  if (!nextThreshold) return null;
  
  return Object.values(ACHIEVEMENT_MILESTONES).find(
    a => a.threshold === nextThreshold && a.type === 'progress'
  ) || null;
}

export function checkNewAchievement(
  completedCount: number,
  streakDays: number,
  rank: number | null,
  unlockedAchievements: string[]
): Achievement | null {

  const progressMilestones = [1, 5, 10, 20, 30, 50, 57];
  for (const threshold of progressMilestones) {
    if (completedCount === threshold) {
      const achievement = Object.values(ACHIEVEMENT_MILESTONES).find(
        a => a.threshold === threshold && a.type === 'progress'
      );
      
      if (achievement && !unlockedAchievements.includes(achievement.id)) {
        return achievement;
      }
    }
  }
  

  const streakMilestones = [7, 30];
  for (const threshold of streakMilestones) {
    if (streakDays === threshold) {
      const achievement = Object.values(ACHIEVEMENT_MILESTONES).find(
        a => a.threshold === threshold && a.type === 'streak'
      );
      
      if (achievement && !unlockedAchievements.includes(achievement.id)) {
        return achievement;
      }
    }
  }
  
  if (rank !== null && rank > 0) {
    if (rank <= 3) {
      const achievement = ACHIEVEMENT_MILESTONES.TOP_3;
      if (!unlockedAchievements.includes(achievement.id)) {
        return achievement;
      }
    } else if (rank <= 10) {
      const achievement = ACHIEVEMENT_MILESTONES.TOP_10;
      if (!unlockedAchievements.includes(achievement.id)) {
        return achievement;
      }
    }
  }
  
  return null;
}

export function getEligibleAchievements(
  completedCount: number,
  streakDays: number,
  rank: number | null,
  unlockedAchievements: string[]
): Achievement[] {
  const eligible: Achievement[] = [];
  
  const progressMilestones = [1, 5, 10, 20, 30, 50, 57];
  for (const threshold of progressMilestones) {
    if (completedCount >= threshold) {
      const achievement = Object.values(ACHIEVEMENT_MILESTONES).find(
        a => a.threshold === threshold && a.type === 'progress'
      );
      
      if (achievement && !unlockedAchievements.includes(achievement.id)) {
        eligible.push(achievement);
      }
    }
  }
  
  const streakMilestones = [7, 30];
  for (const threshold of streakMilestones) {
    if (streakDays >= threshold) {
      const achievement = Object.values(ACHIEVEMENT_MILESTONES).find(
        a => a.threshold === threshold && a.type === 'streak'
      );
      
      if (achievement && !unlockedAchievements.includes(achievement.id)) {
        eligible.push(achievement);
      }
    }
  }
  
  if (rank !== null && rank > 0) {
    if (rank <= 3) {
      const achievement = ACHIEVEMENT_MILESTONES.TOP_3;
      if (!unlockedAchievements.includes(achievement.id)) {
        eligible.push(achievement);
      }
    } else if (rank <= 10) {
      const achievement = ACHIEVEMENT_MILESTONES.TOP_10;
      if (!unlockedAchievements.includes(achievement.id)) {
        eligible.push(achievement);
      }
    }
  }
  
  return eligible.sort((a, b) => a.threshold - b.threshold);
}

