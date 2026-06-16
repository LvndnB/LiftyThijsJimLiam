= Analyse van de Netwerk capture

De volgende deelvragen uit het Plan van Aanpak zijn leidend voor dit hoofdstuk:

//NOG LINKEN AAN DE DEELVRAGEN
- *DV1:* Welke communicatie in de PCAP wijkt af van normaal verwacht netwerkverkeer richting de PLC?
- *DV2:* Welke sporen in de PCAP duiden op ongeautoriseerde toegang tot of manipulatie van de PLC via het netwerk?
- *DV7:* In hoeverre zijn de bevindingen uit het rapport van MCElevatorface reproduceerbaar aan de hand van onafhankelijke analyse met dezelfde bewijsstukken?

Deze deelvragen worden beantwoord aan de hand van de volgende onderzoeksvragen, die in de analyse verder worden uitgewerkt:

- Welke hosts communiceren met de PLC en welke verbinding is afwijkend?
- Welke UMAS-functiecodes zijn ingezet door de verdachte host en wat beschrijven deze?
- Welke gegevens zijn via het netwerk naar de PLC overgedragen en hoe zijn deze te reconstrueren?
- Wat is de inhoud van de overgedragen bestanden en welke wijzigingen zijn daarin aangebracht?
- Zijn er aanwijzingen voor andere aanvalstechnieken in het netwerkverkeer?

Als bewijsstuk is een netwerk dump aangeleverd: het bestand `142728_162728.pcapng`. Dit bestand bevat al het netwerkverkeer dat is vastgelegd op het netwerk van de bank, waaraan ook de PLC van de lift is gekoppeld. De bestandsnaam suggereert een opname van 14:27:28 tot 16:27:28, maar de tijdstempels in de pcap zelf tonen een starttijd van 20:27:28 op 29 juni 2023. Het verschil van zes uur wijst op een tijdzoneverschil tussen het opname-apparaat en de weergave in Wireshark; de tijdstempels zoals zichtbaar in Wireshark zijn leidend in dit onderzoek. Het bestand is omgezet naar het `.pcap`-formaat zodat het ingeladen kan worden in aanvullende analyse-omgevingen.

#grid(
  columns: 2,
  gutter: 10pt,
  align: center,
  image("/assets/image-2.png"),
  image("/assets/image-3.png")
)

Voor de analyse zijn twee tools ingezet: Wireshark en NetworkMiner. Wireshark is gebruikt als primaire tool voor het inspecteren van individuele pakketten, het toepassen van displayfilters en het volgen van TCP-streams. NetworkMiner is ingezet voor een eerste screening op afwijkingen in het netwerk. Daarnaast is een zelf geschreven Python-script (`extract_zips.py`) gebruikt om ZIP-archieven te extraheren vanuit de TCP-streams.

// referentie!!!
MCElevatorface voerde de analyse primair uit in Wireshark en gebruikte daarnaast een script van een groepslid om tijdstempeldata te verwerken in Excel. In dit onderzoek is voor het decoderen van Modbus/UMAS-verkeer een aangepaste Wireshark-plugin gebruikt, uitleg hierover is te vinden in..... De plugin labelt UMAS-verkeer op TCP-poort 502 en maakt gefilterde analyse van specifieke UMAS-functies mogelijk. NetworkMiner is als aanvullende stap ingezet voor de eerste detectie van afwijkingen, voordat de diepere Wireshark-analyse plaatsvond.

#pagebreak()
== Netwerktopologie en identificatie van betrokken hosts
_Onderzoeksvraag: Welke hosts communiceren met de PLC en welke verbinding is afwijkend?_



== Netwerktopologie en identificatie van betrokken hosts

_Subonderzoeksvraag: Welke hosts communiceren met de PLC en welke verbinding is afwijkend?_

=== Identificatie via NetworkMiner

Het pcap-bestand is ingeladen in NetworkMiner 1.6.1. Via het tabblad _Hosts_, gesorteerd op verzonden pakketten (aflopend), zijn 58 hosts geïdentificeerd op het netwerk. De bovenaan verschijnende hosts hebben de meeste activiteit vertoond. Uit dit overzicht zijn de volgende voor dit onderzoek relevante hosts vastgesteld:

- `192.168.10.45` — PLC (geen OS-label; herkend als industrieel apparaat)
- `192.168.10.164` — `DESKTOP-RSRBUGJ` (Windows) — werkstation Employee-01

Daarnaast zijn onder meer `192.168.10.121` (Ubuntu/Linux), `192.168.10.130` (`EGR-AHMED-08`, Windows), `192.168.10.110` en `192.168.10.242` zichtbaar, maar deze zijn niet primair betrokken bij de verdachte activiteit.

#image("/assets/image-4.png")

In het tabblad _Anomalies_ is daarnaast een mogelijke ARP-spoofing-aanval gedetecteerd gericht op `192.168.10.101`. Dit wordt verderop in dit hoofdstuk verder toegelicht.

=== Identificatie via Wireshark Conversations
Via _Statistics → Conversations → IPv4_ is het netwerkverkeer gesorteerd op volume. Hieruit blijkt dat de meest opvallende datatransactie plaatsvond tussen `192.168.10.164` (DESKTOP-RSRBUGJ, Employee-01) en `192.168.10.45` (PLC). Deze verbinding is verdacht omdat een gewone medewerker geen functionele reden heeft om directe Modbus/TCP-communicatie te voeren met de PLC. MCElevatorface identificeerde dezelfde verbinding als meest verdacht.

#image("/assets/image-6.png")

== Analyse van het Modbus/UMAS-verkeer
_Onderzoeksvraag: Welke UMAS-functiecodes zijn ingezet door de verdachte host en wat beschrijven deze?_

=== Toepassen van het displayfilter

Om de analyse te focussen op het relevante verkeer is het volgende Wireshark-displayfilter toegepast:

```
ip.src == 192.168.10.164 && modbus && !(modbus.func_code == 254) && !(modbus.func_code == 36)
```

Dit filter toont uitsluitend het uitgaande Modbus-verkeer van Employee-01. De uitgesloten codes zijn decimaal 254 (0xFE – standaard response-bevestiging) en decimaal 36 (0x24 – READ\_COILS\_REGISTERS, reguliere polling). Wat overblijft zijn de relevante UMAS-interacties.

#image("/assets/image-7.png")

=== Geïdentificeerde functiecodes
Op basis van de gefilterde pakketlijst en de UMAS Wireshark-plugin zijn de volgende functiecodes aangetroffen in de sessies van Employee-01. De codes worden hier weergegeven als decimale waarde en de hexadecimale waarde(0x-notatie):
- *1 (0x01) – INIT\_COMM*
- *3 (0x03) – READ\_PROJECT\_INFO*
- *16 (0x10) – TAKE\_PLC\_RESERVATION*
- *17 (0x11) – RELEASE\_PLC\_RESERVATION*
- *40 (0x28) – UPLOAD*
- *41 (0x29) – DOWNLOAD 1*
- *64 (0x40) – START\_PLC*
- *65 (0x41) – STOP\_PLC*
- *109 (0x6D) – DOWNLOAD 2*
- *114 (0x72) – UPLOAD 2*

*Vergelijking met MCElevatorface:* MCElevatorface identificeerde dezelfde reeks handelingen. In hun rapport worden de functiecodes uitgedrukt in hexadecimaal zonder 0x-prefix (bijv. "functie code 10" voor wat hier 0x10 = decimaal 16 is, en "functie code 41" voor wat hier 0x41 = decimaal 65 is). Dit kan verwarring opleveren bij directe vergelijking. Wat MCElevatorface "functie code 29 (WRITE\_AND\_READ\_REGISTER)" noemt, correspondeert met 0x29 = decimaal 41, hier gelabeld als SEND 1 DOWNLOAD. De functienaam verschilt maar de functie is gelijk: data schrijven naar de PLC.

== File carving: extractie van ZIP-archieven uit TCP-streams
_Subonderzoeksvraag: Welke gegevens zijn via het netwerk naar de PLC overgedragen en hoe zijn deze te reconstrueren?_

=== Identificatie van de downloadstreams
Met behulp van het UMAS-filter `UMAS.Umas_Functions_Code == 41` zijn de vier momenten geïdentificeerd waarop Employee-01 data naar de PLC stuurt. In dit filter is 41 de *decimale* waarde, overeenkomend met 0x29 (SEND 1 DOWNLOAD). De bijbehorende TCP-streams starten bij de volgende pakketnummers:

#table(
  columns: (auto, auto, auto),
  [*Stream*], [*Startpakket*], [*Tijdstip (29-06-2023)*],
  [1], [186], [20:27:51],
  [2], [47116], [21:00:24],
  [3], [86200], [21:24:59],
  [4], [115961], [21:46:48],
)
//SCRIPT IN BIJLAGE
Per stream is via _Follow → TCP Stream_ de ruwe binaire data geëxporteerd als `.bin`-bestand. Elk UMAS-frame in de stream heeft de volgende structuur, zoals beschreven door Liras en la Red #cite(<lirasenlared2017>):
```
[ TCP Packet ] - [ Modbus Header ] - [5A] - [ UMAS CODE (16 bit) ] - [ UMAS PAYLOAD (Variable) ]
```
De byte `5A` (decimaal 90) markeert het begin van het UMAS-gedeelte; de Wireshark-plugin gebruikt dit als herkenningspunt. De UMAS-payload heeft een variabele lengte en bevat naast de ZIP ook de gecompileerde applicatiecode en configuratiedata. Het extractiescript slaat per frame de eerste 16 bytes (Modbus MBAP-header inclusief UMAS-prefix) over en verzamelt uitsluitend de payloadbytes. Binnen de aaneengesloten payload zoekt het script vervolgens naar de ZIP-bestandssignatuur `50 4B 03 04` (PKWARE Local File Header) als startpunt en `50 4B 05 06` (End of Central Directory) als eindpunt. De data vóór en na de ZIP bestaat uit de binaire applicatiecode en configuratieblokken; deze zijn niet verder geanalyseerd omdat ze geen leesbare structuur hebben zonder de bijbehorende Schneider compiler of een geschikte disassembler.

#image("/assets/image-8.png")
#image("/assets/image-9.png")

MCElevatorface constateerde via de PLC-memorydump dat er een ZIP-bestand in het geheugen aanwezig was en traceerde dit terug naar het netwerkverkeer bij pakket 46884. In dit onderzoek zijn alle vier de downloadstreams systematisch geëxtraheerd als volledige, werkende ZIP-archieven, waardoor een directe versievergelijking van het PLC-programma per uploadsessie mogelijk is.

=== Inhoud van de geëxtraheerde ZIP-bestanden
_Onderzoeksvraag: Wat is de inhoud van de overgedragen bestanden en welke wijzigingen zijn daarin aangebracht?_

