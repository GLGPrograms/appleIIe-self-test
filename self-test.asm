; ********************************************************************************
; * Apple II                                                                     *
; * CD-ROM DUMP                                                                  *
; * Self-test code                                                               *
; *                                                                              *
; * Copyright 1978 by Apple Computer, Inc.                                       *
; * All Rights Reserved                                                          *
; *                                                                              *
; ********************************************************************************
; * This is a disassembly of the original Apple //e CD-ROM.                      *
; ********************************************************************************
; * Project created by giuliof from RetrOfficina GLG Programs, using             *
; * virtual 6502, references from 6502.org and 6502disassembly.com,              *
; * and some pieces of paper                                                     *
; * Created 2021/12/12                                                           *
; ********************************************************************************

 
                   SPEAKER  .eq $C030 ; Toggle speaker
                   SWIOAK   .eq $C061 ; Open-Apple Key
                   SWISAK   .eq $C062 ; Solid-Apple Key
 
                   INIT     .eq $FB2F
                   HOME     .eq $FC58 ; 
                   CROUT    .eq $FD8E ; output CR
                   PRHEX    .eq $FDE3
 
                   BNKRO11  .eq $C080 ; Read RAM, no write,  bank 2
                   BNKRW01  .eq $C081 ; Read ROM, write RAM, bank 2
                   BNKRO01  .eq $C082 ; Read ROM, no write,  bank 2
                   BNKRW11  .eq $C083 ; Read RAM, write RAM, bank 2
                   BNKRO10  .eq $C088 ; Read RAM, no write,  bank 1
                   BNKRW00  .eq $C089 ; Read ROM, write RAM, bank 1
                   BNKRO00  .eq $C08A ; Read ROM, no write,  bank 1
                   BNKRW10  .eq $C08B ; Read RAM, write RAM, bank 1
                   RDBNK2ST .eq $C011 ; bit 7 is set if bank 2 is selected, else bank 1
                   RDRAMST  .eq $C012 ; bit 7 is set if reading RAM, else reading ROM 
 
                   RAMRDSW0 .eq $C002 ; Read main memory
                   RAMRDSW1 .eq $C003 ; Read auxiliary memory
                   RAMRDST  .eq $C013 ; Status in bit 7
 
                   RAMWRSW0 .eq $C004 ; Write main memory
                   RAMWRSW1 .eq $C005 ; Write auxiliary memory
                   RAMWRST  .eq $C014 ; Write main memory
 
                   C1ROMSW0 .eq $C006 ; Enable slot ROM from $C100-$CFFF
                   C1ROMSW1 .eq $C007 ; Enable main ROM from $C100-$CFFF
                   C1ROMST  .eq $C015 ; Read C1ROM switch
 
                   ALTZPSW0 .eq $C008 ; ALTZP: use main stack and zp
                   ALTZPSW1 .eq $C009 ; ALTZP: use auxiliary stack and zp
                   ALTZPST  .eq $C016 ; Read ALTZP switch
 
                   C3ROMSW0 .eq $C00A ; Enable main ROM from $C300-$C3FF
                   C3ROMSW1 .eq $C00B ; Enable slot ROM from $C300-$C3FF
                   C3ROMST  .eq $C017 ; 
                   
                   STO80SW0 .eq $C000 ; 80STORE: use RAMRD, RAMWR
                   STO80SW1 .eq $C001 ; 80STORE: access display page
                   STO80ST  .eq $C018 ; 80Store: Read 80Store Switch.
 
                   TEXTSW0  .eq $C050 ; Text: Text mode off, graghics on.
                   TEXTSW1  .eq $C051 ; Text: Text mode on, graghics on.
                   TEXTST   .eq $C01A ; Text: Read text/graphics switch.
 
                   MIXEDSW0 .eq $C052 ; Mixed: Mixed text/graphics mode off.
                   MIXEDSW1 .eq $C053 ; Mixed: Mixed text/graphics mode on. Applicable only in graphics mode.
                   MIXEDST  .eq $C01B ; Mixed: Read mixed text/graphics switch.
 
                   PAGE2SW0 .eq $C054 ; Page2: Display page one.
                   PAGE2SW1 .eq $C055 ; Page2: Display page two.
                   PAGE2ST  .eq $C01C ; Page2: Read page display switch.
 
                   HIRESSW0 .eq $C056 ; HiRes: Hi-res mode off.
                   HIRESSW1 .eq $C057 ; HiRes: Hi-res mode on.
                   HIRESST  .eq $C01D ; HiRes: Read HiRes switch.
 
                   ALTCHSW0 .eq $C00E ; AltCharSet: Primary character set
                   ALTCHSW1 .eq $C00F ; AltCharSet: Alternate character set off
                   ALTCHST  .eq $C01E ; AltCharSet: Read AltCharSet switch.
 
                   COL80SW0 .eq $C00C ; 80Col: 80-column display off
                   COL80SW1 .eq $C00D ; 80Col: 80-column display on.
                   COL80ST  .eq $C01F ; 80Col: Read 80 column switch.
 
                   CDCHK    .eq $C400 ; Checksum for CD-ROM
                   EFCHK    .eq $F7FF ; Checksum for EF-ROM
 
                   CHECKFLG .eq $C7EE ; Default switches status (from $C011 to $C018)
                   ERRARR   .eq $C750 ; Errors string list


;;;;;;;;;;;;;;;;;
;; ENTRYPOINT  ;;
;;;;;;;;;;;;;;;;;

C401   AD 61 C0             LDA SWIOAK       ; Switch Input 0 or Open-Apple Key
C404   85 05                STA $05
C406   A2 FF                LDX #$FF         ; Reset the...
C408   9A                   TXS              ; ...stack pointer
C409   A9 F0                LDA #$F0         ; Loads...
C40B   85 36                STA $36          ; ...$FDF0 (COUT1)...
C40D   A9 FD                LDA #$FD         ; ...in...
C40F   85 37                STA $37          ; ...$0037:$0036
C411   AD 82 C0             LDA BNKRO01      ; Bank switch: ROM read, no write, bank 2
C414   20 58 FC             JSR HOME
C417   A9 00                LDA #$00
C419   85 09                STA $09          ; "boolean value" used to print "MMU: " once in MMUIOUERR.
                                             ; If != 0 means that a failure occurred in MMU
C41B   85 0A                STA $0A          ; "boolean value" used to print "IOU: " once in MMUIOUERR
                                             ; If != 0 means that a failure occurred in IOU
C41D   85 08                STA $08          ; nMMU/IOU test flag: 0 if checking MMU, #$FF if checking IOU
C41F   AA                   TAX              ; Clear X

;;;;;;;;;;;;;;;;;
;; TEST 0: MMU ;;
;;;;;;;;;;;;;;;;;

;; Check default values of MMU-related switches (RDBNK2ST-C018).
;; X is used both as displacement from RDBNK2ST address and test step counter.
;; If a failure in MMU is detected, X is printed on screen (in MMUIOUERR routine)
;; to make troubleshooting easier.
;; Test indexes: 0 to 7

C420   BD 11 C0   LC420     LDA RDBNK2ST,X   ; Load switch value (bit 7)
C423   5D EE C7             EOR CHECKFLG,X   ; Mask with default value
C426   10 03                BPL LC42B        ; Bit7=0 
C428   20 13 C5             JSR MMUIOUERR    ;
C42B   E8         LC42B     INX              ; increase test step
C42C   E0 08                CPX #$08
C42E   D0 F0                BNE LC420

;; Check if MMU-related switches do their job
;; (i.e. move the switch, read its status, put it back)

;; Test index: 8
C430   8D 8B C0             STA BNKRW10      ; Set bank 1 (and RAM read and write)
C433   2C 11 C0             BIT BANKST       ; Load switch
C436   8D 83 C0             STA BNKRW11      ; Set back bank 2
C439   10 03                BPL LC43E        ; Check if bank 1 (switch cleared)
C43B   20 13 C5             JSR MMUIOUERR    ;
C43E   E8         LC43E     INX              ; Next test step

;; Test index: 9
C43F   8D 80 C0             STA BNKRO11      ; Set read RAM
C442   2C 12 C0             BIT RDRAMST      ; Load switch
C445   8D 82 C0             STA BNKRO01      ; Set back read ROM
C448   30 03                BMI LC44D        ; Check if RAM read (switch set)
C44A   20 13 C5             JSR MMUIOUERR
C44D   E8         LC44D     INX              ; Next test step

;; Test index: A
C44E   8D 03 C0             STA RAMRDSW1     ; Set read auxiliary memory
C451   2C 13 C0             BIT RAMRDST      ; Load switch
C454   8D 02 C0             STA RAMRDSW0     ; Put back read main memory
C457   30 03                BMI LC45C        ; Check if read auxiliary memory
C459   20 13 C5             JSR MMUIOUERR    ;
C45C   E8         LC45C     INX              ; Next test step

;; Test index: B
C45D   8D 05 C0             STA RAMWRSW1     ; Set write auxiliary memory
C460   2C 14 C0             BIT RAMWRST      ; Load switch
C463   8D 04 C0             STA RAMWRSW0     ; Put back write main memory
C466   30 03                BMI LC46B        ; Check if write auxiliary memory
C468   20 13 C5             JSR MMUIOUERR    ;
C46B   E8         LC46B     INX              ; Next test step

;; Test index: C
C46C   8D 09 C0             STA ALTZPSW1     ; Set use auxiliary stack and zp
C46F   2C 16 C0             BIT ALTZPST      ; Load switch
C472   8D 08 C0             STA ALTZPSW0     ; Put back use main stack and zp
C475   30 03                BMI LC47A        ; Check if auxiliary stack and zp
C477   20 13 C5             JSR MMUIOUERR    ;
C47A   E8         LC47A     INX              ; Next test step

;; Test index: D
C47B   8D 0B C0             STA C3ROMSW1     ; Set slot ROM enabled
C47E   2C 17 C0             BIT C3ROMST      ; Load switch
C481   8D 0A C0             STA C3ROMSW0     ; Put back main ROM enabled
C484   30 03                BMI LC489        ; Check if slot ROM enabled
C486   20 13 C5             JSR MMUIOUERR    ;
C489   E8         LC489     INX              ; Next test step

;; Test index: E
C48A   8D 01 C0             STA STO80SW1     ; Set access display page
C48D   2C 18 C0             BIT STO80ST      ; Load switch
C490   8D 00 C0             STA STO80SW0     ; Put back use RAMRD, RAMWRT
C493   30 03                BMI LC498        ; Chck if access display page
C495   20 13 C5             JSR MMUIOUERR    ;
C498   20 8E FD   LC498     JSR CROUT        ;
;; End of MMU tests

;;;;;;;;;;;;;;;;;
;; TEST 1: IOU ;;
;;;;;;;;;;;;;;;;;

C49B   A2 00                LDX #$00         ; Reset test index
C49D   A9 FF                LDA #$FF
C49F   85 08                STA $08          ; nMMU/IOU test flag

;; Check default values of IOU-related switches (TEXTST-COL80ST).
;; X is used both as displacement from TEXTST address and test step counter.
;; If a failure in IOU is detected, X is printed on screen (in MMUIOUERR routine)
;; to make troubleshooting easier.
;; Test indexes: 0 to 5

C4A1   BD 1A C0   LC4A1     LDA TEXTST,X     ; Load switch value (bit 7)
C4A4   5D F6 C7             EOR $C7F6,X      ; Mask with default value
C4A7   10 03                BPL LC4AC        ; Bit7=0 
C4A9   20 13 C5             JSR MMUIOUERR    ;
C4AC   E8         LC4AC     INX              ; increase test step
C4AD   E0 06                CPX #$06
C4AF   D0 F0                BNE LC4A1

;; Test index: 6
C4B1   8D 0D C0             STA COL80SW1     ; Set 80-column display on.   
C4B4   2C 1F C0             BIT COL80ST      ; Load switch  
C4B7   8D 0C C0             STA COL80SW0     ; Put back 80-column display off
C4BA   30 03                BMI LC4BF        ; Check if 80-display was on 
C4BC   20 13 C5             JSR MMUIOUERR    ;                                 
C4BF   E8         LC4BF     INX              ; Next test step                                 

;; Test index: 7
C4C0   8D 0F C0             STA ALTCHSW1     ; Set alternate character set
C4C3   2C 1E C0             BIT ALTCHST      ; Load switch
C4C6   8D 0E C0             STA ALTCHSW0     ; Put back primary character set
C4C9   30 03                BMI LC4CE        ; Check if alternate character set was on    
C4CB   20 13 C5             JSR MMUIOUERR    ; 
C4CE   E8         LC4CE     INX              ; Next test step    

;; Test index: 8
C4CF   8D 50 C0             STA TEXTSW0      ; Set text mode off
C4D2   2C 1A C0             BIT TEXTST       ; Load switch
C4D5   8D 51 C0             STA TEXTSW1      ; Put back text mode on
C4D8   10 03                BPL LC4DD        ; Check if text mode was off
C4DA   20 13 C5             JSR MMUIOUERR    ;
C4DD   E8         LC4DD     INX              ; Next test step

;; Test index: 9
C4DE   8D 55 C0             STA PAGE2SW1     ; Set display page two.
C4E1   2C 1C C0             BIT PAGE2ST      ; Load switch
C4E4   8D 54 C0             STA PAGE2SW0     ; Put back display page one.
C4E7   30 03                BMI LC4EC        ; Check if was display page one
C4E9   20 13 C5             JSR MMUIOUERR    ;
C4EC   E8         LC4EC     INX              ; Next test step

;; Test index: A
C4ED   8D 53 C0             STA MIXEDSW1     ; Set mixed mode
C4F0   2C 1B C0             BIT MIXEDST      ; Load switch
C4F3   8D 52 C0             STA MIXEDSW0     ; Put back mixed mode off
C4F6   30 03                BMI LC4FB        ; Check if mixed mode was on
C4F8   20 13 C5             JSR MMUIOUERR    ;
C4FB   E8         LC4FB     INX              ; Next test step

;; Test index: B
C4FC   8D 57 C0             STA HIRESSW1     ; Set hi-res mode on.
C4FF   2C 1D C0             BIT HIRESST      ; Load switch
C502   8D 56 C0             STA HIRESSW0     ; Put back hi-res mode off
C505   30 03                BMI LC50A        ; Check if hi-res mode was on
C507   20 13 C5             JSR MMUIOUERR    ;

;; End of MMU/IOU tests.
;; Single steps are not blocking, but if at least one MMU/IOU failure is detected,
;; test stops here
C50A   A5 09      LC50A     LDA $09          ; Do not go further if...
C50C   05 0A                ORA $0A          ; ... MMU/IOU has failed...
C50E   F0 2F                BEQ LC53F        ; ...else go to next test
C510   4C 10 C5   LC510     JMP LC510        ; Die here.

;; Routine that prints MMU or IOU flag error
C513   86 04      MMUIOUERR STX $04          ; Momentarily store error index in RAM
C515   A5 08                LDA $08          ; Check if MMU error (0) or IOU error (not 0)
C517   D0 0D                BNE LC526
C519   A5 09                LDA $09          ; MMU ERROR, check if first one...
C51B   D0 14                BNE LC531        ; ... else directly print the error step
C51D   A2 44                LDX #$44         ; "MMU FLAG E4 "
C51F   20 40 C7             JSR PRINTERR
C522   E6 09                INC $09          ; Set $09 to 1. Do not print "MMU FLAG E4 " anymore
C524   D0 0B                BNE LC531        ; Always taken, go to error index print
C526   A5 0A      LC526     LDA $0A          ; IOU ERROR, check if first one...
C528   D0 07                BNE LC531        ; ... else directly print the error step
C52A   A2 51                LDX #$51         ; "IOU FLAG E5 "
C52C   20 40 C7             JSR PRINTERR
C52F   E6 0A                INC $0A          ; Set $0A to 1. Do not print "IOU FLAG E5 " anymore
C531   A5 04      LC531     LDA $04          ; Recover the error index from RAM...
C533   20 E3 FD             JSR PRHEX        ; ... and print it
C536   A9 A0                LDA #$A0         ; Add a space
C538   20 F0 FD             JSR COUT1        ;
C53B   A5 04                LDA $04          ; Recover the status of...
C53D   AA                   TAX              ; ...X register
C53E   60                   RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TEST 2: ROM checksum ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; CD-ROM checksum.
;; 8-bit sum of all ROM locations (excluding address CDCHK) is compared with content of address CDCHK
C53F   A9 C1      LC53F     LDA #$C1         ; ROM base address is...
C541   85 01                STA $01          ; ...loaded into...
C543   A9 00                LDA #$00         ; ...$0001:$0000....
C545   85 00                STA $00          ; ...
C547   A8                   TAY              ; Y register is cleared
C548   18         LC548     CLC              ; Checksum cycle
C549   71 00                ADC ($00),Y      ; 
C54B   C8                   INY              ; When Y is 0...
C54C   D0 FA                BNE LC548        ; ...then...
C54E   E6 01                INC $01          ; ...turn ROM address page
C550   A6 01                LDX $01          ; 
C552   E0 C4                CPX #$C4         ; 
C554   D0 03                BNE LC559        ; Skip sum of CDCHK...
C556   C8                   INY              ; ...go to CDCHK+1
C557   D0 EF                BNE LC548        ; Always taken
C559   E0 E0      LC559     CPX #$E0         ; Stop at E000
C55B   F0 02                BEQ LC55F        ;
C55D   D0 E9                BNE LC548        ;
C55F   CD 00 C4   LC55F     CMP CDCHK        ; Compare checksum with CDCHK
C562   F0 08                BEQ LC56C        ; If ok, go to next test, else...
C564   A2 00                LDX #$00         ; Print "ROM:E8" error
C566   20 40 C7             JSR PRINTERR     
C569   4C 69 C5   LC569     JMP LC569        ; Then die here.

;; EF-ROM checksum.
;; 8-bit sum of all ROM locations (excluding address EFCHK) is compared with content of address EFCHK.
;; Note: $0001:$0000 already points to $E000.
C56C   A0 00      LC56C     LDY #$00         ;
C56E   98                   TYA              ; Clear A
C56F   18         LC56F     CLC              ; Checksum cycle
C570   71 00                ADC ($00),Y      ;
C572   C8                   INY              ; When Y is 0...
C573   F0 0B                BEQ LC580        ; ...then jump to turn ROM address page...
C575   C0 FF                CPY #$FF         ; ...else check if...
C577   D0 F6                BNE LC56F        ;
C579   A6 01                LDX $01          ; ...($00),Y is pointing to EFCHK...
C57B   E0 F7                CPX #$F7         ;
C57D   D0 F0                BNE LC56F        ;
C57F   C8                   INY              ; ... and skip it from checksum.
C580   E6 01      LC580     INC $01          ;
C582   D0 EB                BNE LC56F        ; If $01 is 0, test is finished...
C584   CD FF F7             CMP EFCHK        ; ... compare checksum with CDCHK
C587   F0 08                BEQ LC591        ; If ok, go to next test, else...
C589   A2 08                LDX #$08         ; Print "ROM:E10" error
C58B   20 40 C7             JSR PRINTERR       
C58E   4C 8E C5   LC58E     JMP LC58E        ; Then die here.


;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TEST 2: RAM TEST     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; First write pass. Write #$00 in whole RAM (64k).
;; $C000-$CFFF is statically mapped to ROM
;; $D000-$DFFF can be bank switched, so same area is written two times, switching BNKRW10-BNKRW11
C591   AD 50 C0   LC591     LDA TEXTSW0      ; 
C594   AD 57 C0             LDA HIRESSW1     ; Enable Hi-Res mode
C597   AD 52 C0             LDA MIXEDSW0     ; Disable mixed text/graphics mode
C59A   AD 83 C0             LDA BNKRW11      ; Bank switch:
C59D   AD 83 C0             LDA BNKRW11      ; Read/write RAM, bank 2
C5A0   A9 01                LDA #$01         ; Store "true" flag...
C5A2   85 04                STA $04          ; ...in $04
C5A4   A9 FF                LDA #$FF         ;
C5A6   85 03                STA $03          ; Valore FF di appoggio
C5A8   A9 00                LDA #$00
C5AA   AA                   TAX
C5AB   85 00                STA $00
C5AD   85 01                STA $01          ; Load $0000 in $0001:0000
C5AF   A0 06                LDY #$06         ; Skip first 6 RAM locations
C5B1   91 00      LC5B1     STA ($00),Y      ; Write 0 in RAM
C5B3   C8                   INY
C5B4   D0 FB                BNE LC5B1
C5B6   24 05                BIT $05          ; TODO: seems that if solid apple is not pressed
C5B8   10 03                BPL LC5BD        ; TODO: when test is launched, speaker is toggled
C5BA   8D 30 C0             STA SPEAKER      ; TODO: for each RAM page
C5BD   E6 01      LC5BD     INC $01          ; Turn RAM page
C5BF   F0 2A                BEQ LC5EB        ; Reached end of RAM
C5C1   A5 01                LDA $01
C5C3   C9 C0                CMP #$C0         ; Skip $Cxxx...
C5C5   D0 06                BNE LC5CD        ; from test...
C5C7   A9 D0                LDA #$D0         ; and jumpt to...
C5C9   85 01                STA $01          ; $D0xx
C5CB   30 1B                BMI LC5E8        ; then go on.
C5CD   C9 E0      LC5CD     CMP #$E0
C5CF   D0 17                BNE LC5E8
C5D1   2C 11 C0             BIT BANKST       ; Check if Bank 2 or 1
C5D4   10 0C                BPL LC5E2        ; if bank 1, switch back to bank 2 and go on with $Exxx
C5D6   AD 8B C0             LDA BNKRW10      ; Bank switch:
C5D9   AD 8B C0             LDA BNKRW10      ; read and write in RAM, use bank 1
C5DC   A9 D0                LDA #$D0         ; Move back page pointer...
C5DE   85 01                STA $01          ; ... to $D000
C5E0   30 06                BMI LC5E8        ; Always taken
C5E2   AD 83 C0   LC5E2     LDA BNKRW11      ; Bank switch:
C5E5   AD 83 C0             LDA BNKRW11      ; read and write in RAM, use bank 2
C5E8   8A         LC5E8     TXA              ; Put X (0) in A, reset
C5E9   F0 C6                BEQ LC5B1        ; keep testing another RAM page

;; Check and second write pass. Write #$FF in whole RAM (64k).
C5EB   85 02      LC5EB     STA $02          ; Put the testing value (0) in $0002
C5ED   49 FF                EOR #$FF         ; Toggle the testing value...
C5EF   AA                   TAX              ; ... and store in X
C5F0   A9 00      LC5F0     LDA #$00         ; Clear the...
C5F2   85 01                STA $01          ; RAM page counter
C5F4   A0 06                LDY #$06         ; Skip first 6 RAM locations
C5F6   24 05      LC5F6     BIT $05          ; TODO
C5F8   10 03                BPL LC5FD        ; TODO
C5FA   8D 30 C0             STA SPEAKER      ; TODO
C5FD   C6 04      LC5FD     DEC $04          ; Toggle flag to 0
C5FF   B1 00                LDA ($00),Y      ; Read back RAM
C601   C5 02                CMP $02          ; Check if matches the testing value...
C603   F0 03                BEQ LC608
C605   4C AF C6             JMP RAMFAIL      ; ... else print error and end test ($04 = 0)
C608   E6 04      LC608     INC $04          ; Toggle flag to 1
C60A   8A                   TXA              ; write complemented test value (FF)...
C60B   91 00                STA ($00),Y      ; ... in current RAM location...
C60D   D1 00                CMP ($00),Y      ; ... then compare with test value
C60F   F0 03                BEQ LC614
C611   4C AF C6             JMP RAMFAIL      ; If check fails, print error and end test ($04 = 1)
C614   C8         LC614     INY              ; Next memory location...
C615   D0 DF                BNE LC5F6        ; ... until end of page is reached...
C617   E6 01                INC $01          ; ... else turn page.
C619   F0 2A                BEQ LC645        ; Reached end of RAM
C61B   A5 01                LDA $01
C61D   C9 C0                CMP #$C0         ; Skip $Cxxx...
C61F   D0 06                BNE LC627        ; from test...
C621   A9 D0                LDA #$D0         ; and jumpt to...
C623   85 01                STA $01          ; $Dxxx
C625   30 CF                BMI LC5F6        ; then go on.
C627   C9 E0      LC627     CMP #$E0
C629   D0 CB                BNE LC5F6
C62B   2C 11 C0             BIT BANK         ; Check if Bank 2 or 1
C62E   10 0C                BPL LC63C        ; if bank 1, switch back to bank 2 and go on with $Exxx
C630   AD 8B C0             LDA BNKRW10      ; BANK SWITCH:
C633   AD 8B C0             LDA BNKRW10      ; Read twice: read and write in RAM, use bank 1
C636   A9 D0                LDA #$D0         ; Move back page pointer...
C638   85 01                STA $01          ; ... to $D000
C63A   30 BA                BMI LC5F6        ; Always taken
C63C   AD 83 C0   LC63C     LDA BNKRW11      ; BANK SWITCH:
C63F   AD 83 C0             LDA BNKRW11      ; Read twice: read and write in RAM, use bank 2
C642   4C F6 C5             JMP LC5F6

; Check, third write in reverse direction and next check
C645   85 02      LC645     STA $02          ; Put the testing value (FF) in $0002
C647   49 FF                EOR #$FF         ; Toggle the testing value...
C649   AA                   TAX              ; ... and store in X
C64A   F0 A4                BEQ LC5F0
C64C   A9 FF      LC64C     LDA #$FF         ; Set the...
C64E   85 01                STA $01          ; RAM page counter to FF
C650   A8                   TAY
C651   24 05      LC651     BIT $05          ; TODO
C653   10 03                BPL LC658        ; TODO
C655   8D 30 C0             STA SPEAKER      ; TODO
C658   C6 04      LC658     DEC $04          ; Toggle flag to 0
C65A   B1 00                LDA ($00),Y      ; Read back RAM
C65C   C5 02                CMP $02          ; Check if matches the testing value...
C65E   D0 4F                BNE RAMFAIL      ; ... else print error and end test ($04 = 0)
C660   E6 04                INC $04          ; Toggle flag to 1
C662   8A                   TXA              ; write complemented test value (FF)...
C663   91 00                STA ($00),Y      ; ... in current RAM location...
C665   D1 00                CMP ($00),Y      ; ... then compare with test value
C667   D0 46                BNE RAMFAIL      ; If check fails, print error and end test ($04 = 1)
C669   88                   DEY              ; Next RAM location
C66A   C4 03                CPY $03          ; Check if is reached the end of page
C66C   D0 E3                BNE LC651        ;
C66E   C6 01                DEC $01          ; Turn page
C670   A5 01                LDA $01          ; Check if...
C672   C9 FF                CMP #$FF         ; ..last page...
C674   F0 2D                BEQ LC6A3        ; ... then test end
C676   C9 CF                CMP #$CF         ; Skip $Cxxx...
C678   D0 1D                BNE LC697        ; from test
C67A   2C 11 C0             BIT BANK         ; Check if Bank 2 or 1
C67D   10 0C                BPL LC68B        ; if bank 1, switch back to bank 2 and go on with $Exxx
C67F   AD 8B C0             LDA BNKRW10      ; BANK SWITCH:
C682   AD 8B C0             LDA BNKRW10      ; Read twice: read and write in RAM, use bank 1
C685   A9 DF                LDA #$DF         ; Move back page pointer...
C687   85 01                STA $01          ; ... to $DFxx
C689   30 C6                BMI LC651        ; Always taken
C68B   AD 83 C0   LC68B     LDA BNKRW11      ; BANK SWITCH:
C68E   AD 83 C0             LDA BNKRW11      ; Read twice: read and write in RAM, use bank 2
C691   A9 BF                LDA #$BF         ; Move back page pointer...
C693   85 01                STA $01          ; ... to $BFxx
C695   30 BA                BMI LC651        ; Always taken
C697   C9 00      LC697     CMP #$00         ; If page zero.....
C699   F0 02                BEQ LC69D        ; Why...
C69B   D0 B4                BNE LC651        ; ...this??
C69D   A9 06      LC69D     LDA #$06         ; remember to skip first 6 bytes!
C69F   85 03                STA $03          ;
C6A1   D0 AE                BNE LC651        ; always taken. Start back memory testing from 00FF to 0006
C6A3   8A         LC6A3     TXA              ;
C6A4   F0 71                BEQ LC717        ; Test is finished when A == 0
C6A6   85 02                STA $02          ; Else, set page pointer to $FFFF
C6A8   85 03                STA $03          ;
C6AA   49 FF                EOR #$FF         ; Clear A and...
C6AC   AA                   TAX              ; ... move in X (testing value)
C6AD   F0 9D                BEQ LC64C        ; Always taken
;; END OF RAM TEST

;; Routine that prints RAM mem test error
;; Prints the position of the broken chip (F6-F13)
;; Memory chips are 64Kx1bit, parallel-assembled to make a one byte word.
;; If read value is different than written value, a simple XOR operation allows to detect the
;; defective IC.
C6AF   AD 82 C0   RAMFAIL   LDA BNKRO01      ; Bank switch: read ROM, no write,  bank 2
C6B2   20 E3 C7             JSR INITHOME
C6B5   AD 51 C0             LDA TEXTSW1      ; Turn on text mode
C6B8   A2 11                LDX #$11         ; "RAM:"
C6BA   20 40 C7             JSR PRINTERR
C6BD   A5 04                LDA $04          ; Is 0 is $02 = value written. Is 1 if $02 = ~value written
C6BF   F0 0B                BEQ LC6CC        ;
C6C1   A5 02                LDA $02          ; Load ~testing value in A
C6C3   49 FF                EOR #$FF         ; Complement it
C6C5   51 00                EOR ($00),Y      ; Find wrong bits
C6C7   85 06                STA $06          ;
C6C9   4C D2 C6             JMP LC6D2
C6CC   A5 02      LC6CC     LDA $02          ; Load testing value in A
C6CE   51 00                EOR ($00),Y      ; Find wrong bits
C6D0   85 06                STA $06
;; $06 now contains a bit mask: i-th bit set = i-th RAM module is broken
C6D2   A5 06      LC6D2     LDA $06
C6D4   0A                   ASL A
C6D5   90 05                BCC LC6DC
C6D7   A2 20                LDX #$20         ; "F13 "
C6D9   20 40 C7             JSR PRINTERR
C6DC   0A         LC6DC     ASL A
C6DD   90 05                BCC LC6E4
C6DF   A2 25                LDX #$25         ; "F12 "
C6E1   20 40 C7             JSR PRINTERR
C6E4   0A         LC6E4     ASL A
C6E5   90 05                BCC LC6EC
C6E7   A2 2A                LDX #$2A         ; "F11 "
C6E9   20 40 C7             JSR PRINTERR
C6EC   0A         LC6EC     ASL A
C6ED   90 05                BCC LC6F4
C6EF   A2 2F                LDX #$2F         ; "F10 "
C6F1   20 40 C7             JSR PRINTERR
C6F4   0A         LC6F4     ASL A
C6F5   90 05                BCC LC6FC
C6F7   A2 34                LDX #$34         ; "F9 "
C6F9   20 40 C7             JSR PRINTERR
C6FC   0A         LC6FC     ASL A
C6FD   90 05                BCC LC704
C6FF   A2 38                LDX #$38         ; "F8 "
C701   20 40 C7             JSR PRINTERR
C704   0A         LC704     ASL A
C705   90 05                BCC LC70C
C707   A2 3C                LDX #$3C         ; "F7 "
C709   20 40 C7             JSR PRINTERR
C70C   0A         LC70C     ASL A
C70D   90 05                BCC LC714
C70F   A2 40                LDX #$40         ; "F6 "
C711   20 40 C7             JSR PRINTERR
C714   4C 14 C7   LC714     JMP LC714        ; Die here


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Test ended succesfully ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Recover default settings, print "KERNEL OK" and wait for reset
C717   AD 82 C0   LC717     LDA BNKRO01      ; BANK SWITCH: read ROM, no write
C71A   20 E3 C7             JSR INITHOME
C71D   AD 51 C0             LDA TEXTSW1      ; Text mode on, graghics on.
C720   AD 61 C0             LDA SWIOAK       ; Open-Apple Key status
C723   2D 62 C0   LC723     AND SWISAK       ; Solid-Apple Key status
C726   30 08                BMI TRMPL        ; If both key are pressed, jump to trampoline routine
C728   A2 16                LDX #$16         ; "KERNEL OK"
C72A   20 40 C7             JSR PRINTERR     ;
C72D   4C 2D C7   LC72D     JMP LC72D        ; Die here

; Loads INJECT code into $0100-0135, then executes it
C730   A2 00      TRMPL     LDX #$00
C732   BD AE C7   LC732     LDA INJECT,X
C735   9D 00 01             STA $0100,X
C738   E8                   INX
C739   E0 35                CPX #$35         ; Injected code is 0x35 bytes long
C73B   D0 F5                BNE LC732
C73D   4C 00 01             JMP $0100        ; Jump to injected code

;; PRINTERR
;; Routine that prints an error code indexed by X, taking string from ERRARR ($C750)
C740   85 07      PRINTERR  STA $07          ; Save A content
C742   BD 50 C7   LC742     LDA ERRARR,X     ; Load characters until...
C745   F0 06                BEQ LC74D        ; ... null terminator
C747   20 F0 FD             JSR COUT1        ; Print character in A
C74A   E8                   INX              ;
C74B   D0 F5                BNE LC742        ; Always taken, unless string is longer than 255 characters
C74D   A5 07      LC74D     LDA $07          ; Restore A
C74F   60                   RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ERRARR (binary data (error strings) ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; C750   "ROM:E8"
;; C757   "ROM:E10"
;; C760   "RAM: "
;; C765   "KERNEL OK"
;; C76F   "F13 "
;; C774   "F12 "
;; C779   "F11 "
;; C77E   "F10 "
;; C783   "F9 "
;; C787   "F8 "
;; C78B   "F7 "
;; C78F   "F6 "
;; C793   "MMU FLAG E4:"
;; C7A0   "IOU FLAG E5:"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TODO                                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; This code is copied into RAM, starting from $0100, then executed
;; TODO, understand what it does
C7AE   8D 06 C0   INJECT    STA C1ROMSW0
C7B1   8D FF CF             STA $CFFF       ; reset the slot ROM space (ref https://www.1000bit.it/support/manuali/apple/technotes/misc/tn.misc.03.html)
C7B4   A0 00                LDY #$00
C7B6   A9 C0                LDA #$C0
C7B8   85 01                STA $01
C7BA   A9 00                LDA #$00
C7BC   85 00                STA $00
C7BE   A0 90                LDY #$90
C7C0   B1 00      LC7C0     LDA ($00),Y
C7C2   91 00                STA ($00),Y
C7C4   C8                   INY
C7C5   D0 F9                BNE LC7C0
C7C7   E6 01                INC $01
C7C9   A5 01                LDA $01
C7CB   C9 D0                CMP #$D0
C7CD   D0 F1                BNE LC7C0
C7CF   A9 C0                LDA #$C0
C7D1   85 01                STA $01
C7D3   A0 79                LDY #$79
C7D5   B1 00      LC7D5     LDA ($00),Y
C7D7   88                   DEY
C7D8   D0 FB                BNE LC7D5
C7DA   8D 07 C0             STA C1ROMSW1
C7DD   8D 51 C0             STA TEXTSW1
C7E0   4C 01 C4             JMP $C401

;; INITHOME
C7E3   20 2F FB   INITHOME  JSR INIT
C7E6   A9 FF                LDA #$FF
C7E8   85 32                STA $32
C7EA   20 58 FC             JSR HOME
C7ED   60                   RTS


;; Default values of C011-C018 switches
C7EE   80         CHECKFLG  ??? ; RDBNK2ST: default is bank 2
C7EF   00                   BRK ; RDRAMST:  default is read from ROM
C7F0   00                   BRK ; RAMRDST:  default is read from main memory
C7F1   00                   BRK ; RAMWRST:  default is write to main memory
C7F2   80                   ??? ; C1ROMST:  default is main ROM
C7F3   00                   BRK ; ALTZPST:  default is use main stack and zp
C7F4   00                   BRK ; C3ROMST:  default is main ROM
C7F5   00                   BRK ; STO80ST:  default is use RAMRD, RAMWR

;; Default values of C01A-C01F switches
C7F6   80                   ??? ; TEXTST:  default is text on, graphics on
C7F7   00                   BRK ; MIXEDST: default is mixed test/graphics off
C7F8   00                   BRK ; PAGE2ST: deafult is display page one
C7F9   00                   BRK ; HIRESST: default is Hi-Res mode off
C7FA   00                   BRK ; ALTCHST: default is primary character set
C7FB   00                   BRK ; COL80ST: default is 80-column display off

;; Padding bytes?
C7FC   00                   BRK
C7FD   00                   BRK
C7FE   00                   BRK
C7FF   00                   BRK
