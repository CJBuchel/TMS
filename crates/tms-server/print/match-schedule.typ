// Every match with its team at each table.
#import "common.typ": *
#show: setup.with("Match schedule", flipped: data.tables.len() > 4)

#text(18pt, weight: "bold")[Match schedule]
#v(6pt)
#grid-table(
  (auto, auto, auto, ..data.tables.map(_ => 1fr)),
  ([Match], [Start], [End], ..data.tables),
  data.matches.map(m => (m.label, m.start, m.end, ..m.teams)),
)
