use anyhow::{Ok, Result};
use log::LevelFilter;
use log4rs::{
  Config,
  append::{
    console::ConsoleAppender,
    rolling_file::{
      RollingFileAppender,
      policy::compound::{CompoundPolicy, roll::fixed_window::FixedWindowRoller, trigger::size::SizeTrigger},
    },
  },
  config::{Appender, Root},
  encode::pattern::PatternEncoder,
  filter,
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

  // logging to console
  let stdout_log_level = LevelFilter::Info; // always log info to console

  let stdout_appender = ConsoleAppender::builder()
    .encoder(Box::new(PatternEncoder::new("[{d(%Y-%m-%d %H:%M:%S)} {h({l})}] {h({m})}{n}")))
    .build();

  let size_trigger = SizeTrigger::new(1024 * 1024 * 10); // 10MB
  let roller = FixedWindowRoller::builder().base(0).build("logs/tms.{}.log", 10)?;

  let policy = CompoundPolicy::new(Box::new(size_trigger), Box::new(roller));

  // logging to file
  let rolling_appender = RollingFileAppender::builder()
    .encoder(Box::new(PatternEncoder::new("[{d(%Y-%m-%d %H:%M:%S)} {h({l})} {M} LINE: {L}] {h({m})}{n}")))
    .build("logs/tms.log", Box::new(policy))?;

  // Build configuration with filters
  let config = Config::builder()
    .appender(
      Appender::builder()
        .filter(Box::new(filter::threshold::ThresholdFilter::new(stdout_log_level)))
        .build("stdout_appender", Box::new(stdout_appender)),
    )
    .appender(Appender::builder().build("rolling_appender", Box::new(rolling_appender)))
    // Root logger configuration
    .build(Root::builder().appender("stdout_appender").appender("rolling_appender").build(log_level))?;

  Ok(config)
}

pub fn init_logging() -> Result<()> {
  // Initialize log env
  let config = create_config()?;
  log4rs::init_config(config)?;
  Ok(())
}
