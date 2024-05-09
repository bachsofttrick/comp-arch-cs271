TITLE Designing low-level I/O procedures (Proj6_934553922.asm)
; Author: Bach Xuan Phan (934553922)
; Last Modified: 12/10/2023
; OSU email address: phanx@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date: 12/10/2023
; Description: Enter 10 signed integers. Display them, their sum, their truncated average (only the integer part, no rounding)

INCLUDE Irvine32.inc

; -- mDisplayString --
; Procedure to display a string.
; Preconditions: Reference to strings that need to be printed
; Receives: Parameters input (reference, input)
; Returns: Print input to console
mDisplayString MACRO input
    MOV EDX, input											                           ; Load the address of input
    CALL WriteString
ENDM

; -- mGetString --
; Procedure to get a string from the user.
; Preconditions: A reference to a string for displaying message, a reference to a string to save the input, the maximum length of the input allowed,
; a reference to a variable to save the length of the input
; Receives: Parameters prompt (reference, input), output (reference, output), length (value, input), bytesRead (reference, output)
; Returns: Change output with the input content, bytesRead for the length of the input string
mGetString MACRO prompt, output, length, bytesRead
    mDisplayString prompt
    MOV EDX, output												                     ; Load the address of the output buffer
    MOV ECX, length											        	             ; Set the maximum length to receive
    CALL ReadString
    MOV [bytesRead], EAX                                                             ; Save number of bytes received
ENDM

; Size for the input number array
ARRAYSIZE = 10

.data
 greeting		    BYTE	"Designing low-level I/O procedures by Bach Xuan Phan",13,10,13,10,0
 instructToUser	    BYTE	"Please put in 10 signed integers.",13,10,
						    "Each number needs to be between -2^31 and 2^31 - 1.",13,10,
						    "The program will print the numbers, the sum and the truncated average of the numbers.",13,10,13,10,0
 goodbye		    BYTE	13,10,"Till all are one!",0
 inputQuote	        BYTE	"Enter a signed number: ",0						        ; Message for number input
 wrongInputQuote    BYTE	"Wrong number input or number is too big. ",     	    ; Message for when you input the wrong string
                            "Please try again: ",0
 printQuote	        BYTE    13,10,"You entered the following numbers: ",13,10,0     ; Message for when we print the number inputs
 sumQuote	        BYTE    "Sum of these numbers: ",0                              ; Message for the sum of the array
 avgQuote	        BYTE    13,10,"Truncated average of these numbers: ",0          ; Message for the truncated average of the array
 commaSign		    BYTE	", ",0
 newlineSign        BYTE    13,10,0                                                 ; CrLf
 inputStr		    BYTE	50 DUP (0)								        		; String for input
 outputStr		    BYTE	50 DUP (0)								        		; String for output
 inputLength        DWORD   0								        		        ; Input string length
 inputNums          SDWORD  ARRAYSIZE DUP (0)				        		        ; Number outputted from inputted string
 sumResult          SDWORD  0
 avgResult          SDWORD  0

.code
main PROC
	; Introduce the program
	; introduction{intro1 (reference, input), intro2 (reference, input)}
	PUSH OFFSET greeting
	PUSH OFFSET instructToUser
	CALL introduction

    ; Get inputs from the user and validate them, put the valid ones in an array
    ; ReadVal{prompt (reference, input), inputString (reference, input), length (value, input), bytesRead (reference, output),
    ; outputNumber (reference, output), errorPrompt (reference, input)}
    MOV ECX, ARRAYSIZE                                                               ; Set loop count to the array size
    MOV EDI, OFFSET inputNums                                                        ; EDI is the pointer of the integer array to save the valid input
_ReadValToArray:
    PUSH OFFSET inputQuote
    PUSH OFFSET inputStr
    PUSH SIZEOF inputStr
    PUSH OFFSET inputLength
    PUSH EDI
    PUSH OFFSET wrongInputQuote
    CALL ReadVal
    ADD EDI, 4                                                                       ; Move EDI pointer to the next element in the array
    LOOP _ReadValToArray

    ; Display the valid integers
    mDisplayString OFFSET printQuote
    ; WriteVal{inputNum (reference, input), outputString (reference, output)}
    MOV ECX, ARRAYSIZE
    MOV ESI, OFFSET inputNums                                                        ; ESI is the pointer to the integer array to read from
_WriteValFromArray:
    PUSH ESI
    PUSH OFFSET outputStr
    CALL WriteVal
    ADD ESI, 4                                                                       ; Move ESI pointer to the next element in the array
    ; Check to see if the element that have just been printed is the last in the array
    ; If it is, do not print the comma separator
    CMP ECX, 1
    JE _WriteValFromArrayJumpLoop
    mDisplayString OFFSET commaSign
_WriteValFromArrayJumpLoop:
    LOOP _WriteValFromArray
    mDisplayString OFFSET newlineSign                                                 ; CrLf
    
    ; Calculate the total of the valid numbers
    mDisplayString OFFSET sumQuote
    MOV EAX, 0                                                                        ; Reset EAX
    MOV ECX, ARRAYSIZE                                                                ; Set loop count to the array size
    MOV ESI, OFFSET inputNums
_Sum:
    ; Sum of the integer array
    ADD EAX, [ESI]
    ADD ESI, 4
    LOOP _Sum
    ; Save and print the sum result
    MOV sumResult, EAX
    PUSH OFFSET sumResult
    PUSH OFFSET outputStr
    CALL WriteVal

    ; Calculate the average of the valid integers and truncate
    mDisplayString OFFSET avgQuote
    ; Get the sum result to divide with the array size in EBX
    MOV EAX, sumResult
    MOV EBX, ARRAYSIZE
    CDQ                                                                               ; Sign-extended EAX to EDX:EAX for signed DIV (IDIV)
    IDIV EBX
    ; Save and print the truncated average result
    MOV avgResult, EAX
    PUSH OFFSET avgResult
    PUSH OFFSET outputStr
    CALL WriteVal
    mDisplayString OFFSET newlineSign                                                 ; CrLf

	; Bid farewell to user
	; farewell{message (reference, input)}
	PUSH OFFSET goodbye
	CALL farewell
	
	; exit to operating system
	Invoke ExitProcess,0
main ENDP

; -- introduction --
; Procedure to introduce the program.
; Preconditions: Reference to strings that need to be printed
; Postconditions: Change EDX
; Receives: Parameters intro1 (reference, input) [EBP + 4 * 3], intro2 (reference, input) [EBP + 4 * 2]
; Returns: Print intro1, intro2 to console
introduction PROC USES EBP
	MOV EBP, ESP
	mDisplayString [EBP + 4 * 3]								        		    ; Location to intro1 from stack (subtract EBP, return address, intro2)
	mDisplayString [EBP + 4 * 2]								        		    ; Location to intro2 from stack (subtract EBP, return address)
	
	RET 4 * 2													        	    	; Pop intro1, intro2
introduction ENDP

; -- ReadVal --
; Procedure to read an integer from a string.
; Preconditions: A reference to a string for displaying message, a reference to a string to save the input, the maximum length of the input allowed,
; a reference to a variable to save the length of the input, a reference to a location to save the output integer, a reference to a string for displaying error
; Postconditions: Change EAX, EBX, ECX, ESI, EDI, content of inputString, bytesRead, outputNumber
; Receives: prompt (reference, input) [EBP + 4 * 10], inputString (reference, I/O) [EBP + 4 * 9], length (value, input) [EBP + 4 * 8],
; bytesRead (reference, output) [EBP + 4 * 7], outputNumber (reference, output) [EBP + 4 * 6], errorPrompt (reference, input) [EBP + 4 * 5]
; Returns: Change outputNumber with a valid integer, inputString for input by user, bytesRead for the length of the input string
ReadVal PROC USES EBP ECX ESI EDI
    MOV EBP, ESP
    mGetString [EBP + 4 * 10], [EBP + 4 * 9], [EBP + 4 * 8], [EBP + 4 * 7]          ; Print prompt to enter signed integer

_ReadValInput:
    MOV ESI, [EBP + 4 * 9]                                                          ; ESI points to inputString
    MOV EBX, 0
    CLD                                                                             ; Clear direction flag to increment string pointer
    MOV EAX, 0                                                                      ; Reset EAX. We only concern AL
    MOV CL, 0                                                                       ; Reset CL. We use CL as a negative flag

    ; Check if the first character is a plus or a minus (sign)
    ; If the first character is not a sign, check to see if it is a digit without moving the pointer
    LODSB                                                                           ; PUT [ESI] into AL and increment pointer
    CMP AL, 0
    JE _InvalidInput
    CMP AL, '+'
    JE  _ReadValLoopSecondChar
    CMP AL, '-'
    JNE  _ReadValLoopFirstCharNotASign
    MOV CL, 1
    JMP _ReadValLoopSecondChar

_ReadValLoopFirstCharNotASign:
    ; Check if the first character is a digit, after checking for a sign
    CMP AL, '0'
    JL  _InvalidInput
    CMP AL, '9'
    JG  _InvalidInput
    JMP _ReadValUpdate
    
_ReadValLoopSecondChar:
    ; Check if the second character is a digit. The first character is a sign
    LODSB
    CMP AL, 0
    JE _InvalidInput
    CMP AL, '0'
    JL  _InvalidInput
    CMP AL, '9'
    JG  _InvalidInput
    JMP _ReadValUpdate

_ReadValLoop: 
    ; Check if the subsequent character is a digit
    LODSB
    CMP AL, 0
    JE _EndInput
    CMP AL, '0'
    JL  _InvalidInput
    CMP AL, '9'
    JG  _InvalidInput

_ReadValUpdate:
    ; Update the result in EBX
    SUB AL, '0'
    IMUL EBX, 10
    JO _InvalidInput                                                                ; Check for overflow
    ; Check if EBX is a positive or a negative number and use the appropriate arithmetic operation
    CMP EBX, 0
    JL _SubFromResult
    ADD EBX, EAX
    JO _InvalidInput                                                                ; Check for overflow
    JMP _CheckNegFlag
_SubFromResult:
    SUB EBX, EAX
    JO _InvalidInput                                                                ; Check for overflow
_CheckNegFlag:
    ; If the negative flag CL is set, turn the number in EBX to a negative one
    CMP CL, 0
    JNZ _AddMinusSign
    JMP _ReadValLoop

_InvalidInput:
    mGetString [EBP + 4 * 5], [EBP + 4 * 9], [EBP + 4 * 8], [EBP + 4 * 7]          ; Prompt the error when a wrong input is detected and ask user to input a new value
    JMP _ReadValInput
    
_AddMinusSign:
    ; Check if EBX has a value yet before putting a minus sign on it
    CMP EBX, 0
    JZ _ReadValLoop
    NEG EBX
    MOV CL, 0
    JMP _ReadValLoop

_EndInput:
    MOV EDI, [EBP + 4 * 6]
    MOV [EDI], EBX
    RET 4 * 6
ReadVal ENDP

; -- WriteVal --
; Procedure to write an integer to the console.
; Preconditions: A reference to a integer to print, a reference to the string created from the integer
; Postconditions: Change EAAX, EBX, ECX, ESI, EDI
; Receives: inputNum (reference, input) [EBP + 4 * 6], outputString (reference, output) [EBP + 4 * 5]
; Returns: Print inputNum to console by converting inputNum to outputString then print outputString
WriteVal PROC USES EBP ECX ESI EDI
    MOV EBP, ESP
    MOV EBX, 10                                                                     ; Set divisor to 10
    MOV ECX, 0                                                                      ; Count the number's length
    MOV EDI, [EBP + 4 * 5]                                                          ; Set EDI to point to the output string as buffer

    ; Check if input is a negative number. If it is, add a minus sign to the ouput string
    MOV ESI, [EBP + 4 * 6]                                                          ; Set ESI to point to the number to print
    CMP SDWORD PTR [ESI], 0
    JGE _WriteValCopy
    ; Add minus when the number is a negative
    MOV BYTE PTR [EDI], '-'
    ADD EDI, 1

_WriteValCopy:
    ; Check if input is a negative number. If it is, flip the input number to be a positive number to convert to string
    MOV EAX, [ESI]
    CMP EAX, 0
    JGE _WriteValLoop
    NEG EAX                                                                         ; Flip the input number to be a positive number

_WriteValLoop:
    MOV EDX, 0                                                                      ; Clear any previous remainder
    DIV EBX                                                                         ; Divide value by 10, result in EAX, remainder in EDX
    PUSH EDX                                                                        ; Push the remainder onto the stack
    ADD ECX, 1
    CMP EAX, 0                                                                      ; Check if quotient is zero
    JNZ _WriteValLoop                                                               ; If not, continue the loop

_WriteValPopLoop:
    POP EAX                                                                         ; Pop the remainder from the stack
    ADD AL, '0'                                                                     ; Convert to ASCII
    MOV [EDI], AL
    ADD EDI, 1
    LOOP _WriteValPopLoop                                                           ; Loop for each remainder
    MOV BYTE PTR [EDI], 0                                                           ; Add NULL to the string

    mDisplayString [EBP + 4 * 5]                                                    ; Print the string output

    RET 4 * 2
WriteVal ENDP

; -- farewell --
; Procedure to bid farewell to user.
; Preconditions: Reference to strings that need to be printed
; Postconditions: Change EDX
; Receives: Parameter message (reference, input) [EBP + 4 * 2]
; Returns: Print goodbye to console
farewell PROC USES EBP
	MOV EBP, ESP
	mDisplayString [EBP + 4 * 2]										            ; Location to message from stack (subtract EBP, return address)

	RET 4 * 1															            ; Pop message
farewell ENDP

END main
