// One page per team: everything the team has to be at, in order.
#import "common.typ": *
#show: setup.with("Team schedules")

#for (i, team) in data.teams.enumerate() [
  #if i > 0 { pagebreak() }
  #text(30pt, weight: "bold")[#team.number]
  #h(10pt)
  #text(18pt, weight: "semibold")[#team.name]
  #if team.affiliation != "" [ \ #text(fill: muted)[#team.affiliation] ]
  #v(14pt)
  #grid-table(
    (auto, auto, 1fr, auto),
    ([Time], [Until], [What], [Where]),
    team.items.map(it => (it.start, it.end, if it.kind == "match" { strong(it.what) } else { it.what }, it.place)),
  )
  #if team.items.len() == 0 [#text(fill: muted)[Nothing scheduled yet.]]
]
