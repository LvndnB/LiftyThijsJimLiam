= Reflecties

== Liam van den Berg
In dit validatieproject heb ik twee technische onderdelen gedaan: data uit de pcap-bestanden extraheren met een eigen script, en een Wireshark-plugin updaten om het verkeer leesbaar te maken. 

Het schrijven van het extractiescript heeft mijn kennis van het Modbus-protocol flink uitgebreid. Om de juiste data eruit te halen moest ik echt snappen hoe Modbus UMAS is opgebouwd: welke functiecodes er zijn, hoe een request en response eruitzien en waar de waarden in het bericht staan. Door dit zelf in code uit te werken begrijp ik het protocol nu veel beter dan toen ik alleen in Wireshark zat te klikken.

Mijn forensische ontwikkeling zat vooral in het controleren van mijn werk. In een validatieproject is het niet genoeg als het script data oplevert, maar ik moet ook kunnen aantonen dat die data klopt. Daarom heb ik mijn resultaten steeds vergeleken met wat Wireshark liet zien, zodat ik zeker wist dat ik niets verkeerd interpreteerde. Dat controleren en onderbouwen zie ik als mijn sterke punt in dit project.

Mijn zwakke punt is dat ik mijn keuzes niet altijd goed vastlegde. Mijn werk klopte wel, maar voor een teamgenoot was niet altijd te volgen waarom ik iets op een bepaalde manier had gedaan. Voor forensisch werk is dat belangrijk, want een ander moet mijn stappen kunnen herhalen. Daarom ben ik dus beter gaan letten op het documenteren van mijn proces in het logboek zodat het beter reproduceerbaar is.

== Thijs van der Zwan
In dit project heb ik me vooral gericht op het analyseren van de PLC memory dumps. Hoewel ik al ervaring had met het programmeren van PLC's, was het analyseren van RAM dumps nieuw voor mij. Ik heb daarom eerst veel tijd besteed aan het onderzoeken van de technische inhoud, de structuur en de functie van de data in het RAM-geheugen van een PLC. Ook heb ik me verdiept in relevante tools, om de dumps te kunnen analyseren en de inhoud te kunnen interpreteren en vergelijken. Vooraf wist ik niet dat er zoveel interessante informatie te vinden zou zijn in de dumps en dat er zoveel sporen te zien waren van manipulatieve handelingen.

Mijn sterke punt in dit project was de kritische blik die ik heb toegepast op de memory analyse. Ik wilde een nauwkeurige vergelijking maken van de verschillende bestanden, om een sterker onderbouwde conclusie te kunnen vormen dan MCElevatorFace. Zo heb ik alle gevonden wijzigingen overzichtelijk in beeld gebracht en toegelicht. Dit heeft geleid tot een beter inzicht in de impact van de wijzigingen en de oorzaak van het incident.

Een verbeterpunt is dat ik moet aanleren om altijd in mijn onderzoeksomgeving te werken. Terwijl ik voorkennis aan het opdoen was over RAM-geheugen in PLC's liep ik soms te hard van stapel en wilde ik meteen een bestand analyseren, zonder de juiste voorbereidende stappen te nemen. Hierdoor ben ik extra tijd kwijt geraakt aan het opnieuw uitvoeren van sommige stappen, omdat ik deze eerder niet of onvoldoende had gedocumenteerd tijdens het proces.

#pagebreak()

== Jim van Dijk
Tijdens dit project heb ik ervaring opgedaan met het valideren van digitaal forensisch onderzoek aan de hand van dezelfde bewijsstukken van een eerdere onderzoeksgroep. Hierbij heb ik analyses uitgevoerd op een desktop memory dump, netwerk captures bekeken en experimenten uitgevoerd met de PLC, om te kijken hoe bepaalde events er uit zagen in netwerkverkeer.

Achteraf had ik graag meer willen doen omtremt de PLC-memory dump en netwerkcapture. Dit omdat bleek dat er weinig was om diep in te duiken rond de desktop dump, en ik hier niet veel nieuws heb gevonden. Gelukkig heb ik genoeg kunnen mee-denken en kijken om wat op te steken over communicatie over het Modbus protocol en over PLC's in het algemeen.

Verder is een verbeterpunt tijdig mijn logboek bijhouden. Het is dit keer niet zo erg, omdat ik wel notities bijhield. Maar het is handiger om vanaf begins af aan gelijk te loggen. Dan is het veel makkelijker om overzicht te houden, en hoeft dit niet achteraf bij elkaar gezocht te worden.