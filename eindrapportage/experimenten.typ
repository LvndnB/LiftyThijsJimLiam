= Experimenten
== Onderzoeksopzet en gebruikte tools

De experimenten zijn uitgevoerd in een afgeschermd testnetwerk met een Schneider Modicon M221 PLC en een laptop met EcoStruxure Machine Expert - Basic. Beide apparaten bevonden zich in hetzelfde subnet: de laptop op `192.168.243.110` en de PLC op `192.168.243.190`. De onderzoeksomgevingen zijn uitgebreider beschreven in het portfolio bestand "Onderzoeksomgevingen". Voor elk experiment is dezelfde werkwijze aangehouden: in Wireshark werd een live capture gestart, vervolgens werd in Machine Expert (of via de fysieke knoppen) de te onderzoeken handeling uitgevoerd, en daarna werd de capture gestopt en als afzonderlijk `.pcapng`-bestand opgeslagen. Deze opnamen zijn als bijlage in het portfolio opgenomen.

Voor het decoderen van het UMAS-verkeer is gebruikgemaakt van een aangepaste Wireshark-plugin, gebaseerd op het open-source project van biero-el-corridor #cite(<bierocorridor_umasplugin>). Met deze plugin worden de UMAS-functiecodes rechtstreeks in de Wireshark-pakketweergave zichtbaar als een afzonderlijke UMAS-laag. Hierdoor kon het verkeer direct in Wireshark worden uitgelezen en gefilterd, zonder dat de pcap eerst naar Excel hoefde te worden geëxporteerd. MCElevatorface gebruikte voor hun analyse wel een exportstap: zij verwerkten de pakketdata via een zelfgeschreven script in een Excel-bestand.

== De aangepaste Wireshark-plugin <plugin>

De originele plugin van biero-el-corridor is geschreven voor de Schneider Modicon M340. Bij het toepassen op het verkeer van de Modicon M221 bleek dat enkele functiecodes niet overeenkwamen. Met behulp van onderstaande experimenten is de plugin aangepast en zijn enkele belangrijke functie codes gecorrigeerd.

De plugin herkent UMAS-verkeer aan de byte `0x5A` op offset 7 van de Modbus-PDU, de UMAS-functiecode staat op offset 9. Naast de correctie van de start/stop-codes zijn in de aangepaste plugin per functiecode commentaarregels toegevoegd die vastleggen in welk experiment en bij welk pakketnummer de betreffende code is geverifieerd. De volledige aangepaste plugin (`modbus-umas-schneider.lua`) is als bijlage opgenomen: #ref(<appendixA>).

== Experiment 1 - In- en uitloggen op de PLC (TP001)
_PCAP: `login and logout PLC.pcapng`_

Dit experiment hoort bij hypothese 3 en scenario 3: inloggen is de voorwaarde voor manipulatie op afstand, omdat een client pas na het claimen van de PLC wijzigingen kan wegschrijven. Het sluit aan op de in het Plan van Aanpak benoemde validatie van functiecode 10 (TAKE\_PLC\_RESERVATION). Vanaf de PC is een sessie geopend en weer afgesloten: de opname begint met `INIT_COMM`, waarna de PC het eigenaarschap claimt met `TAKE_PLC_RESERVATION` (`0x10`, No. 14) en dit bij het uitloggen weer vrijgeeft met `RELEASE_PLC_RESERVATION` (`0x11`, No. 159). Beide handelingen zijn daarmee herkenbaar in het netwerk.

#figure(
  table(
    columns: (auto, auto, auto, auto),
    [*Functiecode*], [*Decimaal*], [*Pakket*], [*Betekenis*],
    [`0x01`], [1], [No. 10], [INIT\_COMM – initialiseren van een UMAS-communicatie],
    [`0x10`], [16], [No. 14], [TAKE\_PLC\_RESERVATION – PLC claimen (inloggen)],
    [`0x11`], [17], [No. 159], [RELEASE\_PLC\_RESERVATION – reservering vrijgeven (uitloggen)],
  ),
  caption: [UMAS-functiecodes bij in- en uitloggen (TP001).],
)

#figure(
  image("/assets/image-11.png"),
  caption: [Wireshark-opname van het in- en uitloggen op de PLC (`0x10` en `0x11`).],
)

== Experiment 2 - Starten en stoppen van de PLC (TP002)
 
_PCAP: `start and stop PLC.pcapng`_
 
Dit experiment hoort bij hypothese 3 en de scenario's 3 en 8. Een op de PLC aanwezig programma is gestart en gestopt. Bij het starten is op pakket No. 26 functiecode `0x40` (decimaal 64) aangetroffen en bij het stoppen op No. 135 functiecode `0x41` (decimaal 65); het eindoordeel in TP002 is geslaagd. Deze waarden bevestigen tevens dat de oorspronkelijke plugin-koppeling (decimaal 58/59) onjuist was en vormden de aanleiding voor de correctie. Doordat start en stop expliciete netwerkcommando's blijken, wordt een spontane technische- of firmwarefout zonder menselijke invloed als verklaring minder waarschijnlijk.
 
#figure(
  table(
    columns: (auto, auto, auto, auto),
    [*Functiecode*], [*Decimaal*], [*Pakket*], [*Betekenis*],
    [`0x40`], [64], [No. 26], [START\_PLC – het programma op de PLC starten],
    [`0x41`], [65], [No. 135], [STOP\_PLC – het programma op de PLC stoppen],
  ),
  caption: [UMAS-functiecodes bij het starten en stoppen van de PLC (TP002).],
)
 
#figure(
  image("/assets/image-22.png"),
  caption: [Wireshark-opname van het starten en stoppen van de PLC (`0x40` en `0x41`).],
)

== Experiment 3 - Gewijzigd programma naar de PLC sturen (SEND) (TP003)

_PCAP: `send (ingelogd en in programmering tab, na het bewerken van programma).pcapng`_

Dit experiment hoort bij hypothese 3 en de scenario's 3 en 9 en sluit aan op het in het Plan van Aanpak benoemde experiment "aanpassing maken aan het programma". In Machine Expert is een kleine wijziging aangebracht (ingang `I0.0` naar `I0.2`) en via SEND naar de draaiende PLC geschreven. In de opname staan twee schrijf-functiecodes: `0x6d` (SEND 2 DOWNLOAD) op No. 33 en `0x29` (SEND 1 DOWNLOAD) op No. 35, zonder start/stop-commando. Het is dus aantoonbaar mogelijk een draaiend PLC-programma over het netwerk te overschrijven.

#figure(
  table(
    columns: (auto, auto, auto, auto),
    [*Functiecode*], [*Decimaal*], [*Pakket*], [*Betekenis*],
    [`0x6d`], [109], [No. 33], [SEND 2 DOWNLOAD – data naar de PLC schrijven (PC → PLC)],
    [`0x29`], [41], [No. 35], [SEND 1 DOWNLOAD – data naar de PLC schrijven (PC → PLC)],
  ),
  caption: [UMAS-functiecodes bij het sturen van een wijziging via SEND (TP003).],
)

#figure(
  image("/assets/image-23.png"),
  caption: [Wireshark-opname van de SEND-handeling naar de PLC (`0x6d` en `0x29`).],
)

== Experiment 4 - Project van PC naar PLC sturen (download) (TP004)

_PCAP: `PC to Controller (download).pcapng`_

Dit experiment hoort bij hypothese 3 en scenario 3. Een volledig Machine Expert-project is vanaf de PC naar de PLC gestuurd (download); op pakket No. 42 is functiecode `0x36` (DOWNLOAD 1) aangetroffen. Waar SEND een wijziging in een draaiend programma wegschrijft, hoort `0x36` bij het overdragen van een compleet, en dus mogelijk gemanipuleerd, project naar de PLC.

#figure(
  table(
    columns: (auto, auto, auto, auto),
    [*Functiecode*], [*Decimaal*], [*Pakket*], [*Betekenis*],
    [`0x36`], [54], [No. 42], [DOWNLOAD 1 – volledig project van PC naar PLC (PC → PLC)],
  ),
  caption: [UMAS-functiecodes bij het sturen van een project via DOWNLOAD (TP004).],
)

#figure(
  image("/assets/image-24.png"),
  caption: [Wireshark-opname van de download naar de PLC (`0x36`).],
)


== Experiment 5 - Programma van PLC naar PC kopiëren (upload) (TP005)

_PCAP: `Controller to PC (upload).pcapng`_

Dit experiment hoort bij hypothese 3 en de scenario's 3 en 9. Het actieve programma is vanaf de PLC naar de PC gekopieerd (upload). Daarbij zijn twee functiecodes aangetroffen: `0x28` (UPLOAD) op No. 59 en `0x72` (UPLOAD 2) op No. 192, beide in de richting PLC → PC. Hiermee is het op de PLC aanwezige programma via het netwerk uitleesbaar.

#pagebreak()

#figure(
  table(
    columns: (auto, auto, auto, auto),
    [*Functiecode*], [*Decimaal*], [*Pakket*], [*Betekenis*],
    [`0x28`], [40], [No. 59], [UPLOAD – programma van PLC naar PC (PLC → PC)],
    [`0x72`], [114], [No. 192], [UPLOAD 2 – vervolg van de upload (PLC → PC)],
  ),
  caption: [UMAS-functiecodes bij het uploaden van het programma van de PLC (TP005).],
)

#figure(
  image("/assets/image-25.png"),
  caption: [Wireshark-opname van de upload van de PLC (`0x28` en `0x72`).],
)

== Experiment 6 - Knop aan lamp op de PLC (TP006)

Dit experiment hoort bij de hypotheses 1 en 2 en de scenario's 1, 4 en 7. Op de PLC is een programma geplaatst waarin een fysieke drukknop (ingang `I0.0`) een lamp (uitgang `Q0.0`) aanstuurt; daarna is de PLC in RUN gezet en is tijdens een Wireshark-opname de knop ingedrukt.

In het netwerkverkeer is géén statuswijziging van de output zichtbaar en zijn geen UMAS-functiecodes aan de knopdruk te koppelen. De knop-naar-lamp-logica wordt volledig lokaal door de PLC afgehandeld, zonder communicatie met de PC, waardoor deze handeling geen netwerkverkeer genereert. Het experiment is daarmee niet geslaagd en de hypothese verworpen.

Dit is juist een waardevolle bevinding voor de koppeling aan het Plan van Aanpak: omdat fysieke bediening en lokale programmalogica geen sporen in het netwerk achterlaten, kunnen de oorzaken die buiten het netwerk liggen - een door een knopvolgorde getriggerde programmabug (hypothese 1, scenario 1), fysieke of menselijke bediening (hypothese 2, scenario 7) en fysieke manipulatie van knoppen of bekabeling (scenario 4) - niet via de casus-pcap worden aangetoond of uitgesloten. Voor die hypotheses en scenario's is ander bewijsmateriaal nodig, zoals de PLC-memorydump en de CCTV-beelden.

#figure(
  image("/assets/image-26.png"),
  caption: [Wireshark-opname van de knopdruk op de PLC.],
)

== Experiment 7 - Stroomonderbreking van de PLC (TP007)

Dit experiment hoort bij hypothese 4 (en raakt hypothese 1) en de scenario's 2, 5 en 6. Terwijl de PLC in RUN stond en met de PC communiceerde, is tijdens een Wireshark-opname de stroomkabel van de PLC fysiek losgekoppeld.

De abrupte onderbreking is herkenbaar in het netwerkverkeer: de communicatie stopt plotseling en er zijn TCP-retransmissions zichtbaar. In plaats van een nette afsluiting (TCP RST of FIN) blijft de PC pakketten herhalen, wat past bij een onverwacht wegvallen van de PLC. Het moment waarop de communicatie volledig stopt is vastgesteld op 10:25:01 en de laatste zichtbare functiecode vóór de uitval is `0xfe` (decimaal 254, Response OK), de standaardbevestiging. Het experiment is geslaagd en de hypothese bevestigd.

Gekoppeld aan het Plan van Aanpak laat dit zien dat een externe factor (hypothese 4, scenario 5: stroomstoring) of een hardware- of onderhoudsprobleem (scenario 6) een eigen, herkenbaar spoor achterlaat. Doordat er geen stopcommando (`0x41`) aan voorafgaat maar alleen retransmissions en plotselinge stilte, is een stroomuitval of spontane uitval (scenario 2) duidelijk te onderscheiden van een doelbewust via het netwerk verstuurde stop (zoals in experiment 2).

== Overzicht van de geverifieerde functiecodes

De experimenten leveren samen de volgende geverifieerde referentietabel op. Naast de hieronder genoemde codes bevatten de opnamen ook standaard sessie- en pollingverkeer (onder meer `0x01` INIT\_COMM, `0x04` READ\_PLC\_INFO, `0x24` READ\_COILS\_REGISTERS en de bevestiging `0xfe` Response OK); deze zijn niet handelingspecifiek en worden in de casus-analyse weggefilterd.

#figure(
  table(
    columns: (auto, auto, auto, auto),
    [*Code*], [*Dec.*], [*Handeling*], [*Geverifieerd in experiment*],
    [`0x10`], [16], [Inloggen / PLC claimen], [Exp. 1 – login/logout (No. 14)],
    [`0x11`], [17], [Uitloggen / reservering vrijgeven], [Exp. 1 – login/logout (No. 159)],
    [`0x40`], [64], [PLC starten], [Exp. 2 – start/stop (No. 26)],
    [`0x41`], [65], [PLC stoppen], [Exp. 2 – start/stop (No. 135)],
    [`0x6d`], [109], [Wijziging wegschrijven (SEND 2)], [Exp. 3 – send (No. 33)],
    [`0x29`], [41], [Wijziging wegschrijven (SEND 1)], [Exp. 3 – send (No. 35)],
    [`0x36`], [54], [Volledig project downloaden (PC→PLC)], [Exp. 4 – download (No. 42)],
    [`0x28`], [40], [Programma uploaden (PLC→PC)], [Exp. 5 – upload (No. 59)],
    [`0x72`], [114], [Vervolg upload (PLC→PC)], [Exp. 5 – upload (No. 192)],
  ),
  caption: [Overzicht van de geverifieerde UMAS-functiecodes per experiment.],
)


== Vergelijking met de experimenten van MCElevatorface

MCElevatorface programmeerde een eigen lift op een PLC en voerde vier onderzoeken uit: reconstructie van de lift met knoptests, een knipperlicht, het aanpassen van het programma (knipperinterval van twee naar vijf seconden) en het pushen van een nieuw programma. Een deel hiervan had echter weinig toegevoegde waarde voor de casus: het knipperlicht leverde naar eigen zeggen geen nieuwe bevindingen op en de reconstructie bevestigde slechts de al bekende verbindingscodes. Bovendien zijn hun experimenten niet goed vastgelegd: er zijn geen losse, herleidbare opnamen per handeling, codes worden in hexadecimaal zonder `0x`-prefix genoemd (`40`, `41`, `29`) en enkele codes bleven "onbekende functie 80/81".

Waar de onderzoeken overlappen, bevestigen de uitkomsten elkaar wel. De codes `0x01` (INIT\_COMM) en `0x10` (TAKE\_PLC\_RESERVATION) zijn in beide aangetroffen, en hun `WRITE_AND_READ_REGISTER` is dezelfde byte (`0x29`) die de aangepaste plugin als SEND 1 DOWNLOAD labelt - dezelfde schrijf-functie, andere naam. Daar bovenop is in dit onderzoek, dankzij de aangepaste plugin en de losse opname per handeling, méér en nauwkeuriger vastgelegd: de bij hen onbekende codes (`0x6d`, `0x28`/`0x72`, `0x36`) zijn benoemd, de start/stop-codes zijn op byteniveau vastgesteld (wat tot de plugin-correctie leidde) en de programmawijziging is hier wél reproduceerbaar (`0x6d`/`0x29`). De bevindingen van MCElevatorface worden dus niet tegengesproken maar bevestigd, beter gedocumenteerd en op onderdelen aangevuld.


== Conclusie van de experimenten

In de uitgevoerde experimenten is per handeling een geverifieerd verband vastgelegd tussen de handeling op de PLC en de bijbehorende UMAS-functiecode. Inloggen en uitloggen (`0x10`/`0x11`), starten en stoppen (`0x40`/`0x41`), het wegschrijven van een wijziging (`0x6d`/`0x29`), het downloaden van een volledig project (`0x36`) en het uploaden van een programma (`0x28`/`0x72`) zijn elk in een afzonderlijke opname op pakketniveau bevestigd.

Gekoppeld aan het Plan van Aanpak leveren de netwerkgerichte experimenten samen bewijs voor hypothese 3 en in het bijzonder scenario 3, met ondersteuning voor de scenario's 8 en 9. Doordat starten, stoppen en wijzigen het gevolg zijn van expliciete netwerkcommando's, maken zij hypothese 1 en scenario 2 minder aannemelijk. Experiment 6 en 7 dekken de overige hypotheses en scenario's: experiment 6 toont aan dat fysieke bediening en lokale programmalogica (hypothese 1 en 2, scenario's 1, 4 en 7) géén netwerksporen achterlaten en dus alleen met andere bewijsstukken te onderzoeken zijn, terwijl experiment 7 laat zien dat een externe stroomonderbreking (hypothese 4, scenario's 5 en 6) en een spontane uitval (scenario 2) wél een herkenbaar — maar van een netwerkstop te onderscheiden — spoor nalaten. Deze referentie laat zien hoe we de handelingen van Employee-01 in de casus-pcap kunnen interpreteren. Daarmee helpt het de hoofdvraag te beantwoorden: zijn de conclusies van MCElevatorface reproduceerbaar en valide?


