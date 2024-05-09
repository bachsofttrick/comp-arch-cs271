TITLE Create, Sort, Count Appearance of random integers     (Proj5_934553922.asm)

; Author: Bach Xuan Phan (934553922)
; Last Modified: 11/25/2023
; OSU email address: phanx@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 5                Due Date: 11/26/2023
; Description: Generate an array of random integer, display its elements.
;              After that, sort the array in ascending order and display the median value of the array and
;              the array again in order. Print the count of each unique value in the array, starting with the lowest value.

INCLUDE Irvine32.inc

; [LO, HI]
LO = 15
HI = 50

; Size for the random-generated number array
ARRAYSIZE = 200

; Numbers displayed per row
NUMPERROW = 20

.data
 greeting		BYTE	"Create, sort, counting random integers by Bach Xuan Phan",0
 instructToUser	BYTE	"Enter a positive number within a range.",13,10,
						"The program will create and display an array of random integers, sort in ascending order and display the median value of the array and the array again in order.",13,10,
						"It will also print the count of each unique value in the array, starting with the lowest value.",13,10,0
 goodbye		BYTE	"It's over. Tata for now!",0
 unsortQuote	BYTE	"Your unsorted random numbers: ",0				; Message for printing unsorted array
 sortQuote		BYTE	"Your sorted random numbers: ",0				; Message for printing sorted array
 medianQuote	BYTE	"The median value of the array: ",0				; Message for printing median value of the array
 countQuote		BYTE	"The number of each unique integer, starting with the smallest value: ",0
 commaSign		BYTE	", ",0
 colonSign		BYTE	": ",0
 periodSign		BYTE	".",0
 bracketSign1	BYTE	"[",0
 bracketSign2	BYTE	"]",0
 spacerSign		BYTE	" ",0											; Separator for each number
 randArray		DWoRD	ARRAYSIZE DUP (0)								; Array of integers
 counts			DWoRD	HI-LO+1 DUP (0)									; Array of numbers of each unique integer, in ascending order

.code
main PROC
	; Call Randomize once to generate a random seed
	CALL Randomize
	
	; Introduce the program
	; introduction{intro1 (reference, input), intro2 (reference, input)}
	PUSH OFFSET greeting
	PUSH OFFSET instructToUser
	CALL introduction

	; Create an array filled with random integer within a limit
	; fillArray{arrayOutput (reference, output), elementTypeLength (value, input)}
	PUSH OFFSET randArray
	PUSH DWORD PTR TYPE randArray
	CALL fillArray 					

	; Display the unsorted array
	; displayList{message (reference, input), arrayToPrint (reference, input), arrayLength (value, input), elementTypeLength (value, input), numPerRow (value, input)}
	PUSH OFFSET unsortQuote
	PUSH OFFSET randArray
	PUSH DWORD PTR LENGTHOF randArray
	PUSH DWORD PTR TYPE randArray
	PUSH DWORD PTR NUMPERROW
	CALL displayList

	; Sort an array in ascending order
	; sortList{arrayToSort (reference, input/output), elementTypeLength (value, input)}
	PUSH OFFSET randArray
	PUSH DWORD PTR TYPE randArray
	CALL sortList

	; Display median of the sorted array
	; displayMedian{message (reference, input), arrayToCalc (reference, input), arrayLength (value, input), elementTypeLength (value, input)}
	PUSH OFFSET medianQuote
	PUSH OFFSET randArray
	PUSH DWORD PTR LENGTHOF randArray
	PUSH DWORD PTR TYPE randArray
	CALL displayMedian

	; Display the sorted array
	; displayList{message (reference, input), arrayToPrint (reference, input), arrayLength (value, input), elementTypeLength (value, input), numPerRow (value, input)}
	PUSH OFFSET sortQuote
	PUSH OFFSET randArray
	PUSH DWORD PTR LENGTHOF randArray
	PUSH DWORD PTR TYPE randArray
	PUSH DWORD PTR NUMPERROW
	CALL displayList

	; Print the count of each unique value in an integer array
	; countList{arrayToCount (reference, input), uniqueCountArray (reference, output), message (reference, input), elementTypeLength (value, input)}
	PUSH OFFSET randArray
	PUSH OFFSET counts
	PUSH OFFSET countQuote
	PUSH DWORD PTR TYPE randArray
	CALL countList

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
; Receives: Parameters intro1 (reference, input), intro2 (reference, input)
; Returns: Print intro1, intro2 to console
introduction PROC USES EBP
	MOV EBP, ESP
	MOV EDX, [EBP + 4 * 3]												; Location to intro1 from stack (subtract EBP, return address, intro2)
	CALL WriteString
	CALL CrLf
	MOV EDX, [EBP + 4 * 2]												; Location to intro2 from stack (subtract EBP, return address)
	CALL WriteString
	CALL CrLf
	
	RET 4 * 2															; Pop intro1, intro2
introduction ENDP

; -- fillArray --
; Procedure to fill array with random integers.
; Preconditions: Value to specify the element of the array's length, a reference to an empty array that needs to be populated with integers
; Postconditions: EDI, ECX, EAX, content inside arrayOutput changed
; Receives: Parameters arrayOutput (reference, output), elementTypeLength (value, input)
; Returns: Change arrayOutput by filling it with integers
fillArray PROC USES EBP
	MOV EBP, ESP
	MOV EDI, [EBP + 4 * 3]												; Location to arrayOutput from stack (subtract EBP, return address, elementTypeLength), put to EDI as destination base pointer
	MOV ECX, ARRAYSIZE													; Update loop count to keep track of the quantity to generate
	
_GenerateRandomNumbers:
	; Generate a random integer <= HI, if it is < LO then do it again
	MOV EAX, HI + 1
	CALL RandomRange													; Generate number from 0 - HI, must remove any number < LO
	CMP EAX, LO
	JL _GenerateRandomNumbers

	; Put that number to the array and increment the pointer (EDI)
	MOV [EDI], EAX
	ADD EDI, [EBP + 4 * 2]												; Add the element's length (elementTypeLength) to push array to the next element (subtract EBP, return address)
	LOOP _GenerateRandomNumbers
	
	RET 4 * 2															; Pop arrayOutput, elementTypeLength
fillArray ENDP

; -- sortList --
; Procedure to sort an array in ascending order.
; Preconditions: Reference to an integer array that needs to be sorted
; Postconditions: ESI, ECX, EAX, EBX, content inside arrayToSort changed
; Receives: Parameter arrayToSort (reference, input/output), elementTypeLength (value, input)
; Returns: arrayToSort with sorted content
sortList PROC USES EBP
	MOV EBP, ESP

	; Establish outer loop
	MOV ECX, ARRAYSIZE

_OuterLoopOfSort:
	PUSH ECX

	; Establish inner loop
	MOV ECX, ARRAYSIZE - 1
	MOV ESI, [EBP + 4 * 3]												; Location to arrayToSort from stack (subtract EBP, return address, elementTypeLength), put to ESI as source base pointer

_InnerLoopOrSort:
	MOV EAX, [ESI]
	ADD ESI, [EBP + 4 * 2]												; Move to the next index by adding elementTypeLength, take that integer to compare with the previous integer (subtract EBP, return address)
	MOV EBX, [ESI]

	; If the first integer is bigger than the second integer, perform exchange element
	CMP EAX, EBX
	JLE _JumpBackToInnerLoopOfSort
	; Need to ESI forward if exchange doesn't happen
	SUB ESI, [EBP + 4 * 2]												; Move to the previous index by subtracting elementTypeLength (subtract EBP, return address)
	PUSH ESI
	ADD ESI, [EBP + 4 * 2]
	PUSH ESI
	CALL exchangeElements

_JumpBackToInnerLoopOfSort:
	LOOP _InnerLoopOrSort

	; Jump back to outer loop after running out of inner loop
	POP ECX
	LOOP _OuterLoopOfSort

	RET 4 * 2															; Pop arrayToSort, elementTypeLength
sortList ENDP

; -- exchangeElements --
; Procedure to exchange two integer elements.
; Preconditions: Two references to integer elements
; Postconditions: EDI, EAX, EBX, content inside element1, element2 changed
; Receives: Parameters element1 (reference, input/output), element2 (reference, input/output)
; Returns: Integers element1, element2 with their addresses exchanged
exchangeElements PROC USES EBP ESI
	MOV EBP, ESP
	MOV ESI, [EBP + 4 * 4]												; Get element1's address to the source register (subtract ESI, EBP, return address, element2)
	MOV EDI, [EBP + 4 * 3]												; Get element2's address to the destination register (subtract ESI, EBP, return address)
	
	; Swap elements
	MOV EAX, [ESI]
	MOV EBX, [EDI]
	MOV [EDI], EAX
	MOV [ESI], EBX

	RET 4 * 2															; Pop element1, element2
exchangeElements ENDP

; -- displayMedian --
; Procedure to calculate and display median of an integer array.
; Preconditions: A reference to a string for displaying message, a reference to an integer array, that array's length as value
; Postconditions: ESI, EAX, EBX, EDX changed
; Receives: Parameters message (reference, input), arrayToCalc (reference, input), arrayLength (value, input), elementTypeLength (value, input)
; Returns: Print message and the median of arrayToCalc to console 
displayMedian PROC USES EBP
	MOV EBP, ESP
	MOV ESI, [EBP + 4 * 4]												; Location to arrayToCalc from stack (subtract EBP, return address, elementTypeLength, arrayLength)

	; Print display message
	MOV EDX, [EBP + 4 * 5]												; Location to message from stack (subtract EBP, return address, elementTypeLength, arrayLength, arrayToCalc)
	CALL WriteString
	
	MOV EDX, 0
	MOV EAX, DWORD PTR [EBP + 4 * 3]									; Get arrayLength to find the position of the median (subtract EBP, return address, elementTypeLength)
	
	; Check if arrayLength is even or odd by checking the remainder
	; If even (rem = 0), the median value is the average of the indexes quotinent and quotient - 1
	; If odd (rem = 1), the median value is at the quotinent index
	MOV EBX, 2
	DIV EBX
	CMP EDX, 0
	JZ _DivIsEven
	
	MOV EBX, [EBP + 4 * 2]												; Get the element's length (elementTypeLength) (subtract EBP, return address)
	MUL EBX																; Multiply with the quotinent index to get the address offset in EAX
	ADD ESI, EAX														; Add the offset to source register ESI
	MOV EAX, [ESI]
	JMP _PrintAndReturnToMain

_DivIsEven:
	MOV EBX, [EBP + 4 * 2]												; Get the element's length (elementTypeLength) (subtract EBP, return address)
	MUL EBX																; Multiply with the quotinent index to get the address offset in EAX
	ADD ESI, EAX														; Add the offset to source register ESI
	MOV EAX, [ESI]
	
	SUB ESI, [EBP + 4 * 2]												; Find the number in the index quotient - 1 by subtracting address from source register ESI
	ADD EAX, [ESI]														; Add it to the sum so that we can calculate the average of the two integers
	MOV EBX, 2
	DIV EBX
	CMP EDX, 0
	JZ _PrintAndReturnToMain
	ADD EAX, 1															; Round up the median value if the remainder is 1, which makes the result of the division x.5

_PrintAndReturnToMain:
	CALL WriteDec														; The average value is already in EAX
	CALL CrLf
	CALL CrLf

	RET 4 * 4															; Pop message, arrayToCalc, arrayLength, elementTypeLength
displayMedian ENDP

; -- displayList --
; Procedure to display an integer array.
; Preconditions: A reference to a string for displaying message, a reference to an integer array, that array's length as value,
; the type length of an element from that array, number per row in print 
; Postconditions: ESI, EAX, EBX, ECX, EDX changed
; Receives: Parameters message (reference, input), arrayToPrint (reference, input), arrayLength (value, input), elementTypeLength (value, input), numPerRow (value, input)
; Returns: Print content inside the integer array
displayList PROC USES EBP
	MOV EBP, ESP
	MOV ESI, [EBP + 4 * 5]												; Location to arrayToPrint from stack (subtract EBP, return address, numPerRow, elementTypeLength, arrayLength), put to ESI as source base pointer
	MOV ECX, [EBP + 4 * 4]												; Update loop count to keep track of the number to display (subtract EBP, return address, numPerRow, elementTypeLength)

	; Print display message
	MOV EDX, [EBP + 4 * 6]												; Location to message from stack (subtract EBP, return address, numPerRow, elementTypeLength, arrayLength, arrayToPrint)
	CALL WriteString
	CALL CrLf

_PrintElement:
	MOV EAX, [ESI]
	CALL WriteDec
	MOV AL, ' '
	CALL WriteChar
	ADD ESI, [EBP + 4 * 3]												; Add the element's length (elementTypeLength) to push array to the next element (subtract EBP, return address, numPerRow)

	; Get the number of integers printed and check to see if we need a new row
	MOV EAX, [EBP + 4 * 4]												; Get the array length (arrayLength) (subtract EBP, return address, numPerRow, elementTypeLength)
	SUB EAX, ECX
	ADD EAX, 1
	MOV EDX, 0
	DIV DWORD PTR [EBP + 4 * 2]											; Divide the number of integers with numPerRow and check its remainder
	CMP EDX, 0															; Compare to numPerRow to see if it is necessary to start a new line (subtract EBP, return address)
	JNZ _ReturnToPrintElement											; Start a new line when the remainder is 0 (the number of integers reaches numPerRow, numPerRow * 2...)
	CALL CrLf

_ReturnToPrintElement:
	LOOP _PrintElement
	CALL CrLf
	CALL CrLf

	RET 4 * 5															; Pop message, arrayToPrint, arrayLength, elementTypeLength, numPerRow
displayList ENDP

; -- countList --
; Procedure to print the count of each unique value in an integer array, starting with the lowest value.
; Preconditions: A reference to an integer array to count, a reference to an array about the count of unique values of the previous array,
; a reference to a string for displaying message, the type length of an element from that array
; Postconditions: ESI, EDI, EAX, EBX, ECX, EDX, content inside uniqueCountArray changed
; Receives: Parameters arrayToCount (reference, input), uniqueCountArray (reference, output), message (reference, input), elementTypeLength (value, input)
; Returns: Array uniqueCountArray with the count of each unique integer
countList PROC USES EBP
	MOV EBP, ESP

	MOV ECX, ARRAYSIZE													; Update loop count to keep track of the index on arrayToCount
	MOV ESI, [EBP + 4 * 5]												; Location to arrayToCount from stack (subtract EBP, return address, elementTypeLength, message, uniqueCountArray), put to ESI as source base pointer
	MOV EDI, [EBP + 4 * 4]												; Location to uniqueCountArray from stack (subtract EBP, return address, elementTypeLength, message), put to EDI as destination base pointer

_CountListLoop:
	; Get the index of uniqueCountArray to EAX to increment its value
	MOV EAX, [ESI]
	SUB EAX, LO
	
	MOV EBX, [EBP + 4 * 2]												; Get the element's length (elementTypeLength) (subtract EBP, return address)
	MUL EBX																; Multiply with the index in EAX to get the number of bytes to reach the index address in EDI
	INC DWORD PTR [EDI + EAX]											; Increment count of the integer in uniqueCountArray
	
	; Move to the next index of arrayToCount
	ADD ESI, [EBP + 4 * 2]
	LOOP _CountListLoop
	
	; Display the count array uniqueCountArray
	; displayList{message (reference, input), arrayToPrint (reference, input), arrayLength (value, input), elementTypeLength (value, input), numPerRow (value, input)}
	PUSH [EBP + 4 * 3]
	PUSH [EBP + 4 * 4]
	PUSH DWORD PTR HI-LO+1
	PUSH [EBP + 4 * 2]
	PUSH DWORD PTR NUMPERROW
	CALL displayList

	RET 4 * 4															; Pop arrayToCount, uniqueCountArray, message, elementTypeLength
countList ENDP

; -- farewell --
; Procedure to bid farewell to user.
; Preconditions: Reference to strings that need to be printed
; Postconditions: Change EDX
; Receives: Parameter message (reference, input)
; Returns: Print goodbye to console
farewell PROC USES EBP
	MOV EBP, ESP
	MOV EDX, [EBP + 4 * 2]												; Location to message from stack (subtract EBP, return address)
	CALL WriteString
	CALL CrLf

	RET 4 * 1															; Pop message
farewell ENDP

END main
