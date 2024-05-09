TITLE Integer Accumulator     (Proj3_934553922.asm)

; Author: Bach Xuan Phan (934553922)
; Last Modified: 11/3/2023
; OSU email address: phanx@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 3                Due Date: 11/5/2023
; Description: With input to be in [-200, -100] or [-50, -1] (inclusive),
;				count and accumulate the valid user numbers until a positive number is entered.
;				Then display the number of numbers entered that are valid, their sum, the max value, the min value, the rounded average.

INCLUDE Irvine32.inc

; [LOWER_LIMIT_A, UPPER_LIMIT_A] or [LOWER_LIMIT_B, UPPER_LIMIT_B]
LOWER_LIMIT_A = -200
UPPER_LIMIT_A = -100
LOWER_LIMIT_B = -50
UPPER_LIMIT_B = -1

.data
 greeting		BYTE	"Integer Accumulator by Bach Xuan Phan",0
 instructToUser	BYTE	"Enter numbers within limits specified.",13,10,
						"Enter a positive number or 0 when you are finished.",13,10,
						"The program will give out the count, minimum, maximum, sum, average of the valid numbers inputted.",0
 extraCredit1	BYTE	"**EC: Add the number of input number (increment with only valid numbers).",0
 extraCredit2	BYTE	"**EC: Calculate and display the average as a decimal-point number , rounded to the nearest .01.",0
 goodbye		BYTE	"Thank you for using this program",0
 nameAsk		BYTE	"What's your name, stranger? ",0
 printName		BYTE	"All hail ",0
 limitShow		BYTE	"Within limit of ",0		; For display input limit
 numAsk			BYTE	"Enter the number ",0
 noNumWarn		BYTE	"No valid numbers were entered. A shame!",0
 wrongNumWarn	BYTE	"Woah there, partner. Wrong number!",0
 validCountSign	BYTE	"You entered ",0
 validNumsSign	BYTE	" valid numbers.",0
 numMaxSign		BYTE	"The maximum valid number is ",0
 numMinSign		BYTE	"The minimum valid number is ",0
 numSumSign		BYTE	"The sum of valid numbers is ",0
 numAvgSign		BYTE	"The rounded average of valid numbers is ",0
 numAvgDPSign	BYTE	"The rounded average as a decimal-point number is ",0
 commaSign		BYTE	", ",0
 colonSign		BYTE	": ",0
 periodSign		BYTE	".",0
 bracketSign1	BYTE	"[",0
 bracketSign2	BYTE	"]",0
 andSign		BYTE	" and ",0
 orSign			BYTE	" or ",0
 nameOfUser		BYTE	50 DUP(0)
 numInput		SDWoRD	0
 numCount		DWoRD	0
 numCountMid	DWoRD	0							  ; Mid-point of count after division
 numMin			SDWoRD	0
 numMax			SDWoRD	0
 numSum			SDWoRD	0
 numAvg			SDWoRD	0
 numAvgRound	SDWoRD	0							  ; Average number after rounded
 numAvgRem		DWoRD	0
 numAvgFrct		DWORD	0							  ; Fractional part of average calculation

.code
main PROC
  ; --------------------------------------------------
  ; Print introduction of program
  ; --------------------------------------------------
	MOV	EDX, OFFSET greeting
	Call WriteString
	Call CrLf
	MOV	EDX, OFFSET extraCredit1
	Call WriteString
	Call CrLf
	MOV	EDX, OFFSET extraCredit2
	Call WriteString
	Call CrLf
	MOV	EDX, OFFSET instructToUser
	Call WriteString
	Call CrLf

  ; --------------------------------------------------
  ; Get and print name of user
  ; --------------------------------------------------
	MOV	EDX, OFFSET nameAsk
	Call WriteString

	; Get name
	MOV	EDX, OFFSET nameOfUser
	MOV ECX, SIZEOF nameOfUser						; specify max characters
	Call ReadString
	MOV	EDX, OFFSET nameOfUser

	; Print name
	MOV	EDX, OFFSET printName
	Call WriteString
	MOV	EDX, OFFSET nameOfUser
	Call WriteString
	MOV	EDX, OFFSET commaSign
	Call WriteString
	MOV	EDX, OFFSET printName
	Call WriteString
	MOV	EDX, OFFSET nameOfUser
	Call WriteString
	Call CrLf

  ; --------------------------------------------------
  ; Get number from user input and check its validity
  ; --------------------------------------------------
_UserInput:	
	; Print the imput limit
    MOV	EDX, OFFSET limitShow
	Call WriteString
    MOV	EDX, OFFSET bracketSign1
	Call WriteString
	MOV EAX, LOWER_LIMIT_A
	Call WriteInt
	MOV	EDX, OFFSET commaSign
	Call WriteString
	MOV EAX, UPPER_LIMIT_A
	Call WriteInt
	MOV	EDX, OFFSET bracketSign2
	Call WriteString
    MOV	EDX, OFFSET orSign
	Call WriteString
	MOV	EDX, OFFSET bracketSign1
	Call WriteString
	MOV EAX, LOWER_LIMIT_B
	Call WriteInt
	MOV	EDX, OFFSET commaSign
	Call WriteString
	MOV EAX, UPPER_LIMIT_B
	Call WriteInt
	MOV	EDX, OFFSET bracketSign2
	Call WriteString
	Call CrLf

	; Print "Enter number" message with the order of the number
	MOV	EDX, OFFSET numAsk
	Call WriteString
	MOV	EAX, numCount
	INC EAX
	Call WriteDec
	MOV	EDX, OFFSET colonSign
	Call WriteString
	
	; Get number
	Call ReadInt

	; Check if the number is non-negative. If it is, check for the valid number count to see if displaying result is necessary
	CMP EAX, 0
	JNS _CheckCount
	
	; Check if the number is out of the outer range (-inf, LOWER_LIMIT_A) or (UPPER_LIMIT_B, +inf). If it is, warn the user of the wrong number
	CMP EAX, UPPER_LIMIT_B
	JG _NumOutOfBound
	CMP EAX, LOWER_LIMIT_A
	JL _NumOutOfBound
	
	; Check if the number is in the inner range (UPPER_LIMIT_A, LOWER_LIMIT_B). If it is, warn the user of the wrong number
	CMP EAX, LOWER_LIMIT_B
	JGE _StoreNum
	CMP EAX, UPPER_LIMIT_A
	JLE _StoreNum
	
_NumOutOfBound:
	; Print message when an out-of-bound number is entered and return to user input loop
	MOV	EDX, OFFSET wrongNumWarn
	Call WriteString
	Call CrLf
	JMP _UserInput

_StoreNum:
	; Store inputted number to a separate variable
	MOV numInput, EAX

  ; --------------------------------------------------
  ; Calculate the minimum, maximum, sum of the valid inputted numbers, increment number count and return to user input loop
  ; --------------------------------------------------
	; Check if the inputted number is smaller than the minimum
	CMP EAX, numMin
	JGE _SkipToMax
	MOV numMin, EAX
	
	; Check if this is the first number to be entered, make that number the maximum
	CMP numCount, 0
	JG _SkipToMax
	MOV numMax, EAX

_SkipToMax:
	; Check if the inputted number is bigger than the maximum
	CMP EAX, numMax
	JLE _SkipToSum
	MOV numMax, EAX

_SkipToSum:
	; Accumulate the total of valid inputted numbers
	MOV EAX, numSum
	ADD EAX, numInput
	MOV numSum, EAX

	; Increment count
	INC numCount

	; Return to user input
	JMP _UserInput

  ; --------------------------------------------------
  ; Check for the number of valid inputs and calculate the rounded average of the valid inputted numbers
  ; --------------------------------------------------
_CheckCount:
	; Check if there is no valid number entered. If not, warn user about it and jump straight to goodbye
	CMP numCount, 0
	JNE _Avg
	MOV	EDX, OFFSET noNumWarn
	Call WriteString
	Call CrLf
	JMP _GoodBye

_Avg:
	; Calculate average
	MOV EAX, numSum
	CDQ												; Sign-extended to EDX in EDX:EAX dividend
	IDIV numCount									; Divide for the number count
	MOV numAvg, EAX
	MOV numAvgRound, EAX
	NEG EDX											; The remainder always has the same sign as the dividend, so we flip it
	MOV numAvgRem, EDX								; We use remainder to determine whether to round the average

	; Determine the mid-point of count
	MOV EAX, numCount
	MOV EDX, 0
	MOV EBX, 2
	DIV EBX
	MOV numCountMid, EAX
	
	; If the remainder of the previous division is larger than the mid-point,
	; the average is a number with its fractional part > 0.5
	; numAvg = numAvg - 1 to round the average if it happens (numAvg < 0)
	CMP numAvgRem, EAX
	JLE _FractionCalc
	DEC numAvgRound

_FractionCalc:
	; Get the first fractional number (x in .xy) by multiply the average's remainder by 10
	; then divide it by numCount. The remainder is then multiplied by 10 for the fractional part.
	MOV EAX, numAvgRem
	MOV EBX, 10
	MUL EBX
	MOV EDX, 0
	DIV numCount
	MOV numAvgRem, EDX
	MUL EBX
	MOV numAvgFrct, EAX
	
	; Do the same calculation with the second fractional number (y in .xy).
	; The remainder is added to the previous fractional result. 
	MOV EAX, numAvgRem
	MOV EBX, 10
	MUL EBX
	MOV EDX, 0
	DIV numCount
	ADD numAvgFrct, EAX
	MOV numAvgRem, EDX

	; If the remainder of the previous division is larger than the mid-point,
	; the average is a number with its fractional part > .xy5
	; Increment numAvgFrct to round the average if it happens
	MOV EAX, numCountMid
	CMP numAvgRem, EAX
	JLE _Display
	INC numAvgFrct
	
	; If the fractional part reaches 100, clear it and increment the original average
	CMP numAvgFrct, 100
	JL _Display
	MOV numAvgFrct, 0
	DEC numAvg
	
  ; --------------------------------------------------
  ; Display result after breaking from the loop
  ; --------------------------------------------------
_Display:
	; Count
	MOV	EDX, OFFSET validCountSign
	Call WriteString
	MOV EAX, numCount
	Call WriteDec
	MOV	EDX, OFFSET validNumsSign
	Call WriteString
	Call CrLf

	; Maximum
	MOV	EDX, OFFSET numMaxSign
	Call WriteString
	MOV EAX, numMax
	Call WriteInt
	Call CrLf

	; Minimum
	MOV	EDX, OFFSET numMinSign
	Call WriteString
	MOV EAX, numMin
	Call WriteInt
	Call CrLf

	; Sum
	MOV	EDX, OFFSET numSumSign
	Call WriteString
	MOV EAX, numSum
	Call WriteInt
	Call CrLf

	; Average
	MOV	EDX, OFFSET numAvgSign
	Call WriteString
	MOV EAX, numAvgRound
	Call WriteInt
	Call CrLf
	
	; Average as a decimal-point number
	MOV	EDX, OFFSET numAvgDPSign
	Call WriteString
	MOV EAX, numAvg
	Call WriteInt
	MOV	EDX, OFFSET periodSign
	Call WriteString
	CMP numAvgFrct, 10								  ; Check if the fractional part is < 10. If it is, add zero padding
	JGE _SkipPadding
	MOV EAX, 0
	Call WriteDec
	
_SkipPadding:
	MOV EAX, numAvgFrct
	Call WriteDec
	Call CrLf
	
  ; --------------------------------------------------
  ; Print goodbye message and exit
  ; --------------------------------------------------
_GoodBye:
	MOV	EDX, OFFSET goodbye
	Call WriteString
	MOV	EDX, OFFSET commaSign
	Call WriteString
	MOV	EDX, OFFSET nameOfUser
	Call WriteString
	Call CrLf

	; exit to operating system
	Invoke ExitProcess,0
main ENDP

END main
