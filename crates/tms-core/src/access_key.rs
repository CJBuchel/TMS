//! Access key text format: `<ROLE PREFIX>-XXXX-XXXX-XXXX`, using Crockford base32 (60 bits).
//! When parsing, `O` reads as `0` and `I`/`L` read as `1`, so hand-typed keys tolerate the usual confusions.

use crate::Role;

pub const ALPHABET: &[u8; 32] = b"0123456789ABCDEFGHJKMNPQRSTVWXYZ";
pub const SECRET_LEN: usize = 12;

/// A key normalised to upper case without spaces, with the role taken from its prefix.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ParsedKey {
  pub role: Role,
  pub normalized: String,
}

pub fn parse(input: &str) -> Option<ParsedKey> {
  let normalized: String = input
    .trim()
    .to_ascii_uppercase()
    .chars()
    .filter(|c| !c.is_whitespace())
    .collect();
  let (prefix, rest) = normalized.split_once('-')?;
  let role = Role::from_key_prefix(prefix)?;
  let secret: String = rest
    .chars()
    .filter(|c| *c != '-')
    .map(|c| match c {
      'O' => '0',
      'I' | 'L' => '1',
      c => c,
    })
    .collect();
  if secret.len() != SECRET_LEN || !secret.bytes().all(|b| ALPHABET.contains(&b)) {
    return None;
  }
  Some(ParsedKey {
    role,
    normalized: format(role, &secret),
  })
}

/// Formats a key from its role and a secret of `SECRET_LEN` alphabet characters.
pub fn format(role: Role, secret: &str) -> String {
  let groups: Vec<&str> = secret
    .as_bytes()
    .chunks(4)
    .map(|c| std::str::from_utf8(c).unwrap_or_default())
    .collect();
  format!("{}-{}", role.key_prefix(), groups.join("-"))
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn parses_and_normalises() {
    let k = parse(" ref-abcd-efgh-jkmn ").unwrap();
    assert_eq!(k.role, Role::Referee);
    assert_eq!(k.normalized, "REF-ABCD-EFGH-JKMN");
  }

  #[test]
  fn maps_confusable_letters() {
    assert_eq!(parse("JA-OOII-LLAB-CDEF").unwrap().normalized, "JA-0011-11AB-CDEF");
  }

  #[test]
  fn rejects_bad_keys() {
    assert!(parse("XYZ-ABCD-EFGH-JKMN").is_none());
    assert!(parse("REF-ABCD-EFGH").is_none());
    assert!(parse("REF-ABCD-EFGH-JKMU").is_none());
    assert!(parse("REFABCDEFGHJKMN").is_none());
  }
}
