//! TMS design system: rounded panels on a quiet background, colour kept for what needs attention. Colours come
//! from CSS custom properties defined in `tms-client/tailwind.css`, exposed to Tailwind as `bg-surface`,
//! `text-muted`, `border-line`, `bg-danger` etc. Semantic colours mean something: danger destroys or failed,
//! warning needs attention, success confirmed, info neutral.

mod banner;
mod button;
mod card;
mod field;
mod modal;
mod table;
mod tabs;
mod tone;

pub use banner::Banner;
pub use button::{Button, ButtonSize, ButtonVariant};
pub use card::{Card, KeyValue};
pub use field::{Checkbox, Select, TextField};
pub use modal::Modal;
pub use table::DataTable;
pub use tabs::{Tab, Tabs};
pub use tone::{Badge, Tone};
