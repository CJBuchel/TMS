use crate::AppState;
use tms_core::Topic;
use tms_core::game::MatchTimer;
use tms_core::ws::TopicItem;

use crate::repo::{awards, banners, blocks, events, game, judging, schedule, scoresheets, teams, venue};

/// Current full contents of a topic, for the active event.
pub async fn load(state: &AppState, topic: Topic) -> sqlx::Result<Vec<TopicItem>> {
  let pool = &state.pool;
  let Some(event) = events::active(pool).await? else {
    return Ok(Vec::new());
  };
  let id = event.id;
  Ok(match topic {
    Topic::Event => vec![TopicItem::Event(event)],
    Topic::Banners => banners::list_active(pool, id)
      .await?
      .into_iter()
      .map(TopicItem::Banner)
      .collect(),
    Topic::Teams => teams::list(pool, id).await?.into_iter().map(TopicItem::Team).collect(),
    Topic::Tables => venue::tables(pool, id)
      .await?
      .into_iter()
      .map(TopicItem::Table)
      .collect(),
    Topic::Pods => venue::pods(pool, id).await?.into_iter().map(TopicItem::Pod).collect(),
    Topic::Matches => {
      let mut conn = pool.acquire().await?;
      schedule::matches(&mut conn, id)
        .await?
        .into_iter()
        .map(TopicItem::Match)
        .collect()
    }
    Topic::JudgingSessions => {
      let mut conn = pool.acquire().await?;
      schedule::sessions(&mut conn, id)
        .await?
        .into_iter()
        .map(TopicItem::JudgingSession)
        .collect()
    }
    Topic::Blocks => blocks::list(pool, id)
      .await?
      .into_iter()
      .map(TopicItem::Block)
      .collect(),
    Topic::Timer => {
      let timer = match game::timer(pool, id).await? {
        Some((timer, _)) => timer,
        None => MatchTimer::idle(id, &event.settings),
      };
      vec![TopicItem::Timer(timer)]
    }
    Topic::Rankings => crate::http::game::rankings(pool, id)
      .await?
      .into_iter()
      .map(TopicItem::Ranking)
      .collect(),
    Topic::Scoresheets => scoresheets::list(pool, id)
      .await?
      .into_iter()
      .map(|s| TopicItem::Scoresheet(Box::new(s)))
      .collect(),
    Topic::Presence => state.presence.list(id).into_iter().map(TopicItem::Presence).collect(),
    Topic::PodTimers => judging::timers(pool, id)
      .await?
      .into_iter()
      .map(TopicItem::PodTimer)
      .collect(),
    Topic::Rubrics => judging::list(pool, id)
      .await?
      .into_iter()
      .map(|r| TopicItem::Rubric(Box::new(r)))
      .collect(),
    Topic::Deliberation => {
      let mut conn = pool.acquire().await?;
      let deliberation = awards::deliberation(&mut conn, id, event.settings.advancement_slots).await?;
      vec![TopicItem::Deliberation(Box::new(deliberation))]
    }
    Topic::Issues => state
      .issues
      .list(pool, id)
      .await?
      .into_iter()
      .map(TopicItem::Issue)
      .collect(),
    Topic::Ceremony => {
      let mut conn = pool.acquire().await?;
      match crate::http::awards::ceremony(&mut conn, id).await {
        Ok(ceremony) => vec![TopicItem::Ceremony(ceremony)],
        Err(e) => {
          tracing::warn!("ceremony snapshot failed: {e}");
          Vec::new()
        }
      }
    }
  })
}
