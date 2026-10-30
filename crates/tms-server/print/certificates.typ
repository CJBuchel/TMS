// One certificate per award winner, plus one per advancing team.
#import "common.typ": *
#show: setup.with("Certificates", flipped: true, header: false)

#for (i, c) in data.certificates.enumerate() [
  #if i > 0 { pagebreak() }
  #block(width: 100%, height: 100%, stroke: 3pt + accent, inset: 1.4cm)[
    #block(width: 100%, height: 100%, stroke: 0.75pt + accent, inset: 1cm)[
      #align(center + horizon)[
        #text(13pt, weight: "semibold", fill: accent, tracking: 2pt)[#upper(data.program)]
        #v(18pt)
        #text(40pt, weight: "bold")[#c.award]
        #if c.place != "" [ \ #v(4pt) #text(22pt, weight: "semibold", fill: muted)[#c.place] ]
        #v(26pt)
        #text(14pt, fill: muted)[presented to]
        #v(8pt)
        #text(34pt, weight: "bold")[#c.team_name]
        \ #text(18pt)[Team #c.team_number]
        #v(26pt)
        #text(13pt)[#data.event.name · #data.event.dates]
      ]
    ]
  ]
]
