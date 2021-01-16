NAM PAPTAP
 * HIGH SPEED PAPER TAPE LOADER PROGRAM
 * DEVELOPED BY DR. CHARLES ADAMS
 * TEXAS A&M UNIVERSITY
 *
 * MODIFIED BY CHRISTOPHER MALLERY
 * - Made it easier to grok
 * - Changed PIA routines to match what
 *   I understand.
 *
 		    ORG		$1F00
           
PIABFA	    EQU		$8018		PIA IN SLOT 6

CHKSUM      RMB     1           RUNNING CHECKSUM
NUMBYT      RMB     1           BYTES LEFT TO READ
TMPADDR1    RMB     1           TEMP ADDRESS POINTER
TMPADDR2    RMB     1

ENTER       BSR     PIASUP      INIT PIA
START       BSR     PIADAT      GET 1ST BYTE
            CMP A   #'S         IS IT AN S?
            BNE     START       IF NOT, START OVER
            BSR     PIADAT      GET 2ND BYTE
            CMP A   #$31        IS IT A 1?
            BNE     START       IF NOT, START OVER
            CLR     CHKSUM
            BSR     GETBYTE     GET THE BYTE COUNT
            SUB A   #2
            STA A   NUMBYT
            BSR     GETADDR     GET ADDRESS AND LOAD X

LOOP        BSR     GETBYTE     READ THE BYTES
            DEC     NUMBYT
            BEQ     CHKCHK      LAST BYTE IS CHECKSUM
            STA A   0,X
            INX
            BRA     LOOP

CHKCHK      COM     CHKSUM      CHECK THE CHECKSUM
            CMP A   CHKSUM      
            BEQ     START       GO TO NEXT LINE
            SWI                 FAILED CHECK SUM, SO INTERRUPT

*********** PIASUP - PIA SETUP ROUTINE
;PIASUP      LDX     #PIABFA
;            LDA A   #$32        KNOCK DOWN C2(RESET C1)
;            STA A   3,X         SET CRB
;            CLR A
;            STA A   1,X         RESET CRA
;            STA A   2,X         SET DDRB = ALL INPUTS
;            COM A
;            STA A   0,X         SET DDRA = ALL OUTPUTS
;            LDA A   #$3E        C1 SET ON A 0 TO 1, C2=1
;            STA A   3,X         SET CRB
;            LDA A   #$04        DUMMY FOR CRA
;            STA A   1,X         SET CRA
;            RTS                 AND LEAVE...
PIASUP      LDX     #PIABFA
            LDA A   #$00        CHANGE TO DIRECTION REGISTER  
            STA A   3,X         ON PORT B
            STA A   1,X         ON PORT A
            STA A   2,X         SET DDRB = ALL INPUTS
            LDA A   #$02        SET DDRA = 0 - INPUT, 1 - OUTPUT
            STA A   0,X 
            LDA A   #$04        CHANGE TO DATA REGISTER
            STA A   1,X         ON PORT A
            STA A   3,X         ON PORT B
            RTS

*********** PIADAT - GET DATA FROM PIA
;PIADAT      LDX     #PIABFA
;            LDA A   0,X         READ ADR AND
;            LDA A   2,X         BDR TO CLEAR CR FLAGS
;            LDA A   #$3E        C1 SET ON A 0 TO 1, C2=1
;            STA A   3,X         SET CRB
;DATLOP      LDA A   3,X         GET C1 FLAG(BIT 7)
;            BMI     GETDAT      DATA PRESENT?
;            BRA     DATLOP      NOT YET. KEEP TRYING.
;GETDAT      LDA A   2,X         YES. GET THE DATA
;            PSH A               AND SAVE IT.
;            LDA A   #$36        KNOCK DOWN C2(RESET C1)
;            STA A   3,X         SET CRB
;            PUL A               PUT DATA BACK IN REGISTER
;            RTS                 AND LEAVE...

PIADAT      LDX     #PIABFA
            LDA A   #$02        SET ACK
            STA A   0,X
DATLOP      LDA A   0,X         GET RDY
            AND A   #$02
            BNE     GETDAT
            BRA     DATLOP
GETDAT      LDA A   2,X
            JSR     $E1D1
            PSH     A
            LDA A   #$00
            STA A   0,X
            PUL A
            RTS

*********** GETBYTE - READ ASCII HEX BYTE (2 digits)
GETBYTE     BSR     A2H         GET FIRST CHARACTER TO HEX
            ASL     A           MOVE IT UP 4 BITS
            ASL     A
            ASL     A
            ASL     A
            TAB
            BSR     A2H         GET SECOND CHARACTER TO HEX
            ABA                 ADD THEM TOGETHER
            TAB
            ADD B   CHKSUM      ADD TO CHECKSUM
            STA B   CHKSUM
            RTS

*********** GETADDR - READ ADDRESS AND LOAD X
GETADDR     BSR     GETBYTE
            STA A   TMPADDR1
            BSR     GETBYTE
            STA A   TMPADDR2
            LDX     TMPADDR1
            RTS

*********** A2H - READ SINGLE ASCII BYTE AND CONVERT TO HEX
A2H         BSR     PIADAT      
            SUB A   #$30        
            CMP A   #09
            BLE     RT         
            SUB A   #7
RT          RTS

            END