#!/usr/bin/env node

/**
 * Copy exercises and info.toml into the Next.js app at build time
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
  if (!fs.existsSync(dest)) {
    fs.mkdirSync(dest, { recursive: true });
  }

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
  console.log('📦 Copying exercises for build...\n');

  try {
    // Check if source files exist
    if (!fs.existsSync(EXERCISES_SRC)) {
      console.log('⚠️  Parent exercises/ not found - using existing public/exercises/');
      return;
    }

    if (!fs.existsSync(INFO_TOML_SRC)) {
      console.log('⚠️  Parent info.toml not found - using existing public/info.toml');
      return;
    }

    // Copy exercises directory
    console.log('📁 Copying exercises directory...');
    if (fs.existsSync(EXERCISES_DEST)) {
      fs.rmSync(EXERCISES_DEST, { recursive: true, force: true });
    }
    copyDirSync(EXERCISES_SRC, EXERCISES_DEST);
    console.log('   ✅ Copied exercises');

    // Copy info.toml
    console.log('📄 Copying info.toml...');
    fs.copyFileSync(INFO_TOML_SRC, INFO_TOML_DEST);
    console.log('   ✅ Copied info.toml');

    console.log('\n✨ All files copied successfully!\n');
  } catch (error) {
    console.error('❌ Error copying files:', error.message);
    // Don't exit with error - use existing files
    console.log('⚠️  Using existing files in public/ folder\n');
  }
}

// Run
copyExercises();

