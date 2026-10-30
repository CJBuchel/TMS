// One large sign per page, for a competition table or a judging pod.
#import "common.typ": *
#show: setup.with(data.title, flipped: true, header: false)

#for (i, sign) in data.signs.enumerate() [
  #if i > 0 { pagebreak() }
  #align(center + horizon)[
    #text(16pt, fill: muted)[#data.event.name]
    #v(10pt)
    #text(120pt, weight: "bold")[#sign.title]
    #if sign.subtitle != "" [ \ #text(28pt, fill: muted)[#sign.subtitle] ]
  ]
]
