#show heading.where(level: 1): set text(size: 20pt)
#show heading.where(level: 2): set text(size: 16pt)
#show heading.where(level: 3): set text(size: 14pt)
#show heading.where(level: 4): set text(size: 11pt)

= Memory-dump PLC Analyse
== Algemeen beeld

Er zijn twee soorten PLC memory dumps aangeleverd: External RAM en On-chip RAM. Van elke soort dump zijn 7 bestanden aangeleverd. Elk bestand bevat de data uit het RAM-geheugen op dat moment. Het eerste bestand heeft als datum en tijdstip: 29-06-2023 14:35:09. Aan de datum en tijd in de bestandsnamen is te zien dat elke 15 minuten een memory dump wordt gemaakt.

Om de memory dumps te analyseren is eerst het eerst van belang om te weten welke data in dit geheugen aanwezig is, en hoe deze data gestructureerd wordt.

== Magic numbers

Elk bestandstype en protocol bevat een 'magic number'. Elk bestandstype heeft zijn eigen unieke magic number en is terug te vinden in de eerste aantal bytes van een bestand. Programma's kunnen aan de hand van deze magic numbers bestanden herkennen en categoriseren.#footnote[Purohit, 2026]

Met behulp van deze magic numbers kan bij een voorheen onbekend bestand worden vastgesteld welk bestandstype van toepassing is. Wanneer dit bekend is, kan vervolgens gerichter naar de inhoud van het bestand gekeken worden, om aanwijzingen te vinden.

Om deze magic numbers in de verschillende memory dumps te vinden is het programma `Binwalk` gebruikt in een Linux-terminal. Binwalk bevat een uitgebreide bibliotheek aan magic numbers en scant de dump-bestanden ernaar. Op deze manier kunnen mogelijk embedded bestanden uit de dumps worden gehaald.#footnote[devttys0, 2024]

In onderstaande afbeelding is het resultaat van Binwalk te zien nadat het programma de bestanden `ExtRAM_20230629143509`.bin' en `OnChipRAM_20230629143506.bin` heeft geanalyseerd op embedded bestanden. Het programma trof bij het ExtRAM bestand een embedded ziparchief aan. Het OnChipRAM bestand kwam zonder resultaat terug.

#figure(
  image("/assets/image-12.png"),
  caption: [Resultaat Binwalk scan op eerste ExtRAM en OnChipRAM bestanden.],
)

Na de vondst van het ziparchief is dezelfde scan uitgevoerd op de volgende twee dumps. In figuur 2 is te zien dat op dezelfde geheugenadressen wederom een ziparchief is aangetroffen.

#figure(
  image("/assets/image-13.png"),
  caption: [Resultaat Binwalk scan op tweede ExtRAM en OnChipRAM bestanden],
)

Wegens het gebrek aan aanwijzingen in de OnChipRAM dumps zijn vervolgens enkel de overige ExtRAM bestanden op chronologische volgorde geanalyseerd. In onderstaande afbeelding zijn de resultaten te zien, welke tevens zijn verwerkt in tabel 1.

#figure(
  image("/assets/image-14.png", width: 90%),
  caption: [Resultaten Binwalk scans overige ExtRAM bestanden.],
)


#figure(
  table(
  columns: 6,
  align: (center, left, center, center, center, center),
  [*\#*], [*Bestandsnaam*], [*Tijdstip*], [*Zip start*], [*Zip einde*], [*Zip grootte*],
  [1], [`ExtRAM_20230629143509`], [14:35:09], [0xD00B], [0xE8B2], [6311 bytes],
  [2], [`ExtRAM_20230629145014`], [14:50:14], [0xD00B], [0xE8B2], [6311 bytes],
  [3], [`ExtRAM_20230629150519`], [15:05:19], [0xD00B], [0xE8C5], [6330 bytes],
  [4], [`ExtRAM_20230629152024`], [15:20:24], [0xD00B], [0xE8C5], [6330 bytes],
  [5], [`ExtRAM_20230629153528`], [15:35:28], [0xD00B], [0xE8A0], [6293 bytes],
  [6], [`ExtRAM_20230629155033`], [15:50:33], [0xD00B], [0xE8B8], [6317 bytes],
  [7], [`ExtRAM_20230629160538`], [16:05:38], [0xD00B], [0xE8B8], [6317 bytes],
),
  caption: [Overzicht van gevonden ziparchieven per ExtRAM dump.],
)

Op basis van deze gegevens blijkt dat de startwaarde van het ziparchief in alle dumps hetzelfde is. Dit geeft aan dat de header van elke dump een vaste structuur heeft en niet is aangetast. Verder is te zien dat de eindoffset wel verandert. Zo valt op dat in dump 3, 5 en 6 de eindwaardes zijn veranderd ten opzichte van de vorige dump. Ook opmerkelijk is dat de totale grootte van de ziparchieven drie keer verandert. Dit betekent dus dat er in totaal 4 unieke versies van het ziparchief zijn.

In het onderzoek _Zubair et al. (2022)_ wordt beschreven dat er magic numbers in het external RAM van Schneider M221 PLC zijn aangetroffen die corresponderen met een ziparchief. Dit archief is geëxtraheerd en gedecomprimeerd naar een `XML-bestand`. De onderzoekers konden vaststellen dat dit `XML-bestand` de semantiek van de data-objecten beschrijft, welke in de besturingslogica worden gebruikt. Hiermee kan vervolgens de ladder-logica van het PLC-programma deels worden vastgesteld.

Als de verandering van de totale grootte van de ziparchieven wordt gecombineerd met de informatie uit het onderzoek kan geconstateerd worden dat de control logic van de PLC mogelijk is gewijzigd.
#pagebreak()

== Extraheren en decomprimeren van ziparchief uit memory dump

Om de eerdere constatering te valideren is het noodzakelijk dat de inhoud van het gevonden ziparchief ingezien kan worden. Hiervoor wordt eerst de zip-data gekopieerd naar een apart bestand met behulp van het volgende commando:

#block(
  fill: luma(240),
  inset: 8pt,
  radius: 4pt,
  ```
  dd if=<naam_dumpbestand> bs=1 skip=53259 of=<outputBestand>.zip
  ```,
)

_N.B. Het 'skip' argument zorgt ervoor dat dd pas data kopieert vanaf de waarde 53259. Dit is de startwaarde van het ziparchief (zie figuur 1)._

#figure(
  image("/assets/image-15.png"),
  caption: [Output dd commando.],
)
In het ziparchief bevindt zich een `entry`-bestand (fig. 5).

#figure(
  image("/assets/image-16.png"),
  caption: [Inhoud geëxtraheerd ziparchief ExtRAM dump 1.],
)

In het entry-bestand is metadata van het PLC-programma te zien (zie figuur 6). Met de namen van gebruikte I/O adressen kan worden vastgesteld welke fysieke sensoren en actuatoren zijn aangesloten. Ook is terug te zien welke interne toestandsvariabelen en counters worden gebruikt.

#figure(
  image("/assets/image-17.png", width: 80%),
  caption: [Deel van de inhoud entry bestand ExtRAM dump 1.],
)
#pagebreak()

== Vergelijking entry-bestanden

Nu er belangrijke data omtrent het functioneren van de PLC is aangetroffen in de memory dump en bekend is dat de inhoud van dit bestand meermaals is veranderd, zijn alle 7 entry-bestanden uit de ExtRAM-dumps geëxtraheerd en is de inhoud hiervan met elkaar vergeleken. Er zijn 4 unieke versies van het entry-bestand gevonden (zie onderstaande tabel).

#figure(
  table(
  columns: (auto, 2fr, auto, auto, auto, 2fr),
  align: (center, left, center, center, center, left),
  [*Versie*], [*Bestandsnaam*], [*Tijdstip*], [*Zip einde (hex)*], [*Zip grootte (bytes)*], [*Status*],
  [A], [entry1.xml / entry2.xml], [14:35 / 14:50], [0xE8B2], [6311], [Baseline (originele control logic)],
  [B], [entry3.xml / entry4.xml], [15:05 / 15:20], [0xE8C5], [6330], [Mogelijke aanval],
  [C], [entry5.xml], [15:35], [0xE8A0], [6293], [Deel sporen uitwissen],
  [D], [entry6.xml / entry7.xml], [15:50 / 16:05], [0xE8B8], [6317], [Meer sporen uitwissen. Uiteindelijk achtergebleven programma],
),
  caption: [Overzicht van unieke versies van het entry-bestand en bijbehorende status.],
)

_N.B. In het kader van leesbaarheid is een chronologische nummering toegevoegd aan de entry-files (1-7)._

In versie A zijn geen verdachte stukken code aangetroffen, dit wordt daarom gezien als het originele lift-programma dat op de PLC draaide, voordat het incident plaatsvond.

De andere versies bevatten wel aanpassingen ten opzichte van versie A, welke in de volgende sub-paragrafen zullen worden toegelicht.
=
=== Wijzigingen versie B

==== SAME_CALL → attaxk

Het memory bit `SAME_CALL` (Index 60) is vervangen door een comment 'attaxk' op index 35. Deze toegevoegde comment is verdacht, aangezien 'attaxk' erg lijkt op het woord 'attack', wat suggereert dat de control logic mogelijk kwaadwillig is gemanipuleerd.

#figure(
  table(
  columns: (auto, auto, auto, 1fr),
  align: (left),
  [], [*Bestand*], [*Regels*], [*Inhoud*],
  [*Voor*], [`entry1.xml`], [170-172], [`<Index>60</Index>`, `<Symbol>SAME_CALL</Symbol>`, `<Comment>SameFloorCall</Comment>`],
  [*Na*], [`entry3.xml`], [170-171], [`<Index>35</Index>`, `<Comment>attaxk</Comment>`],
),
  caption: [Wijziging memory bit SAME_CALL en toevoeging verdachte comment 'attaxk'.],
)

#pagebreak()

==== Timer0 aangepast

De duur van timer0 is van 10 seconden naar 5000 milliseconden (= 5 seconden) veranderd. Hoewel onduidelijk is waar deze timer voor wordt gebruikt, kan het aanzienlijke gevolgen hebben op de werking van de lift. Dit risico wordt groter als deze timer op meerdere plekken in het programma wordt gebruikt.

#figure(
table(
  columns: (auto, auto, auto, 1fr),
  align: (left),
  [], [*Bestand*], [*Regels*], [*Inhoud*],
  [*Voor*], [`entry1.xml`], [176-177], [`<Preset>10</Preset>`, `<Base>OneSecond</Base>`],
  [*Na*], [`entry3.xml`], [175-176], [`<Preset>5000</Preset>`, `<Base>OneMilliSeconds</Base>`],
),
  caption: [Wijziging duur van timer0.],
)

==== Toegevoegde timers

Timer2 en timer3 zijn toegevoegd en hebben een waarde toegewezen gekregen (zie tabel 5). Net als timer0 is het niet bekend waar en waarvoor deze timers gebruikt zijn, echter kan dit grote functionele gevolgen hebben.

#figure(
 table(
  columns: (auto, auto, 1fr),
  align: (left),
  [*Bestand*], [*Regels*], [*Inhoud*],
  [`entry3.xml`], [184-185, 188-190], [`<Index>2</Index>` `<Preset>30</Preset>` `<Index>3</Index>` `<Preset>7</Preset>` `<Base>OneSecond</Base>`],
),
  caption: [Toevoeging van timer2 en timer3.],
)

==== Rungs toegevoegd

In de verschillende Program Organization Unit's (POU) worden inputs, outputs en functies gecombineerd om code uit te kunnen voeren op een PLC.#footnote[Schneider Electronic India, 2013] Dit zijn dus cruciale onderdelen van de metadata. Verder zijn POU's opgebouwd uit 'Rungs', horizontale regels met links de inputs en rechts de outputs (acties). Deze regels worden van boven naar beneden uitgevoerd, zodat deze manier van programmeren 'Ladder Diagram' wordt genoemd.

In de entry-bestanden zijn de structuur en namen van de POU's terug te vinden onder de sectie `<Pous>`. Daarnaast zijn de verschillende programmablokken terug te zien, elk beginnend met de tag `<PouMetadata>`. De namen van deze blokken en de verschillende rungs zijn ook gedefinieerd. Ondanks het ontbreken van de daadwerkelijke logica, kan alsnog een redelijk beeld worden geschetst van de programmastructuur.

In versie B zijn er twee extra rungs bij POU "Third Called" ten opzichte van het originele programma. Hieruit kan geconcludeerd worden dat er extra logica is toegevoegd aan het programma van de lift.

#figure(
  table(
  columns: (auto, auto, auto, 1fr),
  align: (left),
  [], [*Bestand*], [*Regels*], [*Inhoud*],
  [*Voor*], [`entry1.xml`], [283-315], [POU "Third Called" bevat 5 rungs],
  [*Na*], [`entry3.xml`], [291-335], [POU "Third Called" bevat 7 rungs (2 toegevoegd op regels 324-335)],
),
  caption: [Toevoeging van 2 extra rungs in POU "Third Called".],
)

#pagebreak()
==== Gewijzigde projectnaam

Ten slotte is onderaan het metadata-bestand een wijziging opgetreden in de naam van het Machine Expert project. Deze is van "New Project" naar "SAFE Lab Mafia" aangepast.

#figure(
  table(
  columns: (auto, auto, auto, 1fr),
  align: (left),
  [], [*Bestand*], [*Regels*], [*Inhoud*],
  [*Voor*], [`entry1.xml`], [1384], [`<Name>New Project</Name>`],
  [*Na*], [`entry3.xml`], [1404], [`<Name>SAFE Lab Mafia</Name>`],
),
  caption: [Wijziging projectnaam van 'New Project' naar 'SAFE Lab Mafia'.],
)
=
=== Wijzigingen versie C

In versie C worden de eerder gemaakte wijzigingen uit versie B deels teruggedraaid, waarschijnlijk om sporen uit te wissen na een uitgevoerde aanval.

==== Comment 'attaxk' verwijderd

Geconstateerd is dat de eerder geplaatste comment met de tekst 'attaxk' is verwijderd.

#figure(
 table(
  columns: (auto, auto, auto, 1fr),
  align: (left),
  [], [*Bestand*], [*Regels*], [*Inhoud*],
  [*Voor*], [`entry3.xml`], [169-172], [`<Index>35</Index>`, `<Comment>attaxk</Comment>`],
  [*Na*], [`entry5.xml`], [168-169], [attaxk memory bit verwijderd, geen SAME_CALL memory bit teruggeplaatst.],
),
  caption: [Verwijdering comment 'attaxk' en het bijbehorende memory bit.],
)

==== Extra timers verwijderd

Ook is waargenomen dat de 2 extra toegevoegde timers uit de programmacode zijn verwijderd.

#figure(
 table(
  columns: (auto, auto, auto, 1fr),
  align: (left),
  [], [*Bestand*], [*Regels*], [*Inhoud*],
  [*Voor*], [`entry3.xml`], [183-191], [Timer index 2 (preset 30 ms) en Timer index 3 (preset 7 seconden)],
  [*Na*], [`entry5.xml`], [178-179], [Timer index 2 en Timer index 3 verwijderd],
),
  caption: [Verwijdering van de eerder toegevoegde timers.],
)

==== Extra rungs verwijderd

Ten slotte zijn de POU's ook weer gewijzigd naar de originele structuur doordat de extra rungs zijn verwijderd.

#figure(
  table(
  columns: (auto, auto, auto, 1fr),
  align: (left),
  [], [*Bestand*], [*Regels*], [*Inhoud*],
  [*Voor*], [`entry3.xml`], [291-335], [2 extra rungs in POU "Third Called"],
  [*Na*], [`entry5.xml`], [278-310], [Rungs verwijderd - POU "Third Called" terug naar 5 rungs],
),
  caption: [Verwijdering van de eerder toegevoegde rungs in POU "Third Called".],
)

_N.B. Niet alle wijzigingen uit versie B zijn ongedaan gemaakt: de duur van timer0 is nog altijd 5 seconden, het SAME_CALL memory-bit is niet teruggeplaatst, en de naam van het project is nog altijd 'SAFE Lab Mafia' in plaats van 'New Project'._

#pagebreak()
=== Wijzigingen versie D

In deze laatste versie is een extra poging gedaan om meer wijzigingen (uit versie B) ongedaan te maken.

==== Terugplaatsing 'SAME_CALL' memory-bit

In versie B werd het memory-bit op index 35 met symbool 'SAME_CALL' gewijzigd naar index 60 en bevatte dit nieuwe memory-bit enkel de comment 'attaxk'. In versie C is dit memory-bit verwijderd, maar zijn de aanvallers vergeten om het oorspronkelijke index 60 bit terug te plaatsen. In versie D is dit alsnog gedaan (zie tabel 11).

#figure(
  table(
  columns: (auto, auto, auto, 1fr),
  align: (left),
  [], [*Bestand*], [*Regels*], [*Inhoud*],
  [*Voor*], [`entry5.xml`], [168-172], [geen SAME_CALL memory bit aanwezig],
  [*Na*], [`entry6.xml`], [169-173], [`<Index>60</Index>`, `<Symbol>SAME_CALL</Symbol>`, `<Comment>SameFloorCall</Comment>`],
),
  caption: [Terugplaatsing van het SAME_CALL memory bit.],
)

Als het achtergebleven programma uit versie D wordt vergeleken met het oorspronkelijke programma, zijn alle sporen van de aanval verwijderd. Het enige dat de aanvallers zijn vergeten terug te draaien, is de naam van het project. Dit is nog altijd 'SAFE Lab Mafia'.

==== Duur timer0 terug veranderd

De oorspronkelijke duur van timer0 was 10 seconden. In versie B werd dit aangepast naar 5 seconden. Hoewel dit in versie C niet gecorrigeerd werd, is dit nu wel het geval (zie tabel 12).

#figure(
  table(
  columns: (auto, auto, auto, 1fr),
  align: (left),
  [], [*Bestand*], [*Regels*], [*Inhoud*],
  [*Voor*], [`entry5.xml`], [175-176], [`<Preset>5000</Preset>`, `<Base>OneMilliSeconds</Base>`],
  [*Na*], [`entry6.xml`], [176-177], [`<Preset>10</Preset>`, `<Base>OneSecond</Base>`],
),
  caption: [Duur van timer0 terug veranderd naar originele duur.],
)

#pagebreak()
== Analyse inhoud OnChipRAM

Om mogelijk relevante data uit de OnChipRAM-bestanden te halen, zijn de eerste twee dumps in hex-editor `HxD` geladen (zie figuur 7). Dit programma vertaalt de ruwe bytes naar ASCII-karakters. Hierdoor kan bekeken worden of er strings tekst aanwezig zijn die informatie bevatten.

#figure(
  image("/assets/image-18.png"),
)
#align(left)[_Figuur 7: Deel inhoud tweede OnChipRAM bestand in HxD._]

Nadat hier meerdere strings in te zien waren - bijvoorbeeld `DESKTOP-RSRBUGJ`, `New Project`, `192.168.10.45` - is het Linux commando `strings` gebruikt om alle strings uit een dump te detecteren en weer te geven:

#block(
  fill: luma(240),
  inset: 8pt,
  radius: 4pt,
  ```
  strings -n 6 <naam_dumpbestand>
  ```,
)

Dit resulteerde in een lijst van strings, waarvan een groot deel nuttige informatie bevatte, zoals de naam van het project, het IP- en MAC-adres, de firmware-versie en het modelnummer van de PLC.

Vanaf dump 2 is het aantal gevonden strings aanzienlijk groter, en zijn ook domeinen en Windows PC-gebruikersnamen terug te lezen (zie figuur 8). Dit kan betekenen dat de PLC door iemand is benaderd.

In het strings-resultaat van dump 3 valt in het bijzonder op dat de projectnaam van `New Project` is veranderd naar `SAFE Lab Mafia` (zie figuur 9). Dit komt overeen met de eerdere bevindingen uit de ExtRAM-dumps. De nieuw gevonden domeinen en Windows-gebruikers en de aanwijzing dat de PLC via het netwerk is benaderd en er vervolgens wijzigingen zijn aangebracht, kan worden gebruikt bij het onderzoeken van de netwerkcapture.

#grid(
  columns: 2,
  gutter: 10pt,
  figure(
    image("/assets/image-19.png", width: 89%),
    caption: [Deel output `strings` command voor dump 2],
  ),
  figure(
    image("/assets/image-20.png"),
    caption: [Meer output.],
  ),
)
=
#figure(
  image("/assets/image-21.png"),
  caption: [Aanwezigheid `SAFE Lab Mafia` in dump 3.],
)

#pagebreak()
== Conclusie

Op basis van de bevindingen kan met grote mate van zekerheid worden geconcludeerd dat er een gerichte aanval op het PLC-programma van de lift heeft plaatsgevonden.

De toevoeging van de comment 'attaxk' - een nauwelijks verhulde verwijzing naar het woord 'attack' - wijst onmiskenbaar op een opzettelijke kwaadaardige ingreep in de control logic. Het opeenvolgende patroon van wijzigingen in versies B, C en D toont een aanval gevolgd door twee fasen van systematische sporenverwijdering, wat kenmerkend is voor doelbewust handelen. Kritieke programmaonderdelen zijn gemanipuleerd: de gewijzigde timer0-instelling (van 10 naar 5 seconden), de toevoeging van ongekende timers en de extra ladder-logica in POU "Third Called" kunnen directe gevolgen hebben gehad voor het gedrag van de lift. Het vergeten terugdraaien van de projectnaam "SAFE Lab Mafia" vormt een onweerlegbaar resterend spoor van de aanval.

De analyse van de OnChipRAM-dumps versterkt deze conclusie en geeft aanvullende aanwijzingen over de herkomst van de aanval. Uit de OnChipRAM-dumps zijn via ASCII-analyse en het strings-commando meerdere forensisch relevante gegevens geëxtraheerd, waaronder de projectnaam, het IP-adres, het MAC-adres, de firmware-versie en het modelnummer van de PLC. Het feit dat de projectnaam 'SAFE Lab Mafia' ook in de OnChipRAM-dumps vanaf dump 3 zichtbaar is, bevestigt de bevindingen uit de ExtRAM-analyse en toont aan dat de wijziging actief in het geheugen van de PLC aanwezig was.

Opvallend is dat vanaf dump 2 het aantal gevonden strings aanzienlijk toeneemt en dat er domeinnamen en Windows-gebruikersnamen zichtbaar zijn. Dit wijst erop dat de PLC in de periode voorafgaand aan de aanval via het netwerk is benaderd. Deze gegevens kunnen met vervolgonderzoek op de netwerkcapture toegepast worden, zodat de identiteit en het exacte tijdstip van de toegang mogelijk verder kunnen worden vastgesteld.

== Beoordeling PLC memorydump analyse McElevatorFace

Het onderzoeksteam van McElevatorFace is het onderzoek met een systematische basisaanpak gestart. Binwalk is ingezet voor het detecteren van embedded bestanden in de ExtRAM-dumps, er is een differentiële analyse uitgevoerd op de ziparchieven, en de bevindingen zijn gekoppeld aan de netwerkdata. Dit zijn goede stappen geweest in het zoeken naar de oorzaak van het incident.

Hoewel McElevatorFace gedeeltelijk dezelfde aanpak heeft gekozen om de dumps te analyseren, zijn veel stappen kort (of niet) beschreven. Daarnaast wordt vermeld dat "delen zijn verwijderd, vervangen en aangepast". Niet alle relevante wijzigingen worden concreet beschreven, terwijl deze cruciale bevindingen vormen. Zo missen de manipulatie van timer0, de toevoeging van timer2 en timer3, de toevoeging van extra rungs in een POU én de verwijdering en het latere herstel van het SAME_CALL memory bit.

Er wordt tevens geen feitelijke toelichting gegeven hoe de aanname - dat er mogelijk wijzigingen via het netwerk zijn uitgevoerd - tot stand is gekomen. Zo zijn de Windows-gebruikersnamen en domeinen niet gevonden.

De conclusie van McElevatorFace - dat er niet met absolute zekerheid valt te zeggen of er sprake is geweest van kwaadwillige manipulatie, wat de storing veroorzaakt heeft - is op basis van de aangetroffen wijzigingen te voorzichtig. De 'attaxk' comment, de gemanipuleerde timerwaarden, de extra POU-logica en het patroon van doelbewuste sporenverwijdering duidden op een aanmerkelijk sterkere conclusie: er heeft zeer waarschijnlijk een gerichte aanval op de PLC van de lift plaatsgevonden.