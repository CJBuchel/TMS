use axum::Router;
use axum::routing::{delete, get, patch, post};

use crate::AppState;

pub mod audit_log;
pub mod auth;
pub mod awards;
pub mod banners;
pub mod events;
pub mod exports;
pub mod game;
pub mod judging;
pub mod keys;
pub mod print;
pub mod queue;
pub mod schedule;
pub mod schedule_edit;
pub mod scoresheets;
pub mod support;
pub mod system;
pub mod teams;
pub mod users;
pub mod venue;

pub fn routes() -> Router<AppState> {
  Router::new()
    .route("/version", get(system::version))
    .route("/seasons", get(events::seasons))
    .route("/auth/login", post(auth::login))
    .route("/auth/key", post(auth::key_login))
    .route("/auth/logout", post(auth::logout))
    .route("/auth/me", get(auth::me))
    .route("/auth/refresh", post(auth::refresh))
    .route("/auth/password", post(auth::change_password))
    .route("/events", get(events::list).post(events::create))
    .route("/events/active", get(events::active))
    .route("/events/{id}", patch(events::update))
    .route("/events/{id}/activate", post(events::activate))
    .route("/events/{id}/archive", post(events::archive))
    .route("/events/{id}/keys", get(keys::list).post(keys::create))
    .route("/keys/{id}/revoke", post(keys::revoke))
    .route("/events/{id}/banners", get(banners::list).post(banners::create))
    .route("/banners/{id}/clear", post(banners::clear))
    .route("/events/{id}/teams", get(teams::list).post(teams::create))
    .route("/teams/{id}", patch(teams::update).delete(teams::delete))
    .route("/events/{id}/tables", get(venue::tables).post(venue::create_table))
    .route("/events/{id}/tables/order", post(venue::reorder_tables))
    .route("/tables/{id}", patch(venue::rename_table).delete(venue::delete_table))
    .route("/events/{id}/pods", get(venue::pods).post(venue::create_pod))
    .route("/events/{id}/pods/order", post(venue::reorder_pods))
    .route("/pods/{id}", patch(venue::update_pod).delete(venue::delete_pod))
    .route("/events/{id}/matches", get(schedule::matches))
    .route("/events/{id}/judging-sessions", get(schedule::sessions))
    .route("/events/{id}/import/tiab", post(schedule::import_tiab))
    .route(
      "/events/{id}/blocks",
      get(schedule::blocks).post(schedule::create_block),
    )
    .route(
      "/blocks/{id}",
      patch(schedule::update_block).delete(schedule::delete_block),
    )
    .route("/users", get(users::list).post(users::create))
    .route("/users/{id}", patch(users::update))
    .route("/users/{id}/reset-password", post(users::reset_password))
    .route("/audit", get(audit_log::list))
    .route("/matches/{id}/stage", post(game::stage))
    .route("/matches/{id}/unstage", post(game::unstage))
    .route("/matches/{id}/cancel", post(game::cancel))
    .route("/matches/{id}/reset", post(game::reset))
    .route("/events/{id}/timer", get(game::get_timer))
    .route("/events/{id}/timer/start", post(game::start_timer))
    .route("/events/{id}/timer/abort", post(game::abort_timer))
    .route("/events/{id}/timer/end", post(game::end_timer))
    .route("/events/{id}/rankings", get(game::get_rankings))
    .route("/events/{id}/scoresheets", get(scoresheets::list))
    .route("/sync/scoresheets", post(scoresheets::sync))
    .route("/scoresheets/{id}", get(scoresheets::get))
    .route("/scoresheets/{id}/accept", post(scoresheets::accept))
    .route("/scoresheets/{id}/reject", post(scoresheets::reject))
    .route("/scoresheets/{id}/unpublish", post(scoresheets::unpublish))
    .route("/slots/{id}/queue", post(queue::act))
    .route("/judging-slots/{id}/queue", post(judging::queue))
    .route("/events/{id}/pod-timers", get(judging::pod_timers))
    .route("/pods/{id}/timer/{action}", post(judging::pod_timer))
    .route("/sync/rubrics", post(judging::sync))
    .route("/events/{id}/rubrics", get(judging::list))
    .route("/rubrics/{id}", get(judging::get))
    .route("/rubrics/{id}/accept", post(judging::accept))
    .route("/rubrics/{id}/reject", post(judging::reject))
    .route("/events/{id}/judging-scores", get(judging::scores))
    .route("/events/{id}/awards", get(awards::list).post(awards::create))
    .route("/events/{id}/awards/order", post(awards::reorder))
    .route("/awards/{id}", patch(awards::update).delete(awards::delete))
    .route("/awards/{id}/winners", post(awards::assign))
    .route("/awards/{id}/winners/{place}", delete(awards::unassign))
    .route("/events/{id}/deliberation", get(awards::deliberation))
    .route("/events/{id}/advancement", post(awards::advancement))
    .route("/events/{id}/deliberation/finalize", post(awards::finalize))
    .route("/events/{id}/deliberation/reopen", post(awards::reopen))
    .route("/events/{id}/ceremony/script", get(awards::script))
    .route("/events/{id}/ceremony/{action}", post(awards::ceremony_action))
    .route("/events/{id}/exports/{file}", get(exports::export))
    .route("/events/{id}/print/{file}", get(print::print))
    .route("/events/{id}/schedule/generate", post(schedule::generate))
    .route("/events/{id}/schedule/issues", get(schedule::issues))
    .route("/events/{id}/schedule/export.csv", get(schedule::export_tiab))
    .route("/match-slots/{id}/assign", post(schedule_edit::assign_match_slot))
    .route("/match-slots/{id}/swaps", get(schedule_edit::swap_options))
    .route("/match-slots/swap", post(schedule_edit::swap_match_slots))
    .route("/matches/{id}/move", post(schedule_edit::move_match))
    .route("/judging-slots/{id}/assign", post(schedule_edit::assign_judging_slot))
    .route("/judging-slots/swap", post(schedule_edit::swap_judging_slots))
    .route("/judging-sessions/{id}/move", post(schedule_edit::move_session))
}
