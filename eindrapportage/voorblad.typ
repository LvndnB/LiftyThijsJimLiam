#let title() = {
  set page(numbering: none)
  set align(center)

  v(2fr)

  text(size: 28pt, weight: "bold")[Lifty - Eindrapportage]

  v(0.5em)

  text(size: 18pt)[Validatie van Groep McElevatorface]

  v(0.3em)

  text(size: 14pt, style: "italic")[The Troubled Elevator -- DFRWS 2023 Challenge]

  v(2fr)

  line(length: 60%)

  v(1em)

  grid(
    columns: (auto, auto),
    column-gutter: 2em,
    row-gutter: 0.5em,
    align: (right, left),
    text(weight: "bold")[Auteurs:],   [Liam van den Berg],
    [],                                [Thijs van der Zwan],
    [],                                [Jim van Dijk],
    v(0.5em), v(0.5em),
    text(weight: "bold")[Minor:],     [Digital Forensics],
    text(weight: "bold")[Instelling:], [Hogeschool Leiden],
    text(weight: "bold")[Datum:],     [21 juni 2026],
  )

  v(2fr)
}
