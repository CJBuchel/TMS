//! Printable PDFs. Each template under `print/` reads one JSON value, `sys.inputs.data`, and shares its look from
//! `common.typ`. Templates and the Inter font are built into the program. Without the `print` feature (quicker dev
//! builds) every printable answers that this build can't print.

use serde::Serialize;
use tms_core::Role;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Printable {
  TeamSchedules,
  MatchSchedule,
  JudgingSchedule,
  TableSigns,
  PodSigns,
  Scoresheets,
  Rankings,
  Certificates,
}

impl Printable {
  pub const ALL: [Printable; 8] = [
    Printable::TeamSchedules,
    Printable::MatchSchedule,
    Printable::JudgingSchedule,
    Printable::TableSigns,
    Printable::PodSigns,
    Printable::Scoresheets,
    Printable::Rankings,
    Printable::Certificates,
  ];

  pub fn name(self) -> &'static str {
    match self {
      Printable::TeamSchedules => "team-schedules",
      Printable::MatchSchedule => "match-schedule",
      Printable::JudgingSchedule => "judging-schedule",
      Printable::TableSigns => "table-signs",
      Printable::PodSigns => "pod-signs",
      Printable::Scoresheets => "scoresheets",
      Printable::Rankings => "rankings",
      Printable::Certificates => "certificates",
    }
  }

  pub fn from_name(name: &str) -> Option<Self> {
    Self::ALL.into_iter().find(|p| p.name() == name)
  }

  /// Who may print it: anything with results or awards is for the people who own them.
  pub fn role(self) -> Role {
    match self {
      Printable::Scoresheets | Printable::Rankings => Role::HeadReferee,
      Printable::Certificates => Role::JudgeAdvisor,
      _ => Role::Admin,
    }
  }

  #[cfg(feature = "print")]
  fn source(self) -> &'static str {
    match self {
      Printable::TeamSchedules => include_str!("../print/team-schedules.typ"),
      Printable::MatchSchedule => include_str!("../print/match-schedule.typ"),
      Printable::JudgingSchedule => include_str!("../print/judging-schedule.typ"),
      Printable::TableSigns | Printable::PodSigns => include_str!("../print/signs.typ"),
      Printable::Scoresheets => include_str!("../print/scoresheets.typ"),
      Printable::Rankings => include_str!("../print/rankings.typ"),
      Printable::Certificates => include_str!("../print/certificates.typ"),
    }
  }
}

/// Renders a printable to PDF bytes.
#[cfg(feature = "print")]
pub fn render(printable: Printable, data: &impl Serialize) -> anyhow::Result<Vec<u8>> {
  use typst::foundations::{Dict, IntoValue};
  use typst_as_lib::TypstEngine;

  const FONTS: [&[u8]; 3] = [
    include_bytes!("../print/fonts/Inter-Regular.ttf"),
    include_bytes!("../print/fonts/Inter-SemiBold.ttf"),
    include_bytes!("../print/fonts/Inter-Bold.ttf"),
  ];
  let engine = TypstEngine::builder()
    .main_file(("main.typ", printable.source()))
    .with_static_source_file_resolver([("common.typ", include_str!("../print/common.typ"))])
    .fonts(FONTS)
    .build();
  let mut inputs = Dict::new();
  inputs.insert("data".into(), serde_json::to_string(data)?.into_value());
  let document = engine
    .compile_with_input(inputs)
    .output
    .map_err(|e| anyhow::anyhow!("{} did not compile: {e:?}", printable.name()))?;
  typst_pdf::pdf(&document, &typst_pdf::PdfOptions::default())
    .map_err(|e| anyhow::anyhow!("{} did not render: {e:?}", printable.name()))
}

#[cfg(not(feature = "print"))]
pub fn render(printable: Printable, _data: &impl Serialize) -> anyhow::Result<Vec<u8>> {
  anyhow::bail!(
    "this build of TMS was made without printing, so {} isn't available",
    printable.name()
  )
}
