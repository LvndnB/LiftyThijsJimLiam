= Desktopdump
Voor dit onderdeel is de analyse van de desktop memory dump door de eerdere projectgroep opnieuw uitgevoerd. Het doel is om vast te stellen of de gebruikte methode reproduceerbaar is en of de getrokken conclusies worden ondersteund door de beschikbare artefacten.

== Reproductie van de analyse
=== Validatie van image-informatie
In het onderzoeksverslag wordt vermeld dat het een windows desktop betreft, maar dat de versie niet duidelijk is.
Door middel van de `windows.info` plugin van Volatility3 kon aanvullende systeeminformatie worden verkregen, zie @system_info.
Hieruit blijkt dat het systeem Windows 10 betreft met buildnummer 19041. Deze informatie was aanwezig in de memory dump, maar is niet opgenomen in het oorspronkelijke onderzoeksverslag.
#figure(
```bash
Major/Minor     15.19041
MachineType     34404
KeNumberProcessors      2
SystemTime      2023-06-22 14:32:56+00:00
NtSystemRoot    C:\WINDOWS
NtProductType   NtProductWinNt
NtMajorVersion  10
NtMinorVersion  0
```,
caption: [Systeeminformatie, geextract uit memorydump met Volatility3.],
)<system_info>

=== Validatie procesanalyse
=== Extra controle met psscan
=== Validatie netwerkverbindingen
Tijdens de reproductie van de netscan-analyse werden meer externe IP-adressen aangetroffen dan in het oorspronkelijke verslag zijn opgenomen. Validatie met WHOIS/ASN-attributie toont aan dat deze adressen behoren tot Microsoft Azure, Microsoft 365 en Google-infrastructuur. Er zijn geen aanwijzingen gevonden dat deze verbindingen direct gerelateerd zijn aan de onderzochte PLC-aanval. De aanvullende IP-adressen wijzigen de conclusies van het oorspronkelijke onderzoek daarom niet.
#figure(
  table(
    columns: 3,
    [IP-adres], [Eigenaar], [Interpretatie],

    [20.44.10.123], [Microsoft Corporation (AS8075)], [Azure infrastructuur],
    [20.72.146.34], [Microsoft Corporation (AS8075)], [Azure infrastructuur],
    [20.7.2.167], [Microsoft Corporation (AS8075)], [Azure infrastructuur],
    [20.120.56.233], [Microsoft Corporation (AS8075)], [Azure infrastructuur],
    [13.69.109.130], [Microsoft Corporation (AS8075)], [Azure infrastructuur],
    [13.68.233.9], [Microsoft Corporation (AS8075)], [Azure infrastructuur],
    [13.107.21.200], [Microsoft Corporation], [Microsoft 365 / Windows-diensten],
    [13.107.21.239], [Microsoft Corporation], [Microsoft 365 / Windows-diensten],
    [52.96.109.226], [Microsoft Corporation], [Microsoft 365],
    [172.253.63.17], [Google LLC (AS15169)], [Google-dienst],
  ),
  caption: [Externe IP-adressen aangetroffen tijdens netscan-analyse en bijbehorende organisaties.],
)
=== Registry-claim valideren
=== Filescan valideren
=== Strings-validatie
== Bevindingen van de validatie

