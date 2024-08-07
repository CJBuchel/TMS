use crate::{database::*, network::ClientMap, network::client_publish::ClientPublish};

// pub async fn season_get_fll_game(db: SharedDatabase, season: String) -> Result<impl warp::Reply, warp::Rejection> {
//   let read_db = db.read().await;
//   match read_db.get_bl(season).await {
//     Some(fll_game) => Ok(warp::reply::json(&fll_game)),
//     None => Ok(warp::reply::json(&""))
//   }
// }