#set document(
  title: [Lifty - Eindrapportage],
  author: "Liam van den Berg, Thijs van der Zwan, Jim van Dijk"
)

#set text(
  lang: "nl"
)


#title()

#pagebreak()

#set page(header: [
  Lifty - Eindrapportage
])

#outline()

#pagebreak()
#set page(
  numbering: "1",
  number-align: right
)
#counter(page).update(1)

#include "inleiding.typ"
#pagebreak()

#include "hypothesescenario.typ"
#pagebreak()
#include "onderzoeksvragen.typ"
#pagebreak()
#include "experimenten.typ"
#pagebreak()
#include "pcap.typ"
#pagebreak()
#include "memorydump_plc.typ"
#pagebreak()
#include "desktopdump.typ"
#pagebreak()
#include "conclusie.typ"
#pagebreak()
#set heading(numbering: "A.")

= Bijlage: script
= Bijlage: entry's uit de PCAP-analyse

#pagebreak()
#bibliography("bronnen.bib", style: "apa")