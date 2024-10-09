DRVREG	EQU	$8014		DRIVE REGISTER
COMREG	EQU	$8018		COMMAND REG 1771
TRKREG	EQU	$801A		TRACK REG 1771
SECREG	EQU	$801A		SECTOR REG 1771
DATREG	EQU	$801B		DATA REG 1771

	ORG	$0100

* Boot from Sector 1

GDISK	LDA B #1	BOOT FROM SECTOR 1
	BRA BDISK

FDISK	CLR B		BOOT FROM SECTOR 0

BDISK	EQU *
	LDAA	COMREG	TURN ON MOTOR
	CLR A		SELECT DRIVE 0
	STA A DRVREG	WRITE TO DRIVE SELECT REGISTER
	LDA A COMREG	READ COMREG TO ALLOW MOTOR TO START
	LDX   #$FFFF	WAIT FOR MOTOR TO START
GOWAIT	NOP		"
	NOP		"
	DEX		"
	BNE GOWAIT	"
	LDA A #$0B	ISSUE RESTORE COMMAND
	STA A COMREG	"
	BSR GDELAY	WAIT BEFORE READING STATUS REGISTER
GWAIT1	LDA A COMREG	WAIT FOR RESTORE TO COMPLETE
	AND A #1	"
	BNE GWAIT1	"
	STA B SECREG	SET SECTOR TO BOOT FROM
	LDA A #$9C	READ SECTOR COMMAND
	STA A COMREG	EXECUTE READ COMMAND
	BSR GDELAY	WAIT BEFORE READING STATUS REGISTER
	LDX #$2400	LOAD ADDRESS
GREAD	LDA A COMREG	READ STATUS REGISTER
	BIT A #2	CHECK FOR DRQ
	BNE GREAD1	YES= READ DATA
	BIT A #1	CHECK FOR BUSY
	BNE GREAD	YES = REPEAT LOOP
* 	BITA #sRDERR	GOOD READ?
* 	BEQ GJUMP	YES, JUMP TO LOADED CODE
*	LDX #NOLOAD	Boot Sector failed msg
*	JSR PDATA1	PRINT MESSAGE
*	JMP EOE3	Abort
GJUMP	JMP $2400	EXECUTE LOADED PROGRAM

GREAD1	LDA A DATREG	GET DATA
	STA A 0,X	STORE IT
	INX		BUMP LOAD POINTER TO NEXT LOCATION
	BRA GREAD	GET NEXT BYTE

GDELAY	BSR GDLY1	DELAY ROUTINE
GDLY1	BSR GDLY2
GDLY2	BSR GDLY3
GDLY3   BSR GDLY4
GDLY4   RTS
