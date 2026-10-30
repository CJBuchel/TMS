//! Times are stored in UTC and always shown in the event's timezone, whatever the device's own setting.
//! Formatting uses the browser's timezone database (`Intl`); the server validates event timezones, so an
//! unknown zone never reaches it.

use chrono::{DateTime, Utc};
use js_sys::{Date, Object, Reflect};
use web_sys::wasm_bindgen::JsValue;

pub fn now_ms() -> i64 {
  #[allow(clippy::cast_possible_truncation)]
  let ms = Date::now() as i64;
  ms
}

fn js_date(epoch_ms: i64) -> Date {
  #[allow(clippy::cast_precision_loss)]
  Date::new(&JsValue::from_f64(epoch_ms as f64))
}

fn options(timezone: &str, fields: &[(&str, &str)]) -> Object {
  let options = Object::new();
  let _ = Reflect::set(&options, &"timeZone".into(), &timezone.into());
  let _ = Reflect::set(&options, &"hourCycle".into(), &"h23".into());
  for (key, value) in fields {
    let _ = Reflect::set(&options, &(*key).into(), &(*value).into());
  }
  options
}

/// `HH:MM:SS`.
pub fn format_clock(epoch_ms: i64, timezone: &str) -> String {
  String::from(js_date(epoch_ms).to_locale_time_string_with_options("en-GB", &options(timezone, &[])))
}

/// `HH:MM`.
pub fn format_time(at: DateTime<Utc>, timezone: &str) -> String {
  let opts = options(timezone, &[("hour", "2-digit"), ("minute", "2-digit")]);
  String::from(js_date(at.timestamp_millis()).to_locale_time_string_with_options("en-GB", &opts))
}

/// `Sat 14 Nov, 09:30`.
pub fn format_datetime(at: DateTime<Utc>, timezone: &str) -> String {
  let opts = options(
    timezone,
    &[
      ("weekday", "short"),
      ("day", "numeric"),
      ("month", "short"),
      ("hour", "2-digit"),
      ("minute", "2-digit"),
    ],
  );
  String::from(js_date(at.timestamp_millis()).to_locale_string("en-GB", &opts))
}

/// `2026-11-14T09:30` in the event's timezone, as a `datetime-local` input wants it. The Swedish locale writes
/// dates and times in ISO order.
pub fn local_input(at: DateTime<Utc>, timezone: &str) -> String {
  let opts = options(
    timezone,
    &[
      ("year", "numeric"),
      ("month", "2-digit"),
      ("day", "2-digit"),
      ("hour", "2-digit"),
      ("minute", "2-digit"),
    ],
  );
  String::from(js_date(at.timestamp_millis()).to_locale_string("sv-SE", &opts)).replace(' ', "T")
}

/// The device's own timezone, a sensible default for a new event.
pub fn device_timezone() -> String {
  let format = js_sys::Intl::DateTimeFormat::new(&js_sys::Array::new(), &Object::new());
  let resolved = format.resolved_options();
  Reflect::get(&resolved, &"timeZone".into())
    .ok()
    .and_then(|v| v.as_string())
    .unwrap_or_else(|| "UTC".to_owned())
}
