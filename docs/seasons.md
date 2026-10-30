# Adding a season

A season is Rust code in `crates/tms-seasons`, not data. The scoresheet form, scoring, the rubric form and paper scoresheets all come from it, so a new season needs no changes anywhere else.

1. Copy `src/bioglow.rs` to a new module, such as `src/unearthed.rs`, and add its `Season` to `SEASONS` in `src/lib.rs`.
2. Fill in the missions. Each mission has fields:
   - `Bool`: yes or no;
   - `Count { max }`: how many;
   - `Choice { options }`: one of several.
   Fields can depend on another field (`requires`) and have defaults.
3. Write `score` the way the official scoresheet adds up. Return issues for impossible answers, such as more pieces than exist.
4. Check the scoring against the official Excel scorer. `bioglow.rs` has a test that transcribes the scorer's formulas and compares 20,000 random sheets; do the same.
5. Rubrics: the 2024-25 structure (Innovation Project and Robot Design, ten rows each, five of them for Core Values) has stayed the same since then. A season reuses `rubric::CHALLENGE_RUBRICS`, or defines its own with the same types.
6. Bump `schema_version` whenever a released season's fields change. Devices holding sheets made with the old form are then asked to fill them in again rather than sending wrong answers.
