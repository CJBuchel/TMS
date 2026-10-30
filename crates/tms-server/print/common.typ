// Shared look for every printable: Inter, a header with the event and the document's title, and page numbers.

#let ink = rgb("#111827")
#let muted = rgb("#6b7280")
#let rule = rgb("#d1d5db")
#let accent = rgb("#0f766e")

#let data = json(bytes(sys.inputs.data))

#let setup(title, flipped: false, header: true, body) = {
  set page(
    paper: "a4",
    flipped: flipped,
    margin: (x: 1.6cm, y: 1.8cm),
    header: if header {
      text(8.5pt, fill: muted)[#data.event.name · #data.event.code #h(1fr) #title]
    },
    footer: if header {
      text(8pt, fill: muted)[Printed #data.printed #h(1fr) #context counter(page).display("1 of 1", both: true)]
    },
  )
  set text(font: "Inter", size: 10pt, fill: ink, features: ("tnum",))
  set table(stroke: 0.5pt + rule, inset: (x: 6pt, y: 5pt))
  show table.cell.where(y: 0): set text(weight: "semibold")
  body
}

/// A table with a header row; `rows` is a list of row arrays.
#let grid-table(columns, header, rows) = table(
  columns: columns,
  fill: (_, y) => if y == 0 { rgb("#f3f4f6") },
  table.header(..header),
  ..rows.flatten(),
)
