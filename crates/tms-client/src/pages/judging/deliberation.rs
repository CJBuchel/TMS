//! Deliberation: award allocation step by step in the official order, advancement, finalizing, and exports.

use dioxus::prelude::*;
use tms_core::deliberation::{
  AdvancementRequest, AssignRequest, AwardKind, Candidate, Deliberation, Step, TeamScores, place_label,
};
use tms_core::model::Team;
use tms_core::role::has_role;
use tms_core::{Role, Topic};
use tms_ui::{Badge, Button, ButtonSize, ButtonVariant, Card, DataTable, Modal, TextField, Tone};
use uuid::Uuid;

use super::ceremony::CeremonyControls;
use crate::components::{ConfirmButton, ErrorBox, NeedsActiveEvent, PageHeader, token};
use crate::net::api::{self, ApiFailure};
use crate::net::realtime::{Realtime, use_subscription};
use crate::pages::game::shared::team_label;
use crate::store::session::Session;

/// What a step's candidates are ordered by.
fn basis(kind: Option<AwardKind>) -> &'static str {
  match kind {
    None | Some(AwardKind::Champions | AwardKind::EngineeringExcellence) => "Champion's rank",
    Some(AwardKind::RisingAllStar | AwardKind::Motivate) => "Champion's rank, among the teams the judges selected",
    Some(AwardKind::RobotPerformance) => "Robot game rank (best score, then second, then third)",
    Some(AwardKind::CoreValues) => "Core Values rank",
    Some(AwardKind::InnovationProject) => "Innovation Project rank",
    Some(AwardKind::RobotDesign) => "Robot Design rank",
    Some(AwardKind::Breakthrough) => "Best single area rank, among the teams the judges selected",
    Some(AwardKind::CoachMentor | AwardKind::Peer) => "The judges choose from the nomination forms",
    Some(AwardKind::Local) => "The tournament's own process",
  }
}

fn step_kind(d: &Deliberation, step: Step) -> Option<AwardKind> {
  match step {
    Step::Award { award_id, .. } => d.award(award_id).map(|a| a.kind),
    Step::Advancement => None,
  }
}

fn step_key(step: Step) -> String {
  match step {
    Step::Award { award_id, place } => format!("{award_id}-{place}"),
    Step::Advancement => "advancement".into(),
  }
}

/// Every team that took this step, as labels.
fn step_winners(d: &Deliberation, teams: &[Team], step: Step) -> Vec<String> {
  match step {
    Step::Award { award_id, place } => d
      .winner(award_id, place)
      .map(|w| vec![team_label(teams, Some(w.team_id))])
      .unwrap_or_default(),
    Step::Advancement => d.advancing.iter().map(|id| team_label(teams, Some(*id))).collect(),
  }
}

#[component]
pub fn JudgingDeliberation() -> Element {
  use_subscription(Topic::Teams);
  use_subscription(Topic::Deliberation);
  let realtime = use_context::<Realtime>();
  let session = use_context::<Session>();
  let mut chosen = use_signal(|| None::<Step>);
  let error = use_signal(|| None::<ApiFailure>);
  if realtime.stores.event.read().is_none() {
    return rsx! { PageHeader { title: "Deliberation" } NeedsActiveEvent {} };
  }
  let Some(d) = realtime.stores.deliberation.read().clone() else {
    return rsx! { PageHeader { title: "Deliberation" } p { class: "text-sm text-muted", "Loading…" } };
  };
  let teams = realtime.stores.teams.read().clone();
  let steps = d.steps();
  let current = d.current_step();
  let step = chosen()
    .filter(|s| steps.contains(s))
    .or(current)
    .or(steps.first().copied());
  let awarded = d.teams_awarded();
  let percent = awarded * 100 / d.teams.len().max(1);
  let is_admin = has_role(&session.read().roles(), Role::Admin);

  rsx! {
    PageHeader {
      title: "Deliberation",
      back: (crate::routes::Route::JudgingDashboard {}, "Judging".to_owned()),
      subtitle: "{awarded} of {d.teams.len()} teams have an award ({percent}%). The guide aims for 30 to 50%. Ranks never change; giving an award to anyone but the best-ranked eligible team needs a reason.",
      actions: rsx! {
        if let Some(f) = &d.finalized {
          Badge { tone: Tone::Success, "Finalized by {f.by}" }
        }
      },
    }
    if let Some(e) = error() {
      div { class: "mb-3", ErrorBox { error: e } }
    }
    div { class: "grid gap-4 lg:grid-cols-[18rem_1fr]",
      Card { title: "Steps",
        ol { class: "flex flex-col", "data-testid": "steps",
          for s in steps.iter().copied() {
            {
                let done = d.step_done(s);
                let winners = step_winners(&d, &teams, s);
                let selected = step == Some(s);
                rsx! {
                  li { key: "{step_key(s)}",
                    button {
                      class: if selected { "flex w-full items-start justify-between gap-2 border-l-4 border-primary bg-primary-soft px-2 py-1.5 text-left text-sm" } else { "flex w-full items-start justify-between gap-2 border-l-4 border-transparent px-2 py-1.5 text-left text-sm hover:bg-surface-2" },
                      onclick: move |_| chosen.set(Some(s)),
                      span { class: if done { "text-muted" } else if current == Some(s) { "font-semibold" } else { "" },
                        "{d.step_title(s)}"
                        if !winners.is_empty() {
                          span { class: "block text-xs", "{winners.join(\", \")}" }
                        }
                      }
                      if done {
                        Badge { tone: Tone::Success, "Done" }
                      } else if current == Some(s) {
                        Badge { tone: Tone::Primary, "Next" }
                      }
                    }
                  }
                }
            }
          }
        }
      }
      div { class: "flex min-w-0 flex-col gap-4",
        if let Some(s) = step {
          match s {
              Step::Advancement => rsx! { AdvancementStep { d: d.clone(), teams: teams.clone(), error } },
              Step::Award { .. } => rsx! { AwardStep { key: "{step_key(s)}", d: d.clone(), teams: teams.clone(), step: s, error } },
          }
        }
        FinalizeCard { d: d.clone(), is_admin, error }
        if d.finalized.is_some() {
          CeremonyControls {}
        }
        ExportsCard { event_id: d.event_id, error }
      }
    }
  }
}

fn ranks_summary(t: &TeamScores) -> String {
  format!(
    "CV {} · IP {} · RD {} · RG {} · Champion's {}",
    t.core_values_rank, t.innovation_project_rank, t.robot_design_rank, t.robot_game_rank, t.champions_rank
  )
}

#[component]
fn AwardStep(d: Deliberation, teams: Vec<Team>, step: Step, error: Signal<Option<ApiFailure>>) -> Element {
  let session = use_context::<Session>();
  let mut needs_reason = use_signal(|| None::<Uuid>);
  let mut reason = use_signal(String::new);
  let Step::Award { award_id, place } = step else {
    return rsx! {};
  };
  let kind = step_kind(&d, step);
  let top = d.top_candidate(step);
  let winner = d.winner(award_id, place).cloned();
  let candidates: Vec<Candidate> = d.candidates(step);
  let locked = d.finalized.is_some();
  let assign = move |team_id: Uuid, note: String| async move {
    error.set(None);
    let body = AssignRequest { team_id, place, note };
    match api::post::<_, Deliberation>(&format!("/awards/{award_id}/winners"), token(session).as_deref(), &body).await {
      Ok(_) => needs_reason.set(None),
      Err(e) => error.set(Some(e)),
    }
  };
  let remove = move |()| async move {
    error.set(None);
    if let Err(e) = api::delete(
      &format!("/awards/{award_id}/winners/{place}"),
      token(session).as_deref(),
    )
    .await
    {
      error.set(Some(e));
    }
  };

  rsx! {
    Card { title: "{d.step_title(step)}",
      p { class: "mb-3 text-sm text-muted", "Ordered by {basis(kind)}." }
      if let Some(w) = winner {
        div { class: "rounded-control mb-3 flex flex-wrap items-center gap-3 border border-success bg-success-soft px-3 py-2", "data-testid": "step-winner",
          span { class: "font-semibold", "{team_label(&teams, Some(w.team_id))}" }
          if !w.note.is_empty() {
            span { class: "text-sm", "Reason: {w.note}" }
          }
          span { class: "text-xs text-muted", "by {w.assigned_by}" }
          if !locked {
            ConfirmButton {
              label: "Remove",
              title: "Remove this winner?",
              message: "The place opens again. Later steps keep their winners.",
              confirm_label: "Remove",
              onconfirm: remove,
            }
          }
        }
      }
      DataTable {
        columns: vec!["Rank".into(), "Team".into(), "Area ranks".into(), String::new()],
        empty: "No teams.",
        rows: candidates
            .iter()
            .map(|c| {
                let team_id = c.team_id;
                let scores = d.scores(team_id).map(ranks_summary).unwrap_or_default();
                let is_top = top == Some(team_id);
                let open = d.winner(award_id, place).is_none() && !locked;
                rsx! {
                  tr { key: "{team_id}", class: if c.ineligible.is_some() { "text-muted" } else { "" },
                    td { class: "font-mono", {c.rank.map(|r| r.to_string()).unwrap_or_default()} }
                    td {
                      span { class: "font-semibold", "{team_label(&teams, Some(team_id))}" }
                      if is_top {
                        span { class: "ml-2", Badge { tone: Tone::Primary, "Best-ranked eligible" } }
                      }
                    }
                    td { class: "text-xs", "{scores}" }
                    td { class: "text-right",
                      match &c.ineligible {
                          Some(why) => rsx! { span { class: "text-xs", "{why}" } },
                          None if open => rsx! {
                            Button {
                              size: ButtonSize::Small,
                              variant: if is_top { ButtonVariant::Primary } else { ButtonVariant::Secondary },
                              onclick: move |_| async move {
                                  // Steps the judges choose freely have no best-ranked team, so need no reason.
                                  if is_top || top.is_none() {
                                      assign(team_id, String::new()).await;
                                  } else {
                                      reason.set(String::new());
                                      needs_reason.set(Some(team_id));
                                  }
                              },
                              "Give {place_label(place)}"
                            }
                          },
                          None => rsx! {},
                      }
                    }
                  }
                }
            })
            .collect(),
      }
    }
    if let Some(team_id) = needs_reason() {
      Modal {
        title: "Not the best-ranked eligible team",
        onclose: move |()| needs_reason.set(None),
        footer: rsx! {
          Button { variant: ButtonVariant::Ghost, onclick: move |_| needs_reason.set(None), "Cancel" }
          Button {
            variant: ButtonVariant::Primary,
            disabled: reason().trim().is_empty(),
            onclick: move |_| async move { assign(team_id, reason()).await },
            "Give {place_label(place)}"
          }
        },
        p { class: "mb-3 text-sm",
          "{team_label(&teams, top)} is ranked higher and eligible. The ranks stay as they are; say why the judges chose {team_label(&teams, Some(team_id))}."
        }
        TextField { label: "Reason", value: reason(), oninput: move |v| reason.set(v), autofocus: true }
      }
    }
  }
}

#[component]
fn AdvancementStep(d: Deliberation, teams: Vec<Team>, error: Signal<Option<ApiFailure>>) -> Element {
  let session = use_context::<Session>();
  let candidates = d.candidates(Step::Advancement);
  let locked = d.finalized.is_some();
  let full = d.advancing.len() >= d.advancement_slots as usize;
  let event_id = d.event_id;
  let advancing = d.advancing.clone();
  let save = move |ids: Vec<Uuid>| async move {
    error.set(None);
    let body = AdvancementRequest { team_ids: ids };
    if let Err(e) = api::post::<_, Deliberation>(
      &format!("/events/{event_id}/advancement"),
      token(session).as_deref(),
      &body,
    )
    .await
    {
      error.set(Some(e));
    }
  };
  rsx! {
    Card { title: "Advancement",
      p { class: "mb-3 text-sm text-muted",
        "{d.advancement_slots} team(s) advance, by Champion's rank. Teams that advance can still win awards."
      }
      DataTable {
        columns: vec!["Champion's".into(), "Team".into(), String::new()],
        empty: "No teams.",
        rows: candidates
            .iter()
            .map(|c| {
                let team_id = c.team_id;
                let position = advancing.iter().position(|id| *id == team_id);
                let current = advancing.clone();
                rsx! {
                  tr { key: "{team_id}",
                    td { class: "font-mono", {c.rank.map(|r| r.to_string()).unwrap_or_default()} }
                    td { class: "font-semibold", "{team_label(&teams, Some(team_id))}" }
                    td { class: "text-right",
                      match position {
                          Some(p) => rsx! {
                            Badge { tone: Tone::Success, "Advancing {p + 1}" }
                            if !locked {
                              Button {
                                size: ButtonSize::Small,
                                variant: ButtonVariant::Ghost,
                                onclick: move |_| {
                                    let ids: Vec<Uuid> = current.iter().copied().filter(|id| *id != team_id).collect();
                                    save(ids)
                                },
                                "Remove"
                              }
                            }
                          },
                          None if !locked && !full => rsx! {
                            Button {
                              size: ButtonSize::Small,
                              onclick: move |_| {
                                  let mut ids = current.clone();
                                  ids.push(team_id);
                                  save(ids)
                              },
                              "Advance"
                            }
                          },
                          None => rsx! {},
                      }
                    }
                  }
                }
            })
            .collect(),
      }
    }
  }
}

#[component]
fn FinalizeCard(d: Deliberation, is_admin: bool, error: Signal<Option<ApiFailure>>) -> Element {
  let session = use_context::<Session>();
  let event_id = d.event_id;
  let open = d.open_required();
  let act = move |action: &'static str| async move {
    error.set(None);
    if let Err(e) = api::post::<_, Deliberation>(
      &format!("/events/{event_id}/deliberation/{action}"),
      token(session).as_deref(),
      &(),
    )
    .await
    {
      error.set(Some(e));
    }
  };
  rsx! {
    Card { title: "Finalize",
      match &d.finalized {
          Some(f) => rsx! {
            p { class: "text-sm", "Finalized by {f.by}. Rubrics, awards and advancement are locked, and the ceremony can start." }
            if is_admin {
              div { class: "mt-3",
                ConfirmButton {
                  label: "Reopen deliberation",
                  title: "Reopen deliberation?",
                  message: "Awards can change again and the ceremony starts over.",
                  confirm_label: "Reopen",
                  variant: ButtonVariant::Warning,
                  onconfirm: move |()| act("reopen"),
                }
              }
            }
          },
          None => rsx! {
            if open.is_empty() {
              p { class: "text-sm", "Every required award and advancement place is filled." }
            } else {
              p { class: "text-sm text-warning-strong", "Still open: {open.join(\", \")}." }
            }
            div { class: "mt-3",
              ConfirmButton {
                label: "Finalize",
                title: "Finalize deliberation?",
                message: "This locks rubrics, awards and advancement, and lets the ceremony start. Only an admin can reopen it.",
                confirm_label: "Finalize",
                variant: ButtonVariant::Primary,
                size: ButtonSize::Medium,
                onconfirm: move |()| act("finalize"),
              }
            }
          },
      }
    }
  }
}

const EXPORTS: [(&str, &str); 8] = [
  ("results", "Results and rankings"),
  ("awards", "Awards"),
  ("rankings", "Robot game ranking"),
  ("robot-game", "Robot game scores (spreadsheet input)"),
  ("innovation-project", "Innovation Project (spreadsheet input)"),
  ("robot-design", "Robot Design (spreadsheet input)"),
  ("core-values", "Core Values and GP (spreadsheet input)"),
  ("rubrics", "Rubric feedback"),
];

#[component]
fn ExportsCard(event_id: Uuid, error: Signal<Option<ApiFailure>>) -> Element {
  let session = use_context::<Session>();
  let realtime = use_context::<Realtime>();
  let code = realtime
    .stores
    .event
    .read()
    .as_ref()
    .map(|e| e.code.clone())
    .unwrap_or_default();
  rsx! {
    Card { title: "Exports",
      p { class: "mb-3 text-sm text-muted", "CSV files. The spreadsheet input files keep the Official Judging Spreadsheet's column order, so their columns paste straight in." }
      div { class: "flex flex-wrap gap-2",
        for (name , label) in EXPORTS {
          {
              let code = code.clone();
              rsx! {
                Button {
                  key: "{name}",
                  size: ButtonSize::Small,
                  variant: ButtonVariant::Secondary,
                  onclick: move |_| {
                      let code = code.clone();
                      async move {
                          error.set(None);
                          let path = format!("/events/{event_id}/exports/{name}.csv");
                          if let Err(e) = api::download(&path, token(session).as_deref(), &format!("{code}-{name}.csv")).await {
                              error.set(Some(e));
                          }
                      }
                  },
                  "{label}"
                }
              }
          }
        }
      }
    }
  }
}
