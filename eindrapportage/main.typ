#import "voorblad.typ": title

#show heading.where(level: 1): set text(size: 20pt)
#show heading.where(level: 2): set text(size: 16pt)
#show heading.where(level: 3): set text(size: 14pt)
#show heading.where(level: 4): set text(size: 11pt)

#set document(
  title: [Lifty - Eindrapportage],
  author: "Liam van den Berg, Thijs van der Zwan, Jim van Dijk"
)

#set text(
  lang: "nl"
)


#title()

#pagebreak()

#include "samenvatting.typ"


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

// #pagebreak()
#include "inleiding.typ"
#pagebreak()
#set heading(numbering: "1.")

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
#include "cctv.typ"
#pagebreak()
#include "conclusie.typ"
#pagebreak()
#include "reflectie.typ"
#pagebreak()
#counter(heading).update(0)
#set heading(numbering: "A.", supplement: [Bijlage])

= Wireshark Plugin <appendixA>
Hieronder volgt de aangepaste plugin gebaseerd op de plugin van #cite(<bierocorridor_umasplugin>):


```lua
--[[
    lua wireshark addon for the UMAS embeded modbus protocol 
    made by biero-el-corridor
--]]

-- functions that made the concordance of the umas_code -> funtions meaning
function get_umas_function_name(code)
    local code_name = "Unknown"
    -- source: http://lirasenlared.blogspot.com/2017/08/the-unity-umas-protocol-part-i.html
    if code == 1 then code_name = "0x01 - INIT_COMM: Initialize a UMAS communication"
    elseif code == 2 then code_name = "0x02 - READ_ID: Request a PLC ID"
    elseif code == 3 then code_name = "0x03 - READ_PROJECT_INFO: Read Project Information"
    elseif code == 4 then code_name = "0x04 - READ_PLC_INFO: Get internal PLC Info"
    elseif code == 6 then code_name = "0x06 - READ_CARD_INFO: Get internal PLC SD-Card Info"
    elseif code == 10 then code_name = "0x0A - REPEAT: Sends back data sent to the PLC (used for synchronization)" 
    elseif code == 16 then code_name = "0x10 - [] TAKE_PLC_RESERVATION: Assign an owner to the PLC"    -- geverifieerd met "login and logout PLC.pcapng" op packet No. 14
    elseif code == 17 then code_name = "0x11 - [] RELEASE_PLC_RESERVATION: Release the reservation of a PLC"    -- geverifieerd met "login and logout PLC.pcapng" op packet No. 159 
    elseif code == 18 then code_name = "0x12 - KEEP_ALIVE: Keep alive message (???)"
    elseif code == 32 then code_name = "0x20 - READ_MEMORY_BLOCK: Read a memory block of the PLC"
    elseif code == 34 then code_name = "0x22 - READ_VARIABLES: Read System bits, System Words and Strategy variables"
    elseif code == 35 then code_name = "0x23 - WRITE_VARIABLES: Write System bits, System Words and Strategy variables"
    elseif code == 36 then code_name = "0x24 - READ_COILS_REGISTERS: Read coils and holding registers from PLC"
    elseif code == 37 then code_name = "0x25 - WRITE_COILS_REGISTERS: Write coils and holding registers into PLC"
    elseif code == 40 then code_name = "0x28 - [] UPLOAD (PLC to PC)" -- geverifieerd met "Controller to PC (upload).pcapng" op packet No. 59
    elseif code == 41 then code_name = "0x29 - [] SEND 1 DOWNLOAD (PC to PLC)" -- geverifieerd met "send (ingelogd en in programmering tab, na het bewerken van programma).pcapng" op packet No. 35
    elseif code == 48 then code_name = "0x30 - INITIALIZE_UPLOAD: Initialize Strategy upload (copy from engineering PC to PLC)"
    elseif code == 49 then code_name = "0x31 - UPLOAD_BLOCK: Upload (copy from engineering PC to PLC) a strategy block to the PLC"
    elseif code == 50 then code_name = "0x32 - END_STRATEGY_UPLOAD: Finish strategy Upload (copy from engineering PC to PLC)"
    elseif code == 51 then code_name = "0x33 - INITIALIZE_UPLOAD: Initialize Strategy download (copy from PLC to engineering PC)"
    elseif code == 52 then code_name = "0x34 - DOWNLOAD_BLOCK: Download (copy from PLC to engineering PC) a strategy block"
    elseif code == 53 then code_name = "0x35 - END_STRATEGY_DOWNLOAD: Finish strategy Download (copy from PLC to engineering PC)"
    elseif code == 54 then code_name = "0x36 - [] DOWNLOAD 1 (PC to PLC)" -- geverifieerd met "PC to Controller (download).pcapng" op packet No. 42
    elseif code == 57 then code_name = "0x39 - READ_ETH_MASTER_DATA: Read Ethernet Master Data"
    
    -- elseif code == 58 then code_name = "0x40 - START_PLC: Starts the PLC"    -- not correct, moved to code == 64
    -- elseif code == 59 then code_name = "0x41 - STOP_PLC: Stops the PLC"    -- not correct, moved to code == 65
    elseif code == 64 then code_name = "0x40 - [] START_PLC: Starts the PLC" -- geverifieerd met "start and stop PLC.pcapng" op packet No. 26 
    elseif code == 65 then code_name = "0x41 - [] STOP_PLC: Stops the PLC" -- geverifieerd met "start and stop PLC.pcapng" op packet No. 135
    elseif code == 80 then code_name = "0x50 - MONITOR_PLC: Monitors variables, Systems bits and words"
    elseif code == 88 then code_name = "0x58 - CHECK_PLC: Check PLC Connection status"
    elseif code == 109 then code_name = "0x6d - [] SEND 2 DOWNLOAD (PC to PLC)" -- geverifieerd met "send (ingelogd en in programmering tab, na het bewerken van programma).pcapng" op packet No. 33
    elseif code == 112 then code_name = "0x70 - READ_IO_OBJECT: Read IO Object"
    elseif code == 113 then code_name = "0x71 - WRITE_IO_OBJECT: WriteIO Object"
    elseif code == 114 then code_name = "0x72 - [] UPLOAD 2 (PLC to PC)" -- geverifieerd met "Controller to PC (upload).pcapng" op packet No. 192
    elseif code == 115 then code_name = "0x73 - GET_STATUS_MODULE: Get Status Module"
    elseif code == 254 then code_name = "0xfe - Response Meaning OK"
    elseif code == 253 then code_name = "0xfd - Response Meaning Error" end
    return code_name
end

modbus1_protocol = Proto("Modbus1", "Modbus .")
umas_protocol = Proto("UMAS", "UMAS .")

-- ressourc that worth your time https://www.wireshark.org/docs/wsdg_html_chunked/lua_module_Proto.html
----------- part of the modbus protocol ---------------
Transaction_Identifier  = ProtoField.uint16("Modbus1.Transaction_Identifier"  , "Transaction_Identifier"  , base.DEC)
Protocol_Identifier     = ProtoField.uint16("Modbus1.Protocol_Identifier"     , "Protocol_Identifier"     , base.DEC)
Length                  = ProtoField.uint16("Modbus1.Length"                  , "Length"                  , base.DEC)
Unit_Identifier         = ProtoField.int8("Modbus1.Unit_Identifier"         , "Unit_Identifier"         , base.DEC)
modbus1_protocol.fields = { Transaction_Identifier, Protocol_Identifier, Length, Unit_Identifier }
-------------------------------------------------------

----------- part of the UMAS protocol -----------------
Function_Code           = ProtoField.uint8("UMAS.Function_Code"         , "Function_Code"        , base.HEX_DEC)
Pairing_Key             = ProtoField.uint8("UMAS.Pairing_Key"           , "Pairing_Key"          , base.HEX)
Umas_Functions_Code     = ProtoField.uint8("UMAS.Umas_Functions_Code"   , "Umas_Functions_Code"  , base.DEC)
Umas_Data               = ProtoField.string("UMAS.Umas_Data"            , "Umas_Data"            , base.ASCII )
umas_protocol.fields    = { Function_Code, Pairing_Key, Functions_Code , Umas_Functions_Code ,Umas_Data }
-------------------------------------------------------

function modbus1_protocol.dissector(buffer,pinfo,tree)
    -- get the size of the packet sections 
    length = buffer:len()

    ------------------------------------------
    -- BEGIN OF THE MODBUS SECTIONS ----------
    ------------------------------------------

    -- if the sections is empty , terminate the process
    if length == 0 then return end
    
    -- apply the name in the column if the protocol is detected
    pinfo.cols.protocol = modbus1_protocol.name

    -- add the layer umas in the list of potential layer 
    local subtree       = tree:add(modbus1_protocol, buffer()      , "Modbus Protocol Data")
    local modbusSubtree = subtree:add(modbus1_protocol, buffer()   ,"modbus header")

    modbusSubtree:add(Transaction_Identifier   ,buffer(0,2))
    modbusSubtree:add(Protocol_Identifier      ,buffer(2,2))
    modbusSubtree:add(Length                   ,buffer(4,2))
    modbusSubtree:add(Unit_Identifier          ,buffer(6,1))
    ------------------------------------------
    -- END OF THE MODBUS SECTIONS ------------
    ------------------------------------------
    
    ------------------------------------------
    -- BEGIN OF THE UMAS SECTIONS ------------
    ------------------------------------------

    local umas_identifier = buffer(7,1):le_uint()
    local umas_code = buffer(9,1):le_uint()
    local umas_code_name = get_umas_function_name(umas_code)

    local getData = buffer(10)
    local data = getData:le_ustring()

    if(umas_identifier == 90) 
    then
        local data_length = length - 10
        local umasSubtree   = subtree:add(modbus1_protocol ,buffer()   ,"umas")
        umasSubtree:add(Function_Code, buffer(7,1))
        umasSubtree:add(Pairing_Key, buffer(8,1))
        umasSubtree:add(Umas_Functions_Code,buffer(9,1)):append_text(" (" .. umas_code_name .. ")")
        umasSubtree:add(Umas_Data, getData, data)
    end
    ------------------------------------------
    -- END OF THE UMAS SECTIONS ------------
    ------------------------------------------ 
end

-- subtree for the definitions of the UMAS protocol. 
function umas_protocol.dissector(buffer,pinfo,tree)
    length = buffer:len()
    if length == 0 then return end
    pinfo.cols.protocol = umas_protocol.name

    local subtree = tree:add(umas_protocol, buffer, "UMAS")
    subtree:add_le(Function_Code, buffer(7,1))
end

local modbus = DissectorTable.get("tcp.port")
modbus:add(502, modbus1_protocol)
```
#pagebreak()
= Script <appendixB>
Python script: `extract_zips.py`:


```py
import struct, sys

# Lees het stream bestand
with open(sys.argv[1], 'rb') as f:
    raw = f.read()

# Doorloop alle Modbus TCP frames en verzamel de payloads
# Elk frame begint met een 6-byte MBAP header gevolgd door data
# De totale header die we overslaan is 16 bytes (MBAP + UMAS header)
payload = bytearray()
pos = 0
while pos + 6 <= len(raw):
    proto_id = struct.unpack('>H', raw[pos+2:pos+4])[0]
    length   = struct.unpack('>H', raw[pos+4:pos+6])[0]

    # Sla frames over die geen Modbus zijn (protocol ID moet 0 zijn)
    if proto_id != 0 or length == 0:
        pos += 1
        continue

    # Voeg alles NA de 16-byte header toe aan de payload
    payload.extend(raw[pos+16 : pos+6+length])
    pos += 6 + length

# Zoek het begin van de ZIP (PK header: 50 4B 03 04)
start = payload.find(b'\x50\x4b\x03\x04')

# Zoek het einde van de ZIP (End of Central Directory: 50 4B 05 06)
end = payload.find(b'\x50\x4b\x05\x06', start) + 22

# Sla de ZIP op
with open('extracted.zip', 'wb') as f:
    f.write(payload[start:end])

print(f"Klaar: extracted.zip ({end - start} bytes)")

```
#pagebreak()
= Entry's uit de PCAP-analyse <appendixC>

Tijdens de PCAP-analyse zijn de vier uploadsessies (streams) van Employee-01 naar de PLC gereconstrueerd. Per stream is met het script uit @appendixB het ZIP-archief uit de TCP-datastroom gecarved; elk archief bevat één `entry`-bestand met de XML-metadata van het PLC-project op dat moment (zie het hoofdstuk over de PCAP-analyse).
 
Deze vier `entry`-bestanden zijn in het portfolio aanwezig in de map `TCPstreamZIPextractie`, met de volgende structuur:
 
```
TCPstreamZIPextractie/
├── extract_zips.py
├── Stream1/
│   ├── stream1.bin
│   ├── extracted.zip
│   └── extracted/
│       └── entry
├── Stream2/
│   ├── stream2.bin
│   ├── extracted.zip
│   └── extracted/
│       └── entry
├── Stream3/
│   ├── stream3.bin
│   ├── extracted.zip
│   └── extracted/
│       └── entry
└── Stream4/
    ├── stream4.bin
    ├── extracted.zip
    └── extracted/
        └── entry
```
 
Elke `StreamX`-map komt overeen met één uploadmoment: `streamX.bin` is de ruwe TCP-stream, `extracted.zip` het daaruit gecarvede ZIP-archief en `extracted/entry` het uitgepakte metadatabestand dat voor de versievergelijking tussen de vier uploads is gebruikt.

#pagebreak()
= Entry's uit de ExtRAM-analyse <appendixD>

Tijdens de analyse van het External RAM van de PLC is in alle zeven dumps een `ZIP-archief` aangetroffen. In deze ZIP-archieven was telkens één `entry`-bestand aanwezig. Dit zijn dus de entry-bestanden met de XML-metadata van het PLC-project dat op het moment van de dump op de PLC aanwezig was (zie het hoofdstuk over de PLC Memorydump-analyse).
 
Deze zeven `entry`-bestanden zijn in het portfolio aanwezig in de map `ExtRAMextractie`, met de volgende structuur:
 
```
ExtRAMextractie/
├── Dump1/
│   ├── ExtRAM1.bin
│   ├── OnChipRAM1.bin
│   ├── entry1
│   └── extracted_1.zip
├── Dump2/
│   ├── ExtRAM2.bin
│   ├── OnChipRAM2.bin
│   ├── entry2
│   └── extracted_2.zip
├── Dump3/
│   ├── ExtRAM3.bin
│   ├── OnChipRAM3.bin
│   ├── entry3
│   └── extracted_3.zip
├── Dump4/
│   ├── ExtRAM4.bin
│   ├── OnChipRAM4.bin
│   ├── entry4
│   └── extracted_4.zip
├── Dump5/
│   ├── ExtRAM5.bin
│   ├── OnChipRAM5.bin
│   ├── entry5
│   └── extracted_5.zip
├── Dump6/
│   ├── ExtRAM6.bin
│   ├── OnChipRAM6.bin
│   ├── entry6
│   └── extracted_6.zip
└── Dump7/
    ├── ExtRAM7.bin
    ├── OnChipRAM7.bin
    ├── entry7
    └── extracted_7.zip
```
 
Elke `DumpX`-map komt overeen met één dumpmoment en bevat de volgende bestanden:  `ExtRAMX.bin` en `OnChipRAMX.bin` zijn de originele dump-bestanden. Hier zijn de ZIP-archieven `extracted_X.zip` uit gecarved, en `entryX` is het uitgepakte metadatabestand dat voor de versievergelijking tussen de zeven dumps is gebruikt.

#pagebreak()
#bibliography("bronnen.bib", style:"american-political-science-association")