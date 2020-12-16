******************************
* Demo of PIA input and output
* using switches and a speaker
*
* Schematic provided in folder
* 
* Adapted from the demo in the
* KIM-1 manual.
*
******************************
		ORG		$0100
PIABFA	EQU		$801C		# PIA IN SLOT 7
PIACRA	EQU		$801D
PIAINIT	LDA A	PIACRA
		AND A	#%11111011	# Enable DDR access
		STA A	PIACRA
		LDA A	#%00000001	# PA7-1 Input, PA0 Output
		STA A	PIABFA
		ORA A   #%00000100	# Disable DDR access
		STA A	PIACRA
START	INC		PIABFA
		LDA B   PIABFA
		COM B
		LSR B
DELAY	DEC B
		BPL		DELAY
		BMI		START		
		END