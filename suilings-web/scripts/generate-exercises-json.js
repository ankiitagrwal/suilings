#!/usr/bin/env node

/**
 * Generate exercises.json at build time  
 * Bundles exercises into JSON for Next.js API routes to import
 */

const fs = require('fs');
const path = require('path');
const toml = require('@iarna/toml');

// Paths
const PARENT_DIR = path.join(__dirname, '..', '..');
const PUBLIC_DIR = path.join(__dirname, '..', 'public');
// Place in lib/ so API routes can import it
const EXERCISES_JSON = path.join(__dirname, '..', 'lib', 'exercises-data.json');

function generateExercisesJson() {
  console.log('📦 Generating exercises JSON...\n');

  try {
    // Try parent directory first (local dev)
    let exercisesRoot = PARENT_DIR;
    let infoTomlPath = path.join(PARENT_DIR, 'info.toml');
    
    if (!fs.existsSync(infoTomlPath)) {
      // Fall back to public folder
      exercisesRoot = PUBLIC_DIR;
      infoTomlPath = path.join(PUBLIC_DIR, 'info.toml');
    }

    if (!fs.existsSync(infoTomlPath)) {
      console.error('❌ info.toml not found in parent or public directory');
      process.exit(1);
    }

    console.log('📄 Reading info.toml from:', infoTomlPath);
    const tomlContent = fs.readFileSync(infoTomlPath, 'utf-8');
    const parsed = toml.parse(tomlContent);

    if (!parsed.exercises || !Array.isArray(parsed.exercises)) {
      console.error('❌ No exercises found in info.toml');
      process.exit(1);
    }

    // Load each exercise
    const exercises = parsed.exercises.map((ex) => {
      const exercisePath = path.join(exercisesRoot, ex.path);
      
      console.log(`   Loading ${ex.name}...`);
      
      if (!fs.existsSync(exercisePath)) {
        console.error(`   ❌ File not found: ${exercisePath}`);
        return null;
      }
      
      const code = fs.readFileSync(exercisePath, 'utf-8');
      
      // Extract description from comments
      const lines = code.split('\n');
      const commentLines = [];
      const cleanCodeLines = [];
      let inDescriptionBlock = true;
      
      for (const line of lines) {
        const trimmed = line.trim();
        
        // Skip "I AM NOT DONE" line
        if (trimmed.includes('I AM NOT DONE') || trimmed === '// I AM NOT DONE') {
          continue;
        }
        
        // Collect description from top comments
        if (inDescriptionBlock && trimmed.startsWith('//')) {
          commentLines.push(line.replace(/^\/\/\s*/, ''));
        } else if (trimmed && !trimmed.startsWith('//')) {
          inDescriptionBlock = false;
          cleanCodeLines.push(line);
        } else if (!inDescriptionBlock) {
          if (trimmed !== '//' || cleanCodeLines.length > 0) {
            cleanCodeLines.push(line);
          }
        }
      }
      
      const description = commentLines.join('\n').trim();
      const cleanCode = cleanCodeLines.join('\n').trim();

      return {
        name: ex.name,
        path: ex.path,
        mode: ex.mode,
        hint: ex.hint,
        description: description || `Exercise: ${ex.name}`,
        initialCode: cleanCode,
        status: 'pending',
      };
    }).filter(ex => ex !== null); // Remove failed exercises

    // Ensure lib directory exists
    const libDir = path.dirname(EXERCISES_JSON);
    if (!fs.existsSync(libDir)) {
      fs.mkdirSync(libDir, { recursive: true });
    }

    // Write to JSON file
    fs.writeFileSync(EXERCISES_JSON, JSON.stringify({ exercises }, null, 2));
    console.log(`\n✅ Generated exercises JSON with ${exercises.length} exercises`);
    console.log(`   Saved to: ${path.relative(process.cwd(), EXERCISES_JSON)}\n`);
  } catch (error) {
    console.error('❌ Error generating exercises JSON:', error.message);
    console.error(error.stack);
    process.exit(1);
  }
}

generateExercisesJson();

