use std::env;

use anyhow::{Ok, Result};
use log::LevelFilter;
use log4rs::{
  append::{
    console::ConsoleAppender,
    rolling_file::{
      policy::compound::{roll::fixed_window::FixedWindowRoller, trigger::size::SizeTrigger, CompoundPolicy},
      RollingFileAppender,
    },
  },
  config::{Appender, Root},
  encode::pattern::PatternEncoder,
  Config,
};

// d - Date and time
// l - Log level
// M - Module path
// L - Line number
// m - Message
// n - New line
// h - Highlight log level

fn create_config() -> Result<Config> {
  // log level filter
  #[cfg(debug_assertions)]
  let log_level = LevelFilter::Debug;
  #[cfg(not(debug_assertions))]
  let log_level = LevelFilter::Info;

  let stdout_appender = ConsoleAppender::builder()
    .encoder(Box::new(PatternEncoder::new(
      "[{d(%Y-%m-%d %H:%M:%S)} {h({l})}] {h({m})}{n}",
    )))
    .build();

  let size_trigger = SizeTrigger::new(1024 * 1024 * 10); // 10MB
  let roller = FixedWindowRoller::builder().base(0).build("logs/tms.{}.log", 10)?;

  let policy = CompoundPolicy::new(Box::new(size_trigger), Box::new(roller));

  // logging to file
  let rolling_appender = RollingFileAppender::builder()
    .encoder(Box::new(PatternEncoder::new(
      "[{d(%Y-%m-%d %H:%M:%S)} {h({l})} {M} LINE: {L}] {h({m})}{n}",
    )))
    .build("logs/tms.log", Box::new(policy))?;

  let config = Config::builder()
    .appender(Appender::builder().build("stdout_appender", Box::new(stdout_appender)))
    .appender(Appender::builder().build("rolling_appender", Box::new(rolling_appender)))
    .build(
      Root::builder()
        .appender("stdout_appender")
        .appender("rolling_appender")
        .build(log_level),
    )?;

  Ok(config)
}

pub fn init_logging() -> Result<()> {
  // Initialize log env
  #[cfg(debug_assertions)]
  env::set_var("RUST_LOG", "debug");
  #[cfg(not(debug_assertions))]
  env::set_var("RUST_LOG", "info");

  let config = create_config()?;
  log4rs::init_config(config)?;

  Ok(())
}
