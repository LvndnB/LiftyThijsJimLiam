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

