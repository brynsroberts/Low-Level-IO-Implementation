TITLE Assignment6_BryanRoberts     (Assignment6_BryanRoberts.asm)

; Author: Bryan Roberts
; Last Modified: 05/24/20
; OSU email address: robertb2@oregonstate.edu
; Course number/section: CS271-400
; Project Number: Assignment 6	               Due Date: 6/07/20
; Description: The program implements low level string to decimal and decimal to string conversion.
; It implements a test program which will collect 10 decimal values from the user which need to fit
; within a signed 32-bit range.  User input is validated and then converted from the string input to
; a decimal value and stored in the array.  After collecting 10 values from the user, the values will
; be displayed back to the user, converting the decimal values to strings.  Then the sum and average
; will be calculated based on the decimal values, and will be converted to strings to display to the
; console.  Then a farewell prompt will display.


INCLUDE Irvine32.inc
; (insert MACRO here)
;------------------------------------------MACRO:getString-------------------------------------------;
; Prompt asks user to enter string, string is entered and stored in userString
; receives: OFFSET prompt, OFFSET userString, stringCapacity, userStringLength
; returns: user entered string in userString, length of string in userStringLength
; preconditions: stringSize stores capacity of userString
; registers changed: none
;----------------------------------------------------------------------------------------------------;
getString				MACRO promptOffset, userString, stringCapacity, userStringLength 

	; save registers
	push				edx
	push				ecx
	push				eax

	; display prompt, accept user input
	; save length of userString in userStringLength
	displayString			promptOffset
	mov				edx, userString
	mov				ecx, stringCapacity
	call				ReadString
	mov				userStringLength, eax

	; reset registers
	pop				eax
	pop				ecx
	pop				edx
ENDM

;-----------------------------------------MACRO:displayString----------------------------------------;
; Display string stored in stringOffset to console
; receives: OFFSET string
; returns: none
; preconditions: stringOffset is address to null terminated string
; registers changed: none
;----------------------------------------------------------------------------------------------------;
displayString				MACRO stringOffset
	push				edx
	mov				edx, stringOffset
	call				WriteString
	pop				edx
ENDM

; (insert constant definitions here)
ARRAYSIZE = 10
STRINGSIZE = 32

.data

; (insert variable definitions here)
; output strings
introduction001				BYTE	"ASSIGNMENT 6: Designing low-level I/O procedures", 0
introduction002				BYTE	"Written by: Bryan Roberts", 0
introduction003				BYTE	"Please provide 10 signed decimal integers.", 0
introduction004				BYTE	"Each number needs to be small enough to fit inside a 32 bit register.", 0
introduction005				BYTE	"After you have finished inputting the raw numbers I will display a list", 0
introduction006				BYTE	"of the integers, their sums, and their average value.", 0
enterNumberPrompt			BYTE	"Please enter a signed number: ", 0
errorPrompt				BYTE	"ERROR: You did not enter a signed number or your number was too big.", 0
tryAgainPrompt				BYTE	"Please try again: ", 0
displayPrompt				BYTE	"You entered the following numbers:", 0
comma					BYTE	", ", 0
sumPrompt				BYTE	"The sum of these numbers is: ",0
averagePrompt				BYTE	"The rounded average is: ", 0
farewellPrompt				BYTE	"Goodbye, and thanks for using my program!", 0

; arrays and variable strings
array					DWORD	ARRAYSIZE DUP(0)
userString				BYTE	STRINGSIZE DUP(0)

; variables
userStringSize				DWORD	SIZEOF userString
userStringLength			DWORD	?
numSum					DWORD	?
sum					DWORD	?
average					DWORD	?

.code
main PROC
	; introduction
	push				OFFSET introduction006
	push				OFFSET introduction005
	push				OFFSET introduction004
	push				OFFSET introduction003
	push				OFFSET introduction002
	push				OFFSET introduction001
	call				introduction
	
	; read in ARRAYSIZE vals and store in array after validating input
	push				userStringLength
	push				userStringSize
	push				ARRAYSIZE
	push				OFFSET userString
	push				OFFSET array
	push				OFFSET tryAgainPrompt
	push				OFFSET errorPrompt
	push				OFFSET enterNumberPrompt
	call				readVal

	; display user entered numbers in array
	push				numSum
	push				OFFSET userString
	push				OFFSET displayPrompt
	push				OFFSET comma
	push				ARRAYSIZE
	push				OFFSET array
	call				displayList

	; calculate and display sum and average of numbers stored in array
	push				OFFSET average
	push				OFFSET sum
	push				numSum
	push				OFFSET userString
	push				OFFSET array
	push				ARRAYSIZE
	push				OFFSET averagePrompt
	push				OFFSET sumPrompt
	call				calculations

	; farewll
	push				OFFSET farewellPrompt
	call				farewell

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)
;----------------------------------------------intro------------------------------------------------;
; Procedure to introduce the program using displayString
; receives: address of introduction001 - introduction006 on system stack
; returns: none
; preconditions: null terminated strings stored in introduction001- introduction006
; registers changed: none 
; STACK FRAME STATE
; ebp					(ebp)		
; RET @					(ebp + 4)
; introduction001 @			(ebp + 8)
; introduction002 @			(ebp + 12)
; introduction003 @			(ebp + 16)
; introduction004 @			(ebp + 20)
; introduction005 @			(ebp + 24)
; introduction006 @			(ebp + 28)
;----------------------------------------------------------------------------------------------------;
introduction PROC
	push				ebp
	mov				ebp, esp

	displayString			[ebp + 8]			; value of introduction001
	call				Crlf

	displayString			[ebp + 12]			; value of introduction002
	call				Crlf
	call				Crlf

	displayString			[ebp + 16]			; value of introduction003
	call				Crlf

	displayString			[ebp + 20]			; value of introduction004
	call				Crlf
	
	displayString			[ebp + 24]			; value of introduction005
	call				Crlf

	displayString			[ebp + 28]			; value of introduction006
	call				Crlf
	call				Crlf

	pop				ebp
	ret				24
introduction ENDP

;--------------------------------------------farewell------------------------------------------------;
; Says farewell to the user of the program using displayString
; receives: address of farewellPrompt on system stack
; returns: none
; preconditions: none
; registers changed: none
; STACK FRAME STATE
; ebp					(ebp)		
; RET @					(ebp + 4)
; farewellPrompt @			(ebp + 8)
;----------------------------------------------------------------------------------------------------;
farewell PROC
	push				ebp
	mov				ebp, esp

	displayString			[ebp + 8]			; value of farewellPrompt

	pop				ebp
	ret				4
farewell ENDP

;--------------------------------------------calculations--------------------------------------------;
; calculates the sum and average of the array and displays value to the user
; receives:	OFFSET sumPrompt, OFFSET averagePrompt, ARRAYSIZE, OFFSET array, OFFSET userString,
;			numSum, OFFSET sum, OFFSET average on system stack
; returns: none
; preconditions:sumPrompt, and averagePrompt contain null terminated strings, array contains values
;			from users already entered into array.  numSum set to 0.
; registers changed: none
; STACK FRAME STATE
; ebp					(ebp)		
; RET @					(ebp + 4)
; sumPrompt @				(ebp + 8)
; averagePrompt @			(ebp + 12)
; ARRAYSIZE				(ebp + 16)
; array @				(ebp + 20)
; userString @				(ebp + 24)
; numSum				(ebp + 28)
; sum @					(ebp + 32)
; average @				(ebp + 36)
;----------------------------------------------------------------------------------------------------;
calculations PROC
	push				ebp
	mov				ebp, esp
	mov				edi, [ebp + 20]				; edi stores address of array
	mov				ecx, [ebp + 16]				; ARRAYSIZE
	mov				eax, 0

	; loop through the array and add up values in eax register
sumArray:
	mov				ebx, [edi]
	add				eax, ebx
	add				edi, 4
	loop				sumArray

	displayString			[ebp + 8]				; sumPrompt

	; call writeVal to turn sum into a string and display to user
	mov				ebx, [ebp + 32]
	mov				[ebx], eax
	push				[ebp + 28]
	push				[ebp + 24]
	push				ebx
	call				writeVal
	call				Crlf

	displayString			[ebp + 12]				; averagePrompt

	; divide calculated sum by ARRAYSIZE to get average
	mov				edx, 0
	cdq
	mov				ecx, [ebp + 16]
	idiv				ecx
	mov				ebx, [ebp + 36]
	mov				[ebx], eax
	mov				[ebx], eax

	; call writeVal to turn average into a string and display to user
	push				[ebp + 28]
	push				[ebp + 24]
	push				ebx
	call				writeVal
;	call				WriteInt
	call				Crlf
	call				Crlf

	pop				ebp
	ret				32
calculations ENDP

;--------------------------------------------writeVal------------------------------------------------;
; take offset of decimal value and turn into a string, output string to user with displayString
; receives: OFFSET number in array to write, OFFSET userString, numSum on system stack 
; returns: writes decimal value as string to console
; preconditions: number in address of num is decimal value 
; registers changed: none
; STACK FRAME STATE
; ebp					(ebp)
; RET @					(ebp + 20)
; address of num @			(ebp + 24) 
; userString @				(ebp + 28) 
; numSum				(ebp + 32) 
;----------------------------------------------------------------------------------------------------;
writeVal PROC

	; save registers used in procedure
	push				ebp
	push				edi
	push				ecx
	push				ebx
	push				eax
	mov				ebp, esp
	mov				edi, [ebp + 28]				; userString
	mov				ebx, [ebp + 24]				; OFFSET of number to convert

	; compare value to 0, if 0 skip all processing and go straight to zeroNum
	mov				eax, [ebx]					
	cmp				eax, 0
	je				zeroNum

	; multiply by 1 to set sign flag, write correct sign into userString based on sign flag
	mov				ebx, 1
	imul				ebx							
	js				negative
	mov				eax, 43
	jmp				firstNum
negative:
	mov				eax, 45
firstNum:
	stosb										

	; divide number by decreasing multiples of 10 starting at 1000000000 until value shows up in quotient
	; number is converted to positive number if it is currently negative
	mov				ecx, 1000000000
repeatDiv:
	mov				ebx, [ebp + 24]				; OFFSET of number to convert
	mov				eax, [ebx]					
	mov				ebx, 1
	imul				ebx							
	jns				putInNumSum
	mov				ebx, -1
	imul				ebx

	; put original decimal value in num to start subracting from
putInNumSum:
	mov				[ebp + 32], eax				; numSum
cont:
	cdq
	idiv				ecx
	cmp				eax, 0
	jne				finishDiv	
	mov				ebx, 10
	mov				eax, ecx
	cdq
	div				ebx
	mov				ecx, eax
	jmp				repeatDiv

	; write value found in eax into userString by converting number to acsii character
finishDiv: 
	add				eax, 48
	stosb
	sub				eax, 48

	; subtract off most significant digit, now in [ebp + 32]
	mul				ecx
	sub				[ebp + 32], eax				
	mov				eax, ecx
	mov				ecx, 10
	div				ecx
	mov				ecx, eax
	mov				eax, [ebp + 32]

	; if our divisor ecx is 0, then we have gone through every digit of our number, go to finishString
	; else continue to divide number by 10 and write value into userString as ascii character
	cmp				ecx, 0
	je				finishString
	div				ecx
	jmp				finishDiv

	; if original value was 0, no need to do all that work, just add 0 to userString and continue
zeroNum:
	add				eax, 48
	stosb
	sub				eax, 48

	; add null terminated character to string and display string to console with displayStrign macro
finishString:
	mov				eax, 0
	stosb
	displayString			[ebp + 28]				; userString

	; reset registers
	pop				eax
	pop				ebx
	pop				ecx
	pop				edi
	pop				ebp
	ret				12
writeVal ENDP

;--------------------------------------------readVal-------------------------------------------------;
; read in ARRAYSIZE values as strings, validate input, and write correct input into array as decimal
; receives: OFFSET enterNumberPrompt, OFFSET errorPrompt, OFFSET tryAgainPrompt, OFFSET array,
;			OFFSET userString, ARRAYSIZE, userStringSize, userStringLength on system stack
; returns: filled array with user input values
; preconditions: all strings by userString contain null terminated strings.  Array has space to store
;			ARRAYSIZE values. 
; registers changed: none
; STACK FRAME STATE
; ebp					(ebp)		
; RET @					(ebp + 4)
; enterNumberPrompt @			(ebp + 8)
; errorPrompt @				(ebp + 12)
; tryAgainPrompt @			(ebp + 16)
; array @				(ebp + 20)
; userString @				(ebp + 24)
; ARRAYSIZE				(ebp + 28)
; userStringSize			(ebp + 32)
; userStringLength			(ebp + 36)
;----------------------------------------------------------------------------------------------------;
readVal PROC
	push				ebp
	mov				ebp, esp
	mov				edi, [ebp + 20]				; array		
	mov				ecx, [ebp + 28]				; ARRAYSIZE
	mov				eax, 0

	; if bad input has been entered, eax will by 1
	; display correct prompt based on value of eax
fillArray:
	cmp				eax, 0
	jne				badPrompt
	getString			[ebp + 8], [ebp + 24], [ebp + 32], [ebp + 36]
	jmp				afterPrompt
badPrompt:
	displayString			[ebp + 12]
	Call				Crlf
	getString			[ebp + 16], [ebp + 24], [ebp + 32], [ebp + 36]

	; we now have unvalidated userString, setup for looping through each character, validating
	; and turning string in decimal
afterPrompt:
	push				ecx
	mov				ecx, [ebp + 36]				; userStringLength
	mov				esi, [ebp + 24]				; userString
	mov				ebx, 0					; starter value
	cld								
charLoop:
	mov				eax, 0
	lodsb

	; check if character is outside decimal value in ascii table
	; if characters is outside decimal values in ascii table, jump to characterFound
	; if character is in decimal value, jump to startCalculation
	cmp				eax, 48
	jl				characterFound
	cmp				eax, 57
	jg				characterFound
	jmp				startCalculation
	
	; if we are on first character, see if its a sign character
	; if so move onto the next character, if not, input is bad
characterFound:
	cmp				ecx, [ebp + 36]				; check to see if we are on first character
	jne				badInput
	cmp				eax, 43					; compare to + sign
	je				signFound
	cmp				eax, 45					; compare to - sign
	je				signFound
	jmp				badInput				; invalid character found, jump to badInput
signFound:	
	dec				ecx
	jmp				charLoop
badInput:
	mov				eax, 1
	pop				ecx
	jmp				fillArray

	; loop through each character and calculate decimal value represented by string
	; basically find each successive most significant decimal, and build up the 
	; value stored in the string by multiplying by 10 and adding previous value
	; unless we are in least significant digit, in which case we don't multiply by 10
startCalculation:
	sub				eax, 48
	add				eax, ebx

	; check for overflow to validate decimal values that are too large or too small
	jo				badInput

	; check if we are in least significant digit, if so skip multiplying by 10
	cmp				ecx, 1
	je				skipMult

	; if mul results in change of edx value, number is too large for 32-bit register
	push				ebx
	mov				ebx, 10
	mov				edx, 0
	mul				ebx
	pop				ebx
	cmp				edx, 0
	jne				badInput
skipMult:
	mov				ebx, eax
	dec				ecx
	cmp				ecx, 0
	jg				charLoop

	; if first value in string was a - sign, multiply by -1
	mov				esi, [ebp + 24]				; userString
	mov				eax, 0
	lodsb
 	cmp				eax, 45
	jne				putInArray
	mov				eax, -1
	imul				ebx
	mov				ebx, eax

	; put decimal value in next position of array
putInArray:
	pop				ecx
	mov				[edi], ebx
	add				edi, 4
	mov				eax, 0
	dec				ecx
	cmp				ecx, 0
	jg				fillArray

	pop				ebp
	ret				32
readVal ENDP

;----------------------------------------------displayList-------------------------------------------;
; display values stored in array, calling writeString to convert decimal value to string and display
; receives:	OFFSET array, ARRAYSIZE, OFFSET comma, OFFSET displayPrompt, OFFSET userString, numSum
;			on system stack.
; returns:	displays values in array to console
; preconditions: array has ARRAYSIZE values, all strings are null terminated
; registers changed: none
; STACK FRAME STATE
; ebp					(ebp)		
; RET @					(ebp + 4)
; array @				(ebp + 8)
; ARRAYSIZE				(ebp + 12)
; comma @				(ebp + 16)
; displayPrompt	@			(ebp + 20)
; userString @				(ebp + 24)
; numSum				(ebp + 28)
;----------------------------------------------------------------------------------------------------;
displayList PROC	
	push				ebp
	mov				ebp, esp
	mov				ecx, [ebp + 12]				; ARRAYSIZE
	mov				edi, [ebp + 8]				; array

	; displayPrompt
	call				Crlf
	displayString			[ebp + 20]
	call				Crlf

	; loop through array, convert number to string and display to console
nextElement:
	mov				eax, [edi]
	push				[ebp + 28]
	push				[ebp + 24]
	push				edi
	call				writeVal
	add				edi, 4
	cmp				ecx, 1
 	je				skip

	; write ", " to console
	mov				edx, [ebp + 16]
	call				WriteString

	; don't add comma if on last number
skip:
	loop				nextElement
	call				Crlf
	call				Crlf

	pop				ebp
	ret				24
displayList ENDP

END main
