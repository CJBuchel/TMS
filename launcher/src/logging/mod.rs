use std::env;

use anyhow::Result;
use log::LevelFilter;
use log4rs::{
  append::{
    console::ConsoleAppender,
    rolling_file::{
      policy::compound::{roll::fixed_window::FixedWindowRoller, trigger::size::SizeTrigger, CompoundPolicy},
      RollingFileAppender,
    },
  },
  config::{Appender, Logger, Root},
  encode::pattern::PatternEncoder,
  Config,
};

fn create_config() -> Result<Config> {
  // log level filter
  #[cfg(debug_assertions)]
  let log_level = LevelFilter::Debug;
  #[cfg(not(debug_assertions))]
  let log_level = LevelFilter::Info;

  let stdout = ConsoleAppender::builder()
    .encoder(Box::new(PatternEncoder::new(
      "[{d(%Y-%m-%d %H:%M:%S)} {h({l})}] {h({m})}{n}",
    )))
    .build();

  let size_trigger = SizeTrigger::new(1024 * 1024 * 10); // 10MB
  let roller = FixedWindowRoller::builder().base(0).build("logs/tms.{}.log", 10)?;

  let policy = CompoundPolicy::new(Box::new(size_trigger), Box::new(roller));

  // logging to file
  let tms_server = RollingFileAppender::builder()
    .encoder(Box::new(PatternEncoder::new(
      "[{d(%Y-%m-%d %H:%M:%S)} {h({l})} {M} LINE: {L}] {h({m})}{n}",
    )))
    .build("logs/tms.log", Box::new(policy))?;

  let config = Config::builder()
    .appender(Appender::builder().build("stdout", Box::new(stdout)))
    .appender(Appender::builder().build("tms_server", Box::new(tms_server)))
    .logger(
      Logger::builder()
        .appender("tms_server")
        .additive(false)
        .build("tms_server", log_level),
    )
    .build(Root::builder().appender("stdout").build(log_level))?;

  Ok(config)
}

/// Initialize logger with log4rs
pub fn init_logger() -> Result<()> {
  // Set default log level based on build configuration
  #[cfg(debug_assertions)]
  env::set_var("RUST_LOG", "debug");
  #[cfg(not(debug_assertions))]
  env::set_var("RUST_LOG", "info");

  let config = create_config()?;
  log4rs::init_config(config)?;

  Ok(())
}
