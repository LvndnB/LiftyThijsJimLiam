= Experimenten
== Onderzoeksopzet en gebruikte tools

De experimenten zijn uitgevoerd in een afgeschermd testnetwerk met een Schneider Modicon M221 PLC en een laptop met EcoStruxure Machine Expert – Basic. Beide apparaten bevonden zich in hetzelfde subnet: de laptop op `192.168.243.110` en de PLC op `192.168.243.190`. Voor elk experiment is dezelfde werkwijze aangehouden: in Wireshark werd een live capture gestart, vervolgens werd in Machine Expert (of via de fysieke knoppen) de te onderzoeken handeling uitgevoerd, en daarna werd de capture gestopt en als afzonderlijk `.pcapng`-bestand opgeslagen. Deze opnamen zijn als bijlage opgenomen.

Voor het decoderen van het UMAS-verkeer is gebruikgemaakt van een aangepaste Wireshark-plugin, gebaseerd op het open-source project van biero-el-corridor #cite(<bierocorridor_umasplugin>). Met deze plugin worden de UMAS-functiecodes rechtstreeks in de Wireshark-pakketweergave zichtbaar als een afzonderlijke UMAS-laag. Hierdoor kon het verkeer direct in Wireshark worden uitgelezen en gefilterd, zonder dat de pcap eerst naar Excel hoefde te worden geëxporteerd. MCElevatorface gebruikte voor hun analyse wel een exportstap: zij verwerkten de pakketdata via een zelfgeschreven script in een Excel-bestand.

== De aangepaste Wireshark-plugin

De originele plugin van biero-el-corridor is geschreven voor de Schneider Modicon M340. Bij het toepassen op het verkeer van de Modicon M221 bleek dat enkele functiecodes niet overeenkwamen. Met behulp van onderstaande experimenten is de plugin aangepast en zijn enkele belangrijke functie codes gecorrigeerd.

De plugin herkent UMAS-verkeer aan de byte `0x5A` op offset 7 van de Modbus-PDU, de UMAS-functiecode staat op offset 9. Naast de correctie van de start/stop-codes zijn in de aangepaste plugin per functiecode commentaarregels toegevoegd die vastleggen in welk experiment en bij welk pakketnummer de betreffende code is geverifieerd. De volledige aangepaste plugin (`modbus-umas-schneider.lua`) is als bijlage opgenomen.

== Experiment 1 — In- en uitloggen op de PLC (TP001)
_PCAP: `login and logout PLC.pcapng`_

Dit experiment hoort bij hypothese 3 en scenario 3: inloggen is de voorwaarde voor manipulatie op afstand, omdat een client pas na het claimen van de PLC wijzigingen kan wegschrijven. Het sluit aan op de in het Plan van Aanpak benoemde validatie van functiecode 10 (TAKE\_PLC\_RESERVATION). Vanaf de PC is een sessie geopend en weer afgesloten: de opname begint met `INIT_COMM`, waarna de PC het eigenaarschap claimt met `TAKE_PLC_RESERVATION` (`0x10`, No. 14) en dit bij het uitloggen weer vrijgeeft met `RELEASE_PLC_RESERVATION` (`0x11`, No. 159). Beide handelingen zijn daarmee herkenbaar in het netwerk.

#table(
  columns: (auto, auto, auto, auto),
  [*Functiecode*], [*Decimaal*], [*Pakket*], [*Betekenis*],
  [`0x01`], [1], [No. 10], [INIT\_COMM – initialiseren van een UMAS-communicatie],
  [`0x10`], [16], [No. 14], [TAKE\_PLC\_RESERVATION – PLC claimen (inloggen)],
  [`0x11`], [17], [No. 159], [RELEASE\_PLC\_RESERVATION – reservering vrijgeven (uitloggen)],
)

#image("/assets/image-11.png")

== Experiment 2 — Starten en stoppen van de PLC (TP002)
 
_PCAP: `start and stop PLC.pcapng`_
 
Dit experiment hoort bij hypothese 3 en de scenario's 3 en 8. Een op de PLC aanwezig programma is gestart en gestopt. Bij het starten is op pakket No. 26 functiecode `0x40` (decimaal 64) aangetroffen en bij het stoppen op No. 135 functiecode `0x41` (decimaal 65); het eindoordeel in TP002 is geslaagd. Deze waarden bevestigen tevens dat de oorspronkelijke plugin-koppeling (decimaal 58/59) onjuist was en vormden de aanleiding voor de correctie. Doordat start en stop expliciete netwerkcommando's blijken, wordt een spontane technische- of firmwarefout zonder menselijke invloed als verklaring minder waarschijnlijk.
 
#table(
  columns: (auto, auto, auto, auto),
  [*Functiecode*], [*Decimaal*], [*Pakket*], [*Betekenis*],
  [`0x40`], [64], [No. 26], [START\_PLC – het programma op de PLC starten],
  [`0x41`], [65], [No. 135], [STOP\_PLC – het programma op de PLC stoppen],
)
 
#image("/assets/image-22.png")

== Experiment 3 — Gewijzigd programma naar de PLC sturen (SEND) (TP003)

_PCAP: `send (ingelogd en in programmering tab, na het bewerken van programma).pcapng`_

Dit experiment hoort bij hypothese 3 en de scenario's 3 en 9 en sluit aan op het in het Plan van Aanpak benoemde experiment "aanpassing maken aan het programma". In Machine Expert is een kleine wijziging aangebracht (ingang `I0.0` naar `I0.2`) en via SEND naar de draaiende PLC geschreven. In de opname staan twee schrijf-functiecodes: `0x6d` (SEND 2 DOWNLOAD) op No. 33 en `0x29` (SEND 1 DOWNLOAD) op No. 35, zonder start/stop-commando. Het is dus aantoonbaar mogelijk een draaiend PLC-programma over het netwerk te overschrijven.

#table(
  columns: (auto, auto, auto, auto),
  [*Functiecode*], [*Decimaal*], [*Pakket*], [*Betekenis*],
  [`0x6d`], [109], [No. 33], [SEND 2 DOWNLOAD – data naar de PLC schrijven (PC → PLC)],
  [`0x29`], [41], [No. 35], [SEND 1 DOWNLOAD – data naar de PLC schrijven (PC → PLC)],
)

#image("/assets/image-23.png")

== Experiment 4 — Project van PC naar PLC sturen (download) (TP004)

_PCAP: `PC to Controller (download).pcapng`_

Dit experiment hoort bij hypothese 3 en scenario 3. Een volledig Machine Expert-project is vanaf de PC naar de PLC gestuurd (download); op pakket No. 42 is functiecode `0x36` (DOWNLOAD 1) aangetroffen. Waar SEND een wijziging in een draaiend programma wegschrijft, hoort `0x36` bij het overdragen van een compleet, en dus mogelijk gemanipuleerd, project naar de PLC.

#table(
  columns: (auto, auto, auto, auto),
  [*Functiecode*], [*Decimaal*], [*Pakket*], [*Betekenis*],
  [`0x36`], [54], [No. 42], [DOWNLOAD 1 – volledig project van PC naar PLC (PC → PLC)],
)

#image("/assets/image-24.png")

== Experiment 5 — Programma van PLC naar PC kopiëren (upload) (TP005)

_PCAP: `Controller to PC (upload).pcapng`_

Dit experiment hoort bij hypothese 3 en de scenario's 3 en 9. Het actieve programma is vanaf de PLC naar de PC gekopieerd (upload). Daarbij zijn twee functiecodes aangetroffen: `0x28` (UPLOAD) op No. 59 en `0x72` (UPLOAD 2) op No. 192, beide in de richting PLC → PC. Hiermee is het op de PLC aanwezige programma via het netwerk uitleesbaar.

#table(
  columns: (auto, auto, auto, auto),
  [*Functiecode*], [*Decimaal*], [*Pakket*], [*Betekenis*],
  [`0x28`], [40], [No. 59], [UPLOAD – programma van PLC naar PC (PLC → PC)],
  [`0x72`], [114], [No. 192], [UPLOAD 2 – vervolg van de upload (PLC → PC)],
)

#image("/assets/image-25.png")

