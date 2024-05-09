TITLE Basic Math     (Proj1_934553922.asm)

; Author: Bach Xuan Phan (934553922)
; Last Modified: 10/21/2023
; OSU email address: phanx@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 1                Due Date: 10/22/2023
; Description: Using 3 numbers inputted by the user, perform basic arithmetic operations, which is adding and subtracting

INCLUDE Irvine32.inc

.data
 greeting		BYTE	"Basic Math by Bach Xuan Phan",0
 instructToUser	BYTE	"Enter 3 numbers in descending order A > B > C",0
 extraCredit3	BYTE	"**EC: Accept negative result and compute B - A, C - A, C - B, C - B - A",0
 extraCredit4	BYTE	"**EC: Divide A / B, A / C, B / C and show quotients, remainders",0
 goodbye		BYTE	"Thank you for using this program.",0
 numAAsk		BYTE	"Type in the number A: ",0
 numBAsk		BYTE	"Type in the number B: ",0
 numCAsk		BYTE	"Type in the number C: ",0
 addSign		BYTE	" + ",0
 subSign		BYTE	" - ",0
 divSign		BYTE	" / ",0
 equalSign		BYTE	" = ",0
 remainderSign	BYTE	" rem ",0
 numA			DWoRD	0
 numB			DWoRD	0
 numC			DWoRD	0
 aAddB			DWoRD	0
 aSubB			SDWoRD	0
 aAddC			DWoRD	0
 aSubC			SDWoRD	0
 bAddC			DWoRD	0
 bSubC			SDWoRD	0
 aAddBAddC		DWoRD	0
 bSubA			SDWoRD	0
 cSubA			SDWoRD	0
 cSubB			SDWoRD	0
 cSubBSubA		SDWoRD	0
 aDivBQuotient	DWoRD	0
 aDivBRemainder	DWoRD	0
 aDivCQuotient	DWoRD	0
 aDivCRemainder	DWoRD	0
 bDivCQuotient	DWoRD	0
 bDivCRemainder	DWoRD	0

.code
main PROC
  ; --------------------------------------------------
  ; Print introduction of program
  ; --------------------------------------------------
	MOV	EDX, OFFSET greeting
	Call WriteString
	Call CrLf
	MOV	EDX, OFFSET extraCredit3
	Call WriteString
	Call CrLf
	MOV	EDX, OFFSET extraCredit4
	Call WriteString
	Call CrLf
	MOV	EDX, OFFSET instructToUser
	Call WriteString
	Call CrLf

  ; --------------------------------------------------
  ; Get number from user input and save to 3 variables
  ; --------------------------------------------------
	; Get number A
    MOV	EDX, OFFSET numAAsk
	Call WriteString
	Call ReadDec
	MOV numA, EAX

	; Get number B
	MOV	EDX, OFFSET numBAsk
	Call WriteString
	Call ReadDec
	MOV numB, EAX

	; Get number C
	MOV	EDX, OFFSET numCAsk
	Call WriteString
	Call ReadDec
	MOV numC, EAX

  ; --------------------------------------------------
  ; Calculate multiple operations using user-inputted numbers from earlier
  ; --------------------------------------------------
	; A + B
    MOV EAX, numA
	ADD EAX, numB
	MOV aAddB, EAX

	; A - B
    MOV EAX, numA
	SUB EAX, numB
	MOV aSubB, EAX

	; A + C
    MOV EAX, numA
	ADD EAX, numC
	MOV aAddC, EAX

	; A - C
    MOV EAX, numA
	SUB EAX, numC
	MOV aSubC, EAX

	; B + C
    MOV EAX, numB
	ADD EAX, numC
	MOV bAddC, EAX

	; B - C
    MOV EAX, numB
	SUB EAX, numC
	MOV bSubC, EAX

	; A + B + C
    MOV EAX, numA
	ADD EAX, numB
	ADD EAX, numC
	MOV aAddBAddC, EAX

	; B - A
    MOV EAX, numB
	SUB EAX, numA
	MOV bSubA, EAX

	; C - A
    MOV EAX, numC
	SUB EAX, numA
	MOV cSubA, EAX
	
	; C - B
    MOV EAX, numC
	SUB EAX, numB
	MOV cSubB, EAX

	; C - B - A
    MOV EAX, numC
	SUB EAX, numB
	SUB EAX, numA
	MOV cSubBSubA, EAX

	; A / B
	MOV EDX, 0				; Clear EDX before DIV
	MOV EAX, numA			; EDX:EAX forms a 64-bit dividend. We only need 32 bits
	DIV numB				; Use numB as 32-bit divisor
	MOV aDivBQuotient, EAX	; EAX contains quotient
	MOV aDivBRemainder, EDX	; EDX contains remainder
	
	; A / C
	MOV EDX, 0
	MOV EAX, numA
	DIV numC
	MOV aDivCQuotient, EAX
	MOV aDivCRemainder, EDX
	
	; B / C
	MOV EDX, 0
	MOV EAX, numB
	DIV numC
	MOV bDivCQuotient, EAX
	MOV bDivCRemainder, EDX

  ; --------------------------------------------------
  ; Display result of calculations
  ; --------------------------------------------------

    ; A + B
	MOV	EAX, numA
	Call WriteDec
	MOV	EDX, OFFSET addSign
	Call WriteString
	MOV	EAX, numB
	Call WriteDec
	MOV	EDX, OFFSET equalSign
	Call WriteString
	MOV	EAX, aAddB
	Call WriteDec
	Call CrLf

	; A - B
	MOV	EAX, numA
	Call WriteDec
	MOV	EDX, OFFSET subSign
	Call WriteString
	MOV	EAX, numB
	Call WriteDec
	MOV	EDX, OFFSET equalSign
	Call WriteString
	MOV	EAX, aSubB
	Call WriteDec
	Call CrLf

	; A + C
	MOV	EAX, numA
	Call WriteDec
	MOV	EDX, OFFSET addSign
	Call WriteString
	MOV	EAX, numC
	Call WriteDec
	MOV	EDX, OFFSET equalSign
	Call WriteString
	MOV	EAX, aAddC
	Call WriteDec
	Call CrLf

	; A - C
	MOV	EAX, numA
	Call WriteDec
	MOV	EDX, OFFSET subSign
	Call WriteString
	MOV	EAX, numC
	Call WriteDec
	MOV	EDX, OFFSET equalSign
	Call WriteString
	MOV	EAX, aSubC
	Call WriteDec
	Call CrLf

	; B + C
	MOV	EAX, numB
	Call WriteDec
	MOV	EDX, OFFSET addSign
	Call WriteString
	MOV	EAX, numC
	Call WriteDec
	MOV	EDX, OFFSET equalSign
	Call WriteString
	MOV	EAX, bAddC
	Call WriteDec
	Call CrLf

	; B - C
	MOV	EAX, numB
	Call WriteDec
	MOV	EDX, OFFSET subSign
	Call WriteString
	MOV	EAX, numC
	Call WriteDec
	MOV	EDX, OFFSET equalSign
	Call WriteString
	MOV	EAX, bSubC
	Call WriteDec
	Call CrLf

	; A + B + C
	MOV	EAX, numA
	Call WriteDec
	MOV	EDX, OFFSET addSign
	Call WriteString
	MOV	EAX, numB
	Call WriteDec
	MOV	EDX, OFFSET addSign
	Call WriteString
	MOV	EAX, numC
	Call WriteDec
	MOV	EDX, OFFSET equalSign
	Call WriteString
	MOV	EAX, aAddBAddC
	Call WriteDec
	Call CrLf

	; B - A
	MOV	EAX, numB
	Call WriteDec
	MOV	EDX, OFFSET subSign
	Call WriteString
	MOV	EAX, numA
	Call WriteDec
	MOV	EDX, OFFSET equalSign
	Call WriteString
	MOV	EAX, bSubA
	Call WriteInt
	Call CrLf

	; C - A
	MOV	EAX, numC
	Call WriteDec
	MOV	EDX, OFFSET subSign
	Call WriteString
	MOV	EAX, numA
	Call WriteDec
	MOV	EDX, OFFSET equalSign
	Call WriteString
	MOV	EAX, cSubA
	Call WriteInt
	Call CrLf

	; C - B
	MOV	EAX, numC
	Call WriteDec
	MOV	EDX, OFFSET subSign
	Call WriteString
	MOV	EAX, numB
	Call WriteDec
	MOV	EDX, OFFSET equalSign
	Call WriteString
	MOV	EAX, cSubB
	Call WriteInt
	Call CrLf

	; C - B - A
	MOV	EAX, numC
	Call WriteDec
	MOV	EDX, OFFSET subSign
	Call WriteString
	MOV	EAX, numB
	Call WriteDec
	MOV	EDX, OFFSET subSign
	Call WriteString
	MOV	EAX, numA
	Call WriteDec
	MOV	EDX, OFFSET equalSign
	Call WriteString
	MOV	EAX, cSubBSubA
	Call WriteInt
	Call CrLf

	; A / B
	MOV	EAX, numA
	Call WriteDec
	MOV	EDX, OFFSET divSign
	Call WriteString
	MOV	EAX, numB
	Call WriteDec
	MOV	EDX, OFFSET equalSign
	Call WriteString
	MOV	EAX, aDivBQuotient
	Call WriteDec
	MOV	EDX, OFFSET remainderSign
	Call WriteString
	MOV	EAX, aDivBRemainder
	Call WriteDec
	Call CrLf
	
	; A / C
	MOV	EAX, numA
	Call WriteDec
	MOV	EDX, OFFSET divSign
	Call WriteString
	MOV	EAX, numC
	Call WriteDec
	MOV	EDX, OFFSET equalSign
	Call WriteString
	MOV	EAX, aDivCQuotient
	Call WriteDec
	MOV	EDX, OFFSET remainderSign
	Call WriteString
	MOV	EAX, aDivCRemainder
	Call WriteDec
	Call CrLf
	
	; B / C
	MOV	EAX, numB
	Call WriteDec
	MOV	EDX, OFFSET divSign
	Call WriteString
	MOV	EAX, numC
	Call WriteDec
	MOV	EDX, OFFSET equalSign
	Call WriteString
	MOV	EAX, bDivCQuotient
	Call WriteDec
	MOV	EDX, OFFSET remainderSign
	Call WriteString
	MOV	EAX, bDivCRemainder
	Call WriteDec
	Call CrLf

  ; --------------------------------------------------
  ; Print goodbye message and exit
  ; --------------------------------------------------
	MOV	EDX, OFFSET goodbye
	Call WriteString
	Call CrLf

	; exit to operating system
	Invoke ExitProcess,0
main ENDP

END main
