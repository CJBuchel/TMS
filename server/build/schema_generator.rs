
use std::ffi::OsString;
use std::fs;
use std::path::Path;

include!("../src/schemas/schema.rs");

pub fn generate_schema(outdir: &OsString) {
  let schema = schemars::schema_for!(TmsSchema);
  let schema_file = Path::new(outdir).join("tms-schema.json");
  fs::write(schema_file, serde_json::to_string_pretty(&schema).unwrap()).unwrap();
}