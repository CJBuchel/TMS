// Every judging session with its team in each pod.
#import "common.typ": *
#show: setup.with("Judging schedule", flipped: data.pods.len() > 4)

#text(18pt, weight: "bold")[Judging schedule]
#v(6pt)
#grid-table(
  (auto, auto, auto, ..data.pods.map(_ => 1fr)),
  ([Session], [Start], [End], ..data.pods),
  data.sessions.map(s => (s.label, s.start, s.end, ..s.teams)),
)
