// The robot game ranking: best score, then second, then third.
#import "common.typ": *
#show: setup.with("Robot game ranking")

#text(18pt, weight: "bold")[Robot game ranking]
#v(6pt)
#grid-table(
  (auto, auto, 1fr, ..data.rounds.map(_ => auto), auto),
  ([Rank], [Team], [Name], ..data.rounds, [Best]),
  data.rows.map(r => (r.rank, r.number, r.name, ..r.scores, strong(r.best))),
)
