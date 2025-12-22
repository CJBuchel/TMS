use std::{io::Result, path::PathBuf};

fn find_workspace_root() -> PathBuf {
  let mut current = PathBuf::from(env!("CARGO_MANIFEST_DIR"));

  loop {
    if current.join("Cargo.toml").exists() {
      // Check if this is likely the workspace root by looking for a [workspace] section
      if let Ok(content) = std::fs::read_to_string(current.join("Cargo.toml"))
        && content.contains("[workspace]")
      {
        return current;
      }
    }

    // Move to parent directory
    if let Some(parent) = current.parent() {
      current = parent.to_path_buf();
    } else {
      // Fallback: return one level up from manifest dir
      return PathBuf::from(env!("CARGO_MANIFEST_DIR")).parent().unwrap().to_path_buf();
    }
  }
}

// Generate rust code from proto files
fn main() -> Result<()> {
  let workspace_root = find_workspace_root();
  let proto_dir = workspace_root.join("protos");

  tonic_prost_build::configure().out_dir("src/generated").compile_protos(
    &[
      proto_dir.join("db/db.proto").to_str().unwrap(),
      proto_dir.join("common/common.proto").to_str().unwrap(),
      proto_dir.join("api/api.proto").to_str().unwrap(),
    ],
    &[proto_dir.to_str().unwrap()],
  )?;

  Ok(())
}
