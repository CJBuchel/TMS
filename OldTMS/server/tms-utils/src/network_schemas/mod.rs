

// Public network schemas are non standard connections (unencrypted, non-secure, register/login setup etc...)
mod public;
pub use public::*;

// Private network schemas are standard connections (encrypted, secure, and require specific user permissions)
mod private;
pub use private::*;