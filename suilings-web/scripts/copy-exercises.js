#!/usr/bin/env node

/**
 * Copy exercises and info.toml into the Next.js app at build time
 * This allows the app to work on Vercel (where parent directory access is not allowed)
 */

const fs = require('fs');
const path = require('path');

// Paths
const PARENT_DIR = path.join(__dirname, '..', '..');
const PUBLIC_DIR = path.join(__dirname, '..', 'public');
const EXERCISES_SRC = path.join(PARENT_DIR, 'exercises');
const INFO_TOML_SRC = path.join(PARENT_DIR, 'info.toml');
const EXERCISES_DEST = path.join(PUBLIC_DIR, 'exercises');
const INFO_TOML_DEST = path.join(PUBLIC_DIR, 'info.toml');

// Helper: Copy directory recursively
function copyDirSync(src, dest) {
  // Create destination directory
  if (!fs.existsSync(dest)) {
    fs.mkdirSync(dest, { recursive: true });
  }

  // Read source directory
  const entries = fs.readdirSync(src, { withFileTypes: true });

  for (const entry of entries) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);

    if (entry.isDirectory()) {
      copyDirSync(srcPath, destPath);
    } else {
      fs.copyFileSync(srcPath, destPath);
    }
  }
}

// Main copy function
function copyExercises() {
  console.log('📦 Copying exercises for production build...\n');

  try {
    // Check if source files exist
    if (!fs.existsSync(EXERCISES_SRC)) {
      console.log('ℹ️  Parent directory not found (likely on Vercel)');
      console.log('   Using pre-bundled exercises from public/ folder');
      console.log('   ✅ Skipping copy (already bundled)\n');
      return; // Skip copy on Vercel
    }

    if (!fs.existsSync(INFO_TOML_SRC)) {
      console.log('ℹ️  info.toml not found in parent directory');
      console.log('   Using pre-bundled file from public/ folder');
      console.log('   ✅ Skipping copy (already bundled)\n');
      return; // Skip copy on Vercel
    }

    // Create public directory if it doesn't exist
    if (!fs.existsSync(PUBLIC_DIR)) {
      fs.mkdirSync(PUBLIC_DIR, { recursive: true });
    }

    // Copy exercises directory
    console.log('📁 Copying exercises directory...');
    if (fs.existsSync(EXERCISES_DEST)) {
      fs.rmSync(EXERCISES_DEST, { recursive: true, force: true });
    }
    copyDirSync(EXERCISES_SRC, EXERCISES_DEST);
    console.log('   ✅ Copied to', path.relative(process.cwd(), EXERCISES_DEST));

    // Copy info.toml
    console.log('📄 Copying info.toml...');
    fs.copyFileSync(INFO_TOML_SRC, INFO_TOML_DEST);
    console.log('   ✅ Copied to', path.relative(process.cwd(), INFO_TOML_DEST));

    console.log('\n✨ All files copied successfully!\n');
  } catch (error) {
    console.error('❌ Error copying files:', error.message);
    process.exit(1);
  }
}

// Run if called directly
if (require.main === module) {
  copyExercises();
}

module.exports = copyExercises;

