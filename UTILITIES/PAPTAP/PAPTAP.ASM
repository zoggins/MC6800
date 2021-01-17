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
 		    ORG		$9000
           
PIABDR	    EQU		$801E		PIA IN SLOT 7, DATA REGISTER OF PORT B
PIABCR      EQU		$801F		PIA IN SLOT 7, CONTROL REGISTER OF PORT B

OUTCH       EQU     $E1D1       OUTPUT CHARACTER ROUTINE

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

CHKCHK      INC     CHKSUM      CHECK THE CHECKSUM      
            BEQ     START       GO TO NEXT LINE
            LDA A   #'!
            JSR     OUTCH
            SWI                 FAILED CHECK SUM, SO INTERRUPT

*********** PIASUP - PIA SETUP ROUTINE
PIASUP      LDA A   #$32        C1 SET ON RISING EDGE OF RDY & ACK=0
            STA A   PIABCR      SET CRB
            CLR A
            STA A   PIABDR      SET DDRB = ALL INPUTS
            LDA A   #$3E        RAISE ACK ON C2 (RESET RDY ON C1)
            STA A   PIABCR      SET CRB
            RTS                 AND LEAVE...

*********** PIADAT - GET DATA FROM PIA
PIADAT      LDA A   #$36        C1 SET ON RISING EDGE OF RDY & ACK=0
            STA A   PIABCR      SET CRB
DATLOP      LDA A   PIABCR      GET RDY ON C1 
            BMI     GETDAT      DATA PRESENT? (BIT 7 == 1)
            BRA     DATLOP      NOT YET. KEEP TRYING.
GETDAT      LDA A   PIABDR      YES. GET THE DATA,
            JSR     OUTCH       PRINT IT OUT
            PSH A               AND SAVE IT.
            LDA A   #$3E        RAISE ACK ON C2 (RESET RDY ON C1)
            STA A   PIABCR         
            PUL A               PUT DATA BACK IN REGISTER
            RTS                 AND LEAVE...

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

NUMBYT      RMB     1           BYTES LEFT TO READ
TMPADDR1    RMB     1           TEMP ADDRESS POINTER
TMPADDR2    RMB     1
CHKSUM      RMB     1           RUNNING CHECKSUM

            END