TITLE Prime Number Printer     (Proj4_934553922.asm)

; Author: Bach Xuan Phan (934553922)
; Last Modified: 11/19/2023
; OSU email address: phanx@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 4                Due Date: 11/19/2023
; Description: With input to be in [1, 200], enter the number of prime numbers you want to calculate and print to screen

INCLUDE Irvine32.inc

; [LOWER_LIMIT, UPPER_LIMIT]
LOWER_LIMIT = 1
UPPER_LIMIT = 200

; Numbers displayed per row
NUM_PER_ROW = 10

.data
 greeting		BYTE	"Prime Number Printer by Bach Xuan Phan",0
 instructToUser	BYTE	"Enter a positive number within a range.",13,10,
						"The program will print the prime numbers with the valid input as a count.",0
 goodbye		BYTE	"Autobots, roll out!",0
 numAsk			BYTE	"Enter the number of primes you want to print from ",0
 wrongNumWarn	BYTE	"By the Prime. Wrong number!",0
 commaSign		BYTE	", ",0
 colonSign		BYTE	": ",0
 periodSign		BYTE	".",0
 bracketSign1	BYTE	"[",0
 bracketSign2	BYTE	"]",0
 spacerSign		BYTE	"   ",0			; Separator for each prime
 numInput		DWoRD	0
 numInputValid	DWoRD	0				; Boolean to see if inputted number is valid
 numPerRow		DWoRD	NUM_PER_ROW
 displayCount	DWORD	0				; Count the number of primes that has been displayed
 currPrime		DWORD	1				; Current prime number to consider. Starts at 1 so when showPrimes runs, it will be at 2, the first prime
 isCurrPrime	DWoRD	0				; Boolean to see if currPrime is a prime
 divisor		DWORD	0				; Divisor to check for prime number

.code
main PROC
	CALL introduction
	CALL getUserData					; Get the input number from user and validate it
	CALL showPrimes						; Print the prime numbers according to the count of primes inputted
	CALL farewell
	
	; exit to operating system
	Invoke ExitProcess,0
main ENDP

; -- introduction --
; Procedure to introduce the program.
; Preconditions: greeting, instructToUser are strings that greet the user and give a general instrction to the program
; Postconditions: change EDX
; Receives: none
; Returns: print greeting, instrction to console
introduction PROC
	MOV EDX, OFFSET greeting
	CALL WriteString
	CALL CrLf
	CALL CrLf
	MOV EDX, OFFSET instructToUser
	CALL WriteString
	CALL CrLf
	CALL CrLf
	RET
introduction ENDP

; -- getUserData --
; Procedure to get user input.
; Preconditions: numAsk, bracketSign1, commaSign, bracketSign2, colonSign, wrongNumWarn are strings to print,
; numInputValid is a boolean to see if inputted number is valid
; Postconditions: EAX, EDX, numInput changed
; Receives: user input from EAX
; Returns: user input value for global variable numInput, or print error wrongNumWarn to console
getUserData PROC
_UserInput:
	; Print the input limit
    MOV	EDX, OFFSET numAsk
	CALL WriteString
    MOV	EDX, OFFSET bracketSign1
	CALL WriteString
	MOV EAX, LOWER_LIMIT
	CALL WriteDec
	MOV	EDX, OFFSET commaSign
	CALL WriteString
	MOV EAX, UPPER_LIMIT
	CALL WriteDec
	MOV	EDX, OFFSET bracketSign2
	CALL WriteString
	MOV	EDX, OFFSET colonSign
	CALL WriteString

	; Get number and validate the input
	CALL ReadDec
	CALL validate
	CMP numInputValid, 0
	JZ _NumOutOfBound

	; Store inputted number to a separate variable
	MOV numInput, EAX
	RET

_NumOutOfBound:
	; Print message when an out-of-bound number is entered and return to user input loop
	MOV	EDX, OFFSET wrongNumWarn
	Call WriteString
	Call CrLf
	JMP _UserInput

getUserData ENDP

; -- validate  --
; Procedure to validate the input value to check if it is within bound.
; Preconditions: EAX has the number to check, numInputValid for result, LOWER_LIMIT, UPPER_LIMIT as limit
; Postconditions: numInputValid changed
; Receives: EAX
; Returns: global variable numInputValid the boolean result of whether inputted number is valid
validate PROC
	; Check if the number is out of the outer range [0, LOWER_LIMIT) or (UPPER_LIMIT, +inf)
	CMP EAX, UPPER_LIMIT
	JG _NumInputIsNotValid
	CMP EAX, LOWER_LIMIT
	JL _NumInputIsNotValid
	MOV numInputValid, 1
	RET

_NumInputIsNotValid:
	MOV numInputValid, 0
	RET
validate ENDP

; -- showPrimes --
; Procedure to print the prime numbers according to the count of primes inputted before.
; Preconditions: ECX used as loop count for how many primes to print, currPrime is the current number to check for primeness,
; numPerRow for number limit on row, displayCount to check when it's time for a new row
; Postconditions: EAX, ECX, EDX, currPrime, displayCount changed
; Receives: numInput as global variable
; Returns: print prime numbers in a row, go to new row when reach numPerRow numbers
showPrimes PROC
	CALL CrLf

	; Update loop count to keep track of the number of primes to print with the input
	MOV ECX, numInput
	; Reset the current number in check
	MOV currPrime, 1
	; Reset display count
	MOV displayCount, 0

_CalculatePrime:
	; Check if the current number in check is a prime
	INC currPrime
	CALL isPrime
	CMP isCurrPrime, 0
	JNZ _ShowPrime
	; If the current number is NOT a prime, don't count toward loop
	JMP _CalculatePrime

_ShowPrime:
	; Print the prime number
	MOV EAX, currPrime
	CALL WriteDec
	MOV EDX, OFFSET spacerSign
	CALL WriteString
	INC displayCount
	
	; Decide whether to move to a new row using displayCount
	MOV EDX, 0
	MOV EAX, displayCount
	DIV numPerRow
	CMP EDX, 0
	JZ _NewLineForPrimePrint
	LOOP _CalculatePrime
	CALL CrLf
	RET

_NewLineForPrimePrint:
	CALL CrLf
	LOOP _CalculatePrime

showPrimes ENDP

; -- isPrime --
; Procedure to validate whether the number is a prime or not.
; Preconditions: divisor must start at 2, EDX and EAX for divison, currPrime is the current number to check for primeness
; Postconditions: EAX, EDX, isCurrPrime, divisor changed
; Receives: currPrime as global variable
; Returns: global variable isCurrPrime for boolean result of whether currPrime is a prime
isPrime PROC
    MOV divisor, 1						; Start divisor

_IncreaseDivisor:
    INC divisor							; Increment divisor
	MOV EAX, currPrime
	MOV EDX, 0
    CMP divisor, EAX					; Check if divisor exceeds currPrime
    JL  _CheckPrime

	; Return that the current number in check is a prime
	MOV isCurrPrime, 1
	RET

_CheckPrime:
    DIV divisor							; Divide current prime by a divisor
    CMP EDX, 0
    JNZ  _IncreaseDivisor				; If remainder is zero, currPrime is not a prime

	; Return that the current number in check is NOT a prime
	MOV isCurrPrime, 0
	RET

isPrime ENDP

; -- farewell --
; Procedure to bid farewell to user.
; Preconditions: goodbye is a string that says goodbye to the user
; Postconditions: change EDX
; Receives: none
; Returns: print goodbye to console
farewell PROC
	CALL CrLf
	MOV EDX, OFFSET goodbye
	CALL WriteString
	CALL CrLf
	RET
farewell ENDP

END main
