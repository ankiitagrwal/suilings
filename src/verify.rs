use crate::{
    clear_screen,
    exercise::{Exercise, Mode, State},
    utils,
};
use console::style;
use indicatif::{ProgressBar, ProgressStyle};
use std::env;

pub fn verify<'a>(
    exercises: impl IntoIterator<Item = &'a Exercise>,
    progress: (usize, usize),
) -> Result<(), &'a Exercise> {
    let (mut num_done, total) = progress;
    for exercise in exercises {
        clear_screen();
        let bar = ProgressBar::new(total as u64);

        // Safe: template is static and valid
        let style = ProgressStyle::default_bar()
            .template("Progress: [{bar:60.green/red}] {pos}/{len} {msg}\n")
            .expect("Hardcoded template should be valid")
            .progress_chars("#>-");

        bar.set_style(style);
        bar.set_position(num_done as u64);

        let exercise_result = match exercise.mode {
            Mode::Build => match utils::build_exercise(exercise) {
                Ok(output) => Ok(prompt_for_completion(exercise, Some(output))),
                Err(_) => Err(()),
            },
            Mode::Test => {
                match utils::test_exercise(exercise) {
                    Ok(output) => Ok(prompt_for_completion(exercise, Some(output))),
                    Err(_) => {
                        utils::print_warning(&format!("Tests failed for {}!", exercise));
                        Err(())
                    }
                }
            }
        };

        if !exercise_result.unwrap_or(false) {
            return Err(exercise);
        }

        let percentage = num_done as f32 / total as f32 * 100.0;
        bar.set_message(format!("({percentage:.1} %)"));
        num_done += 1;
    }
    Ok(())
}

fn prompt_for_completion(exercise: &Exercise, prompt_output: Option<String>) -> bool {
    let context = match exercise.state() {
        State::Done => return true,
        State::Pending(context) => context,
    };

    if let Some(output) = prompt_output {
        utils::print_exercise_output(output);
    }

    utils::print_exercise_success(exercise);
    let no_emoji = env::var("NO_EMOJI").is_ok();

    let success_msg = match exercise.mode {
        Mode::Build => "The code builds successfully!",
        Mode::Test => "The code builds and all tests pass!",
    };

    if no_emoji {
        println!("~*~ {success_msg} ~*~")
    } else {
        println!("(party popper) (party popper)  {success_msg} (party popper) (party popper)")
    }
    println!();

    println!("You can keep working on this exercise,");
    println!(
        "or jump into the next one by removing the {} comment:",
        style("`I AM NOT DONE`").bold()
    );
    println!();

    for context_line in context {
        let formatted_line = if context_line.important {
            format!("{}", style(context_line.line).bold())
        } else {
            context_line.line.to_string()
        };

        println!(
            "{:>2} {}  {}",
            style(context_line.number).blue().bold(),
            style("|").blue(),
            formatted_line
        );
    }

    false
}