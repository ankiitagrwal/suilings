use crate::exercise::{Exercise, Mode};
use console::style;
use std::path::PathBuf;
use std::fs;
use std::process::Command;

#[macro_export]
macro_rules! warn {
    ($fmt:expr, $($arg:tt)*) => {{
        use console::{style, Emoji};
        use std::env;
        let formatstr = format!($fmt, $($arg)*);
        println!();
        if env::var("NO_EMOJI").is_ok() {
            println!("{} {}", style("!").red(), style(formatstr).red());
        } else {
            println!(
                "{} {}",
                style(Emoji("⚠️ ", "!")).red(),
                style(formatstr).red()
            );
        }
        println!();
    }};
}

#[macro_export]
macro_rules! success {
    ($fmt:expr, $($arg:tt)*) => {{
        use console::{style, Emoji};
        use std::env;
        let formatstr = format!($fmt, $($arg)*);
        println!();
        if env::var("NO_EMOJI").is_ok() {
            println!("{} {}", style("✓").green(), style(formatstr).green());
        } else {
            println!(
                "{} {}",
                style(Emoji("✅", "✓")).green(),
                style(formatstr).green()
            );
        }
        println!();
    }};
}

#[macro_export]
macro_rules! progress {
    ($fmt:expr, $($arg:tt)*) => {{
        use console::{style, Emoji};
        use std::env;
        let formatstr = format!($fmt, $($arg)*);
        println!();
        if env::var("NO_EMOJI").is_ok() {
            println!("{} {}", style("○").yellow(), style(formatstr).yellow());
        } else {
            println!(
                "{} {}",
                style(Emoji("🟡", "○")).yellow(),
                style(formatstr).yellow()
            );
        }
        println!();
    }};
}

// Prepares the runner crate by copying the exercise's Move file to runner-crate/sources/main.move
pub fn prepare_crate_for_exercise(exercise: &Exercise) -> PathBuf {
    let crate_path = std::env::current_dir().unwrap().join("runner-crate");
    let src_dir = crate_path.join("sources");
    if !src_dir.exists() {
        fs::create_dir_all(&src_dir).expect("Failed to create runner-crate/sources directory");
    }
    let dest_path = src_dir.join("main.move");

    fs::copy(&exercise.path, &dest_path)
        .unwrap_or_else(|e| panic!("Failed to copy {} to {}: {}", exercise.path.display(), dest_path.display(), e));

    crate_path
}

pub fn build_exercise(exercise: &Exercise) -> Result<String, ()> {
    progress!("Building {} exercise...", exercise);

    let crate_path = prepare_crate_for_exercise(exercise);
    let output = Command::new("sui")
        .args(&[
            "move",
            "build",
            "--path",
            crate_path.to_str().unwrap(),
        ])
        .output()
        .map_err(|e| {
            eprintln!("Failed to run `sui move build`: {}", e);
            ()
        })?;

    if output.status.success() {
        let stdout = String::from_utf8_lossy(&output.stdout).to_string();
        // Filter out [note] messages - they're informational, not errors
        let filtered_output = filter_note_messages(&stdout);
        Ok(filtered_output)
    } else {
        let err = String::from_utf8_lossy(&output.stderr);
        // Filter out [note] messages before displaying errors
        let filtered_err = filter_note_messages(&err);
        
        // Only show error if there's actual content after filtering
        if !filtered_err.trim().is_empty() {
            eprintln!("\n=== BUILD ERROR ===\n{filtered_err}\n");
        }
        warn!("Build failed for {}! Fix the errors above.", exercise);
        Err(())
    }
}

// Helper function to filter out [note] messages
fn filter_note_messages(text: &str) -> String {
    text.lines()
        .filter(|line| !line.trim().starts_with("[note]"))
        .collect::<Vec<_>>()
        .join("\n")
        .trim()
        .to_string()
}

pub fn test_exercise(exercise: &Exercise) -> Result<String, ()> {
    progress!("Testing {} exercise...", exercise);

    let crate_path = prepare_crate_for_exercise(exercise);
    let output = Command::new("sui")
        .args(&[
            "move",
            "test",
            "--path",
            crate_path.to_str().unwrap(),
        ])
        .output()
        .map_err(|e| {
            eprintln!("Failed to run `sui move test`: {}", e);
            ()
        })?;

    if output.status.success() {
        let stdout = String::from_utf8_lossy(&output.stdout).to_string();
        // Filter out [note] messages - they're informational, not errors
        let filtered_output = filter_note_messages(&stdout);
        Ok(filtered_output)
    } else {
        // Test output can be in both stdout and stderr
        let stdout = String::from_utf8_lossy(&output.stdout).to_string();
        let stderr = String::from_utf8_lossy(&output.stderr).to_string();
        
        // Combine and filter out [note] messages
        let combined = if !stdout.is_empty() && !stderr.is_empty() {
            format!("{}\n{}", stdout, stderr)
        } else if !stdout.is_empty() {
            stdout
        } else {
            stderr
        };
        
        let filtered_output = filter_note_messages(&combined);
        
        // Display error output if there's content after filtering
        if !filtered_output.trim().is_empty() {
            eprintln!("\n=== TEST FAILED ===\n{filtered_output}\n");
        }
        warn!("Tests failed for {}! Check the output above.", exercise);
        Err(())
    }
}

pub fn print_exercise_output(output: String) {
    if !output.is_empty() {
        println!("    {} {output}", style("Output").green().bold());
    }
}

pub fn print_exercise_success(exercise: &Exercise) {
    match exercise.mode {
        Mode::Build => success!("Successfully built {}!", exercise),
        Mode::Test => success!("Successfully tested {}!", exercise),
    }
}

// Clears the terminal with an ANSI escape code
pub fn clear_screen() {
    println!("\x1Bc");
}

// Print a warning message using the warn macro
pub fn print_warning(message: &str) {
    warn!("{}", message);
}

