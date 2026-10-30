use dioxus::prelude::*;
use tms_core::Role;

use crate::pages::game::{
  DisplayIndex, Emcee, MatchControl, QueueBoard, QueueDisplay, RefereeStation, ScheduleDisplay, ScoreboardDisplay,
  ScoresheetReview, TimerDisplay,
};
use crate::pages::judging::{
  AwardsDisplay, JudgeStation, JudgingDashboard, JudgingDeliberation, JudgingScores, RubricReview,
};
use crate::pages::setup::{
  SetupAudit, SetupAwards, SetupEvent, SetupKeys, SetupLayout, SetupSchedule, SetupTeams, SetupUsers, SetupVenue,
};
use crate::pages::{Home, Login, NotFound, Print, Settings};
use crate::shell::Shell;

#[derive(Debug, Clone, PartialEq, Routable)]
#[rustfmt::skip]
pub enum Route {
  #[layout(Shell)]
    #[route("/")]
    Home {},
    #[route("/settings")]
    Settings {},
    #[route("/print")]
    Print {},
    #[route("/match-control")]
    MatchControl {},
    #[route("/match-control/scoresheets")]
    ScoresheetReview {},
    #[route("/referee")]
    RefereeStation {},
    #[route("/emcee")]
    Emcee {},
    #[route("/queue")]
    QueueBoard {},
    #[route("/judge")]
    JudgeStation {},
    #[route("/judging")]
    JudgingDashboard {},
    #[route("/judging/rubrics")]
    RubricReview {},
    #[route("/judging/scores")]
    JudgingScores {},
    #[route("/judging/deliberation")]
    JudgingDeliberation {},
    #[nest("/setup")]
      #[layout(SetupLayout)]
        #[route("/")]
        SetupEvent {},
        #[route("/teams")]
        SetupTeams {},
        #[route("/venue")]
        SetupVenue {},
        #[route("/schedule")]
        SetupSchedule {},
        #[route("/awards")]
        SetupAwards {},
        #[route("/users")]
        SetupUsers {},
        #[route("/keys")]
        SetupKeys {},
        #[route("/audit")]
        SetupAudit {},
      #[end_layout]
    #[end_nest]
  #[end_layout]
  #[route("/login?:access")]
  Login { access: String },
  #[route("/display")]
  DisplayIndex {},
  #[route("/display/scoreboard")]
  ScoreboardDisplay {},
  #[route("/display/timer?:tables")]
  TimerDisplay { tables: String },
  #[route("/display/queue?:tables")]
  QueueDisplay { tables: String },
  #[route("/display/schedule")]
  ScheduleDisplay {},
  #[route("/display/awards")]
  AwardsDisplay {},
  #[route("/:..segments")]
  NotFound { segments: Vec<String> },
}

impl Route {
  /// Where a device logged in with these roles opens: an admin, or anyone with several screens, gets Home to choose
  /// from; everyone else goes straight to their one screen.
  pub fn primary(roles: &[Role]) -> Route {
    if roles.contains(&Role::Admin) {
      return Route::Home {};
    }
    let mut screens: Vec<Route> = roles
      .iter()
      .filter_map(|role| match role {
        Role::HeadReferee => Some(Route::MatchControl {}),
        Role::Referee => Some(Route::RefereeStation {}),
        Role::JudgeAdvisor => Some(Route::JudgingDashboard {}),
        Role::Judge => Some(Route::JudgeStation {}),
        Role::Queuer => Some(Route::QueueBoard {}),
        Role::Emcee => Some(Route::Emcee {}),
        Role::Display => Some(Route::DisplayIndex {}),
        Role::Admin | Role::Scorekeeper => None,
      })
      .collect();
    screens.dedup();
    match screens.as_slice() {
      [only] => only.clone(),
      _ => Route::Home {},
    }
  }

  pub fn is_setup(&self) -> bool {
    matches!(
      self,
      Route::SetupEvent {}
        | Route::SetupTeams {}
        | Route::SetupVenue {}
        | Route::SetupSchedule {}
        | Route::SetupAwards {}
        | Route::SetupUsers {}
        | Route::SetupKeys {}
        | Route::SetupAudit {}
    )
  }
}
