use warp::Filter;

pub fn pulse_filter() -> impl warp::Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
  warp::path("pulse")
    .and(warp::get())
    .map(|| warp::reply())
}