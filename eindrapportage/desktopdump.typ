= Memory-dump Desktop Analyse
De volgende deelvragen uit het Plan van Aanpak zijn leidend voor dit hoofdstuk:

- *DV5* Welk verband is er aantoonbaar tussen de activiteit op de desktop van Kristi en het lift-incident?
- *DV6* Welke rol heeft de software op Kristi's computer gespeeld bij het lift-incident?
- *DV7* In hoeverre zijn de bevindingen uit het rapport reproduceerbaar a.d.h.v. onafhankelijk analyse met dezelfde bewijsstukken?

Deze deelvragen worden beantwoord aan de hand van de volgende onderzoeksvragen, die in de analyse verder worden uitgewerkt:
- Welke processen waren actief op het systeem ten tijde van de memory dump?
- Welke netwerkverbindingen waren aanwezig op het systeem?
- Zijn er aanwijzingen voor PLC-gerelateerde software, bestanden of artefacten?
- In hoeverre ondersteunen de aangetroffen artefacten de conclusies van de oorspronkelijke onderzoeksgroep?

Voor dit onderdeel is de analyse van de desktop memory dump door de eerdere projectgroep opnieuw uitgevoerd. Het doel is om vast te stellen of de gebruikte methode reproduceerbaar is en of de getrokken conclusies worden ondersteund door de beschikbare artefacten.

== Image-informatie
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

== Procesanalyse
De proceslijst te zien in @pslist, bevat voornamelijk standaard Windows-processen, Microsoft Edge, OneDrive, VMware Tools en Microsoft Defender. Er zijn geen processen aangetroffen die direct wijzen op PLC-engineeringsoftware, remote access software of andere tooling die direct in verband gebracht kan worden met de PLC-aanval. Deze bevinding komt overeen met de conclusie van de oorspronkelijke onderzoeksgroep.

#figure(
image("/assets/image-22-desktopdump.png", width: 60%),
caption: "[Desktopdump-2] Output van Volatility3's windows.pslist plugin"
)<pslist>

== Extra controle met psscan
De aanvullende analyse met de psscan-plugin weergegeven in @psscan leverde geen afwijkende of verborgen processen op ten opzichte van de resultaten van pslist. Hiermee wordt de conclusie van de oorspronkelijke onderzoeksgroep verder ondersteund.

#figure(
image("/assets/image-23-desktopdump.png", width: 60%),
caption: "[Desktopdump-2] Output van Volatility3's windows.psscan plugin"
)<psscan>
== Validatie netwerkverbindingen
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
  caption: [[Desktopdump-3] Externe IP-adressen aangetroffen tijdens netscan-analyse en bijbehorende organisaties.],
)
== Registry
De oorspronkelijke onderzoeksgroep concludeert dat de registry waarschijnlijk niet aanwezig was in de memory dump. Tijdens de validatie is de plugin `windows.registry.hivelist` uitgevoerd. Hieruit blijkt dat meerdere registry hives aanwezig zijn in de memory dump, waaronder `SYSTEM`, `SOFTWARE`, `SAM`, `SECURITY` en de gebruikershive van gebruiker krist. De conclusie dat de registry niet aanwezig was in de memory dump wordt daarom niet ondersteund door de resultaten van de validatie.

#figure(
image("/assets/image-24-desktopdump.png", width: 100%),
caption: "[Desktopdump-3
4] Output van Volatility3's windows.registry.hivelist plugin"
)<hive>

== Filescan
Tijdens de filescan-analyse zijn geen bestanden aangetroffen die direct wijzen op de aanwezigheid van Schneider EcoStruxure, Machine Expert of andere PLC-gerelateerde software. Deze bevinding ondersteunt de conclusie van de oorspronkelijke onderzoeksgroep.
== Strings
De ruwe memorydump is omgezet naar een strings.txt bestand, en hier is gegrept op termen die eventueel nuttige informatie kunnen extraheren gerelateerd aan het onderzoek.
```bash
grep -i -E "schneider|ecostruxure|machine expert|modbus" strings.txt
```
Tijdens de analyse werden meerdere PLC-gerelateerde strings aangetroffen:
#figure(
  ```json
  {"helps":[{"id":"yzq01c5g1rDRs_Lflg2ggw","ver":"V2.1","lng":"en","ttl":"PLCopen Safety Function Blocks","n":"SF_PrefaceSafety","bc":[{"id":"Fya5GQLY7ul57KsswMNICQ","n":"VLP_PLCOpen","ttl":"PLCopen Safety Function Blocks Library"},{"id":"SACgLqMU9gqYoWdyQNxTmQ","n":"VLP_SoSafe","ttl":"EcoStruxure Machine Expert - Safety"},{"id":"IAUhz70yDliIZsV2lwUtNw","n":"VLP_Safety","ttl":"EcoStruxure Machine Expert - Safety"},{"id":"RkN_cuO-L1Cqr1BwRxzTtg","n":"V2.1","ttl":"V2.1"},{"id":"_6iawEiBfGt5TJm-GCGLkg","n":"Machine Expert","ttl":"Machine Expert"}]}],"groups":[]}
  ```,
  caption: "[Desktopdump-5] Verwijzing naar Machine Expert documentatie betreft veiligheid"
)

#figure(
  ```
  prog_cntTsBase.py.TsBase(TsHi.pykeystateGetProjectInfoGetProgramTableSafeAppendProgramMod. TsHi(TsLow.pyprint_last_error.TsLow( TCM foundCRC16_MODBUSKotov AlaxanderCRC_CCITT_XMODEMcrc16retCRC16_CCITTsh.pyc FAILUREsymbol tableinject.binimain.bin
  ```,
caption: "[Desktopdump-5] Verwijzing naar MODBUS"
)<verwijzing_modbus>

in @verwijzing_modbus staan eventueel interessante termen, zoals `GetProjectInfo` en `GetProgramTable`. Deze kunnen eventueel betrekking hebben tot projectbestanden van een PLC.
#linebreak()
Na het uitvoeren van ```bash grep -i -C 100 -E "GetProjectInfo" strings.txt```


Na verder onderzoek van de context waarin deze strings voorkwamen wijst erop dat deze waarschijnlijk afkomstig zijn uit Microsoft Defender-signatures en niet uit daadwerkelijk uitgevoerde PLC-software. De aangetroffen strings vormen daarom geen sterk bewijs voor PLC-manipulatie.
== Conclusie
De analyse van de desktop memory dump bleek grotendeels reproduceerbaar. Tijdens de validatie werden enkele aanvullende artefacten aangetroffen, waaronder de exacte Windows versie, aanwezige registry hives en aanvullende externe IP-adressen. Deze bevindingen hebben echter geen invloed op de conclusies van het oorspronkelijke onderzoek.

*DV5: Welk verband is er aantoonbaar tussen de activiteit op de desktop van Kristi en het lift-incident?*

Op basis van de uitgevoerde analyse is geen direct verband aangetoond tussen activiteiten op de desktop van Kristi en het lift-incident. Er zijn geen processen, bestanden of netwerkverbindingen aangetroffen die direct gekoppeld kunnen worden aan manipulatie van de PLC of het veroorzaken van de storing.

*DV6: Welke rol heeft de software op Kristi's computer gespeeld bij het lift-incident?*

Tijdens de analyse zijn geen aanwijzingen gevonden voor actieve PLC-engineeringsoftware, PLC-projectbestanden of andere software die direct gebruikt lijkt te zijn voor het aanpassen van de PLC. De aangetroffen PLC-gerelateerde strings blijken waarschijnlijk afkomstig uit Microsoft Defender-signatures en vormen daarom geen sterk bewijs voor daadwerkelijke PLC-activiteiten.

*DV7: In hoeverre zijn de bevindingen uit het rapport reproduceerbaar aan de hand van onafhankelijk onderzoek met dezelfde bewijsstukken?*

De meeste bevindingen uit het oorspronkelijke onderzoeksrapport konden worden gereproduceerd. Daarnaast zijn enkele aanvullende artefacten aangetroffen die niet in het oorspronkelijke rapport zijn beschreven. Deze aanvullende bevindingen wijzigen de oorspronkelijke conclusies echter niet. De conclusie dat de desktop memory dump beperkte forensische waarde heeft voor het reconstrueren van de aanval wordt daarmee ondersteund.