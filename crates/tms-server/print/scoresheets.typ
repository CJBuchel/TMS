// Paper scoresheets for when a tablet isn't available: one per team per match, with every mission's answers to
// circle. Scores are worked out when the sheet is entered into TMS.
#import "common.typ": *
#show: setup.with("Scoresheets")

#let boxes(options) = options.map(o => box(stroke: 0.6pt + ink, inset: (x: 3.5pt, y: 2pt), radius: 2pt)[#o]).join(h(3pt))

#for (i, sheet) in data.sheets.enumerate() [
  #if i > 0 { pagebreak() }
  #grid(
    columns: (1fr, auto),
    [#text(20pt, weight: "bold")[#sheet.team] \ #text(fill: muted)[#sheet.team_name]],
    align(right)[#text(14pt, weight: "semibold")[#sheet.match] \ #text(fill: muted)[#sheet.table · #sheet.time]],
  )
  #v(4pt)
  #line(length: 100%, stroke: 0.6pt + rule)
  #set text(7.5pt)
  #columns(2, gutter: 14pt)[
    #for m in data.missions [
      #block(breakable: false, below: 5pt)[
        #text(weight: "semibold")[#m.name]
        #for f in m.fields [ \ #f.label #h(1fr) #boxes(f.options) ]
      ]
    ]
  ]
  #v(6pt)
  #line(length: 100%, stroke: 0.6pt + rule)
  #grid(
    columns: (1fr, 1fr),
    gutter: 10pt,
    [Gracious Professionalism #h(6pt) #boxes(("2 Developing", "3 Accomplished", "4 Exceeds"))],
    [Referee #box(width: 1fr, stroke: (bottom: 0.6pt + ink))[] #h(8pt) Team initials #box(width: 2.5cm, stroke: (bottom: 0.6pt + ink))[]],
  )
]
