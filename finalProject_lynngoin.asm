TITLE final.asm
; Author:  Matthew Lynn-Goin
; Date:  7 May 2018
; Description: This program is a game of connect3 the program presents a menu allowing the user to pick a menu option
;              which then performs a given task.
; 1.  Player 1 vs Player 2. //allows two players to play against each other
; 2.  Player1 vs Computer1. //Alllows the player to playy against the computer
; 3.  Computer1 vs Computer2. //the computer plays against itself
; 4.  Exit
;///
; ====================================================================================

Include Irvine32.inc 

;//all of the necessary proto calls for invoking the functions

playerVplayer proto, matrixPtr: ptr byte, matrixRow: byte, wins1: ptr byte, numGames1: ptr byte
playerVcomputer proto, matrixPtr2: ptr byte, matrixRow2: byte, wins2: ptr byte, numGames2: ptr byte
computerVcomputer proto, matrixPtr3: ptr byte, matrixRow3: byte
displayBoard proto, matrixPtr4: dword , matrixRow4: byte
clearBoard proto, mtrxPtr5: ptr byte, matrixRow5: byte
decideOrder proto
fillMatrix proto, matrixPtr6: ptr byte, matrixRow6: byte, whichPlayer: byte, userChoice: byte


;//Macros
ClearEAX textequ <mov eax, 0> ;//macros to clear the registers
ClearEBX textequ <mov ebx, 0>
ClearECX textequ <mov ecx, 0>
ClearEDX textequ <mov edx, 0>
ClearESI textequ <mov esi, 0>
ClearEDI textequ <mov edi, 0>


.data
Menuprompt1 byte 'MAIN MENU', 0Ah, 0Dh, ;//menu display
'==============================================', 0Ah, 0Dh,
'Welcome to the connect three game[Please select from the following options]', 0Ah, 0Dh,
'==============================================', 0Ah, 0Dh,
'1. Player 1 vs Player 2', 0Ah, 0Dh,
'2. Player 1 vs Computer1 ',0Ah, 0Dh,
'3. Computer1 vs Computer2 ',0Ah, 0Dh,
'4. Exit: ',0Ah, 0Dh, 0h
UserOption byte 0h ;//declare a variable to hold the user option
errormessage byte 'You have entered an invalid option. Please try again.', 0Ah, 0Dh, 0h ;//an array to display an error message
mainprompt1 byte '=============================================', 0ah, 0dh, 0h ;//display player 1 game stats
mainprompt2 byte 'PLAYER 1 GAME STATS: ', 0ah, 0dh, 0h
mainprompt3 byte 'Number of Games Played: ', 0h
mainprompt4 byte 'Number of Games Won: ', 0h
mainprompt5 byte 'Number of Games lost: ', 0h

;//matrix to hold information
matrix byte 0h, 0h, 0h, 0h
	   byte 0h, 0h, 0h, 0h
	   byte 0h, 0h, 0h, 0h
	   byte 0h, 0h, 0h, 0h
	   
rowSize = 4;
gamesPlayed byte 0;
gamesWon byte 0;


.code
main PROC

call ClearRegisters          ;// clears registers
startHere:
call clrscr ;//clear the screen
mov edx, offset menuprompt1 ;//move the offset of menu prompt into edx
call WriteString ;//display the menu 
mov edx, offset mainprompt1
call writestring
mov edx, offset mainprompt2
call writestring
mov edx, offset mainprompt3
call writestring
movzx eax, gamesPlayed
call writedec ;//display the number of games played
call crlf
mov edx, offset mainprompt4
call writestring
movzx eax, gamesWon
call writedec ;//displa the number of games won
call crlf
mov edx, offset mainprompt5
call writestring
movzx eax, gamesPlayed
movzx ebx, gamesWon
sub eax, ebx
call writedec ;//display the number of games lost
call crlf
mov edx, offset mainprompt1
call writestring
clearEAX
clearEBX
call readhex ;//read the user choice
mov useroption, al ;//save the user choice

opt1:
cmp useroption, 1 ;//check to see if the user entered 1
jne opt2 ;//jump if not equa to opt2
call clrscr ;//clear the screen
INVOKE playerVplayer, ADDR matrix, rowSize, ADDR gamesWon, ADDR gamesPlayed
INVOKE clearBoard, ADDR matrix, rowSize
jmp starthere ;//jump back to starthere

opt2:
cmp useroption, 2 ;//check to see if the user entered 2
jne opt3 ;//jump not equal to option 3
call clrscr ;//clear the screen
INVOKE playerVcomputer, ADDR matrix, rowSize, ADDR gamesWon, ADDR gamesPlayed
INVOKE clearBoard, ADDR matrix, rowSize
jmp starthere ;//jump back to starthere

opt3:
cmp useroption, 3 ;//check to see if the user entered 3
jne opt4 ;//jump not equal to opt 4
call clrscr ;//clear the screen
INVOKE computerVcomputer, ADDR matrix, rowSize
INVOKE clearBoard, ADDR matrix, rowSize
jmp starthere ;//jump back to starthere

opt4:
cmp useroption, 4 ;//check to see if the user entered 6
jne oops ;//jump not equal to oops
jmp quitit ;//jump to quitit
oops:
push edx ;//push edx to the stack
mov edx, offset errormessage ;//move the offset of errormessage into edx
call writestring ;//display the error message
call waitmsg ;//make the user see the message and wait for a keyboard entry
pop edx ;//restore contents of edx
jmp starthere ;//jump back to starthere

;//end the program....
quitit:
exit
main ENDP
;// Procedures
;// ===============================================================
ClearRegisters Proc
;// Description:  Clears the registers EAX, EBX, ECX, EDX, ESI, EDI
;// Requires:  Nothing
;// Returns:  Nothing, but all registers will be cleared.

cleareax
clearebx
clearecx
clearedx
clearesi
clearedi

ret
ClearRegisters ENDP
;///////////////////////////////////////////////////////////////////////////////////////////////
decideOrder Proc
;// Description:  Decides which player will go first
;// Requires:  Nothing
;// Returns:  The remainder of quotient in ah + 1.

.data
RandRange = 256; //declare a size[max size of unsigned byte]

.code
call randomize ;//set the seed for the random functions
clearEAX;
mov eax, RandRange; //move the random limmit to eax
call RandomRange; //generate a random number
mov bl, 2; //move 2d into bl
div bl; //divide [basically heads or tails]
add ah, 1 ;//add 1 to ah

ret
decideOrder ENDP
;///////////////////////////////////////////////////////////////////////////////////////////////
playerVplayer proc, 
matrixPtr: ptr byte,
matrixRow: byte,
wins1: ptr byte,
numGames1: ptr byte

;// Description: Driver of the player vs player feature of the program.
;// Requires: a pointer to the main matrix that holds the pertinent informaiton, size of the matrix rows, pointer to varibale
;//that hold how many were won, pointer to variable that holds how many games were played total
;// Returns: Nothing-bute updates the games won/played variables.

;/////player2 is yellow. player1 is blue

.data

player byte 0; 
playerTurn byte 0;
playerOne byte 1;
playerTwo byte 2;
option1prompt byte 'Player ', 0h ;//
option1prompt2 byte ' Goes first-[player 1 is blue|player 2 is yellow] ', 0Ah, 0Dh, 0h ;//
option1prompt3 byte 'Please select a column[1-4]: ', 0ah, 0dh, 0h
option1prompt4 byte 'Player 1- ', 0h
option1prompt5 byte 'Player 2- ', 0h
option1prompt6 byte 'HAS WON!', 0ah, 0dh, 0h
option1prompt7 byte 'There has been a DRAW!', 0ah, 0dh, 0h
whoWon byte 0;
maxMoves byte 16;
columnChoice byte 0;
choice1 byte 1;

.code

mov edx, matrixPtr ;//move local pointer varibale into edx[edx now points to matrix]
movzx ebx, matrixRow ;//move zerro extend local varibale into ebx
mov whoWon, 0 ;//clear variable
INVOKE decideOrder
mov player, ah ;//move ah into player(this is the player that will go first)
mov playerTurn, ah ;//move ah into variable
push edx ;//save edx
mov edx, offset option1prompt ;//move offset of message into edx
call writestring ;//dispay
pop edx ;//restore edx
movzx eax, player ;//movzx player into eax
call writedec ;//display the number
push edx ;//save edx
mov edx, offset option1prompt2 ;//move offset of message in to edx
call writestring ;//dispay
pop edx ;//restore edx
;///////////////////////////////loop for the game starts here
movzx ecx, maxMoves ;//move zero extend variable into ecx
call waitmsg ;//make the user see the message
Lpvp1:
call clrscr ;//clear the screen
INVOKE displayBoard, matrixPtr, matrixRow 
movzx ax, playerTurn ;//move zero extend varible into ax
mov bl, 2 ;//move 2 in to bl
div bl ;//divide
cmp ah, 0 ;//see if it is even or odd

ja player1 ;//if odd then its player 1's turn
push ecx ;//save ecx
INVOKE fillMatrix, matrixPtr, matrixRow, playerTwo, choice1
mov whoWon, al ;//move the winner(if any) into whowon
pop ecx ;//restore ecx
jmp endLpvp1

player1:
push ecx ;//save ecx
INVOKE fillMatrix, matrixPtr, matrixRow, playerOne, choice1
mov whoWon, al ;//move al into whowon(if there was a winner)
pop ecx  ;//restore ecx

endLpvp1:
cmp whoWon, 0 ;//if anyone won then jump to endfunction1
ja endFunction1
inc playerTurn; //now its the next players turn
loop Lpvp1

;//if the program reaches here then it was a draw
call clrscr
INVOKE displayBoard, matrixPtr, matrixRow
push edx ;//save edx
mov edx, offset option1prompt7 ;//move offset of message into edx
call writestring ;//display
pop edx ;//restore edx
call waitmsg ;//make the user see the message
jmp endFunction2

endFunction1:

call clrscr
INVOKE displayBoard, matrixPtr, matrixRow 

cmp whoWon, 1 ;//did player one win?
ja next
push edx ;//save edx
mov edx, offset option1prompt4 ;//move offset of message into edx
call writestring ;//display the message
mov edx, offset option1prompt6 ;//move the offset of the next message into edx
call writestring ;//display the message
call waitmsg ;//make the user see the message
;/////////////////////////add one to player one visctory count
push edx ;//save edx
mov edx, wins1 ;//move local pointer varibel into edx
mov bl, 1;//move 1 into bl
add [edx], bl ;//add b to varibel pointed to by edx 
pop edx ;//restore edx
jmp endFunction2

next:
push edx ;//save edx
mov edx, offset option1prompt5 ;//move the offset of the message into edx
call writestring ;//display the message
mov edx, offset option1prompt6 ;//move offset of message into edx
call writestring ;//display the message
pop edx ;//restore edx
call waitmsg 

endFunction2:
;//////add one to the number of games played
push edx ;//save edx
mov edx, numGames1 ;//move pointer varubel into edx
mov bl, 1 ;//move 1 into bl
add [edx], bl ;//add bl to varibel pointed to by edx
pop edx ;//restor edx

ret
playerVplayer endp
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
fillMatrix proc,
matrixPtr6: ptr byte,
matrixRow6: byte,
whichPlayer: byte,
userChoice: byte
;/////this function will aslo decide if there is a winner or loser
;/////remember to add input validation-[DONE]

;// Description: Procedure that fills the matrix and checks if there is a winner after each move.
;// Requires: a pointer to the main matrix that holds the pertinent informaiton, size of the matrix rows, which players turn it is
;// What column choice the particular player chose.
;// Returns: [If there is a winner] the winner number in al, and fills the matrix.



.data

option2prompt3 byte 'Please select a column[1-4]: ', 0ah, 0dh, 0h
option2prompt4 byte 'Player 1- ', 0h
option2prompt5 byte 'Player 2- ', 0h

playerNumber byte 0;
fillMatrixprompt1 byte 'This column is full-please select another column', 0ah, 0dh, 0h
fillMatrixprompt2 byte 'Please enter a column number[1-4]', 0ah, 0dh, 0h
fillMatrixprompt3 byte 'You entered a number outisde the column range. Please enter a cloumn[1-4]', 0ah, 0dh, 0h
Three2win byte 0;
saveSpot dword 0;
rowNumber byte 4;
counter byte 0;
winCount byte 0;
columnNumber byte 0;
randRange2 = 256;

.code
movzx ebx, matrixRow6 ;//movve zero extend matrixRow6 into ebx
mov rowNumber, 4; //reset and clear all of the necessary variables
mov counter, 0;
mov Three2win, 0
mov saveSpot, 0
mov columnNumber, 0
mov winCount, 0


cmp userChoice, 1 ;//see if coming from playerVplayer, playerVComputer, or ComputerVComputer
jne nextUserChoice

cmp whichPlayer, 1 ;//see if it is user1's turn
ja otherPlayer


push edx ;//save edx
mov edx, offset option2prompt4 ;//move offset of message in to edx
call writestring ;//display the message
mov edx, offset option1prompt3 ;//move the offset of message into edx
call writestring ;//display the message
pop edx ;//rrstore edx
call readdec ;//get the new column number
mov columnNumber, al ;//move al into the varibale
jmp startFillMatrix

otherPlayer:

push edx;//save edx
mov edx, offset option2prompt5 ;//mov offset of message into edx
call writestring ;//dispay the message
mov edx, offset option1prompt3 ;//move the offset of message into edx
call writestring ;//display the message
pop edx ;//restore edx
call readdec ;//get the new column numberr
mov columnNumber, al ;//move al into the varibale
jmp startFillMatrix

nextUserChoice:
cmp userChoice, 2 ;//compare userChoice to 2
jne finalUserChoice ;//jump not equal to finaluserchoice
jmp startFillMatrix


finalUserChoice:
;push eax
mov eax, randRange2 ;//set the limit in eax
call RandomRange ;//generate random number
mov bl, 4 ;//move 4 into bl
div bl ;//divide
add ah, 1 ;//add 1 to ah
mov columnNumber, ah ;//move the new column number into variable



startFillMatrix:
cmp whichPlayer, 1 ;//see if its player 1 or 2
ja fillNext
mov playerNumber, 1
jmp fillAfter
fillNext:
mov playerNumber, 2

fillAfter:
cmp columnNumber, 0 ;//see if they chose 0 as a column number[we are making sure its in range 1-4]
ja nextFillMatrix
push edx ;//save edx
mov edx, offset fillMatrixprompt3 ;//move the offset of message into edx
call writestring ;//display the string
pop edx ;//restore edx
call readdec ;//get user input
mov columnNumber, al; //move new columnnumber into varibale
jmp startFillMatrix
nextFillMatrix:
cmp columnNumber, 4 ;//make sure the choice is in range
jbe nextFillMatrix2
push edx ;//save edx
mov edx, offset fillMatrixprompt3 ;//move offset of message into edx
call writestring ;//display message
pop edx ;//restor edx
call readdec ;//get new column number
mov columnNumber, al; //move al into the varibale
jmp startFillMatrix

nextFillMatrix2:

mov ecx, 4 ;//move 4 into ecx
mov edx, matrixPtr6 ;//make edx point to matrix
movzx ebx, columnNumber ;//move zero etxend varibael into ebx
add edx, ebx ;//add ebx to edx
dec edx ;//dec edx
add edx, 12 ;//add 12 to edx

LFM1:
mov al, [edx] ;//move element into al
cmp al, 0 ;//see if it zero
ja endLFM1 ;//if nonzerro 
mov bl, playerNumber ;//move playernumber into bl
mov [edx], bl ;//move bl into element pointed to by edx
inc counter ;//increment counter
jmp endFillMatrix
;mov saveSpot, edx
endLFM1:
sub edx, 4 ;//move up int he column
dec rowNumber ;//decrememnt rowNumber
loop LFM1

fullCol:
cmp userChoice, 3 ;//see if its CompVComp
jne fullColSkip
mov eax, randRange2 ;//move max range into eax
call RandomRange ;//generate random number
mov bl, 4 ;//mov 4 into bl
div bl ;//divide bl
add ah, 1 ;//add 1 to ah
mov columnNumber, ah ;//move new column number into ah
jmp startFillMatrix
fullColSkip:
push edx ;//save edx
mov edx, offset fillMatrixprompt1 ;//move offset of message into edx
call writestring ;//display message
pop edx ;//restor edx
call waitmsg ;//make the user see the message
;//////display the matrix again here
push edx ;//save edx
mov edx, offset fillMatrixprompt2 ;//move the offset of message into edx
call writestring ;//dislay the message
pop edx ;//restor edx
call readdec ;//get new column number
mov columnNumber, al; //move al into varibale
jmp startFillMatrix

;//////////////now we check for a winner
endFillMatrix:
mov edx, matrixPtr6 ;//have edx point to matrix
mov ecx, 4 ;//move 4 into ecx
checkWinner1:
push edx ;//save edx
push ecx ;//save ecx
mov ecx, 2 ;//move 2 into ecx
	checkWinner12:
	push edx ;//save edx
	push ecx ;//save ecx
	mov ecx, 3 ;//move 3 into ecx
		checkWinner121:
		mov al, [edx] ;//move element pointed to by edx into edx
		cmp al, playerNumber ;//see if that number matches the playerNumber
		jne innerskip
		inc Three2win ;//incrment
		innerskip:
		inc edx ;//point to next element
		loop checkWinner121
	cmp Three2win, 3 ;//see if they got 3 in a row
	jne outerSkip
	mov winCount, 1 ;//move 1 to wincount
	outerSkip:
	pop ecx ;//restore ecx
	pop edx ;//restor edx
	inc edx ;//pointot next element
	mov Three2win, 0 ;//clear out varibale
	loop checkWinner12
pop ecx ;//restore ecx
pop edx ;//restore edx
add edx, 4 ;//move down a row
loop checkWinner1


mov edx, matrixPtr6 ;//have edx point to matrix
mov ecx, 4 ;//move 4 into ecx
checkWinner2:
push edx ;//save edx
push ecx ;//save ecx
mov ecx, 2
	checkWinner22:
	push edx ;//save edx
	push ecx ;//save ecx
	mov ecx, 3 ;//move 3 into ecx
		checkWinner221:
		mov al, [edx] ;//move element pointed to by edx into al
		cmp al, playerNumber ;//see if that number is eqal to playerNumber
		jne innerskip2
		inc Three2win ;//incremement aribale if it is equal
		innerskip2:
		add edx, 4 ;//move down a row
		loop checkWinner221
	cmp Three2win, 3 ;//see if the got 3 in a row
	jne outerSkip2
	mov winCount, 1 ;//move 1 into winCount
	outerSkip2:
	pop ecx ;//restore ecx
	pop edx ;//restor edx
	add edx, 4 ;//mobve down a row
	mov Three2win, 0 ;//clear out the varibale
	loop checkWinner22
pop ecx ;//restor ecx
pop edx ;//restore edx
inc edx ;//move to next column
loop checkWinner2

mov edx, matrixPtr6 ;//have edx point to matrix
mov ecx, 2 ;//move 2 into ecx
checkWinner3:
push edx ;//save edx
push ecx ;//save ecx
mov ecx, 2
	checkWinner32:
	push edx ;//save edx
	push ecx ;//save ecx
	mov ecx, 3 ;// mo ve 3 into ecx
		checkWinner321:
		mov al, [edx] ;//move element pinted to by edx into al
		cmp al, playerNumber ;//see if that number matches the playerNumber
		jne innerskip3
		inc Three2win ;//increment varibale
		innerskip3:
		add edx, 5 ;//move in a diagonal
		loop checkWinner321
	cmp Three2win, 3 ;//see if they got 3 in a row
	jne outerSkip3
	mov winCount, 1 ;//move 1 into wincount
	outerSkip3:
	pop ecx ;//restor ecx
	pop edx ;//restor edx
	inc edx ;//point to next element
	mov Three2win, 0 ;//clear the varibale
	loop checkWinner32
pop ecx ;//restore ecx
pop edx ;//restor edx
add edx, 4 ;//move down a row
loop checkWinner3

mov edx, matrixPtr6 ;//have edx point to beginning of matrix
add edx, 2 ;//move 2 elements over
mov ecx, 2 ;//move 2 into ecx
checkWinner4:
push edx ;//save edx
push ecx ;//save ecx
mov ecx, 2 ;//move 2 into ecx
	checkWinner42:
	push edx ;//save edx
	push ecx ;//save ecx
	mov ecx, 3
		checkWinner421:
		mov al, [edx] ;//move element pointed to by edx into al
		cmp al, playerNumber ;//see if that matches the playerNumber
		jne innerskip4
		inc Three2win ;//incrememnt varibale
		innerskip4:
		add edx, 3 ;//move down-left diagonal
		loop checkWinner421
	cmp Three2win, 3 ;//see if they got 3 in a row
	jne outerSkip4
	mov winCount, 1 ;//move 1 into wincount
	outerSkip4:
	pop ecx ;//save ecx
	pop edx ;//save edx
	inc edx ;//point to next element
	mov Three2win, 0 ;//clear varibale
	loop checkWinner42
pop ecx ;//restor ecx
pop edx ;//restore edx
add edx, 4 ;//move down a row
loop checkWinner4


finalfillMatrix:
cmp winCount, 1 ;//see if someone won
jb fillSkip
movzx eax, playerNumber ;//move zer extend the playerNumber into eax
jmp finalfillMatrix2

fillSkip:
clearEAX

finalfillMatrix2:
ret
fillMatrix endp
;///////////////////////////////////////////////////////////////////////////////////////////////// 


;/////////////////////////////////////////////////////////////////////////////////////////////////
playerVcomputer proc, 
matrixPtr2: ptr byte,
matrixRow2: byte,
wins2: ptr byte,
numGames2: ptr byte
;// Description: Implements the player vs computer feature of the program
;// Requires:  pointer to the matrix, size of the row, pointer to varibale holding how many games were won
;//pointer to varibale holding how many games were played
;// Returns:  Nothinng but updates how many games were games were played and won

.data
player3 byte 0;
playerTurn3 byte 0;
playerOne3 byte 1;
playerTwo3 byte 2;
option3prompt byte 'Player ', 0h ;//
option3prompt2 byte ' Goes first-[player 1 is blue|Computer 2 is yellow] ', 0Ah, 0Dh, 0h ;//
option3prompt3 byte 'Please select a column[1-4]: ', 0ah, 0dh, 0h
option3prompt4 byte 'Player 1- ', 0h
option3prompt5 byte 'Computer 2- ', 0h
option3prompt6 byte 'HAS WON!', 0ah, 0dh, 0h
option3prompt7 byte 'There has been a DRAW!', 0ah, 0dh, 0h
whoWon3 byte 0;
maxMoves3 byte 16;
columnChoice3 byte 0;
choice2 byte 1;
choice32 byte 3;

.code
mov edx, matrixPtr2 ;// have edx point to matrix
movzx ebx, matrixRow2 ;//move zero extend local varibale into ebx
mov whoWon3, 0 ;//clear the variable
INVOKE decideOrder
mov player3, ah ;//move ah into player3
mov playerTurn3, ah ;//move ah into playerTurn3
push edx ;//save edx
mov edx, offset option3prompt ;//move offset of message into edx
call writestring ;//display message
pop edx ;//restore edx
movzx eax, player3 ;//move zero extend varibel into eax
call writedec ;//display the number
push edx ;//save edx
mov edx, offset option3prompt2 ;//move offset of message into edx
call writestring ;//display the message
pop edx ;//restore edx
;///////////////////////////////loop for the game starts here
movzx ecx, maxMoves3 ;//move zero extent variable into ecx
call waitmsg ;//make the user see the message
Lpvp3:
call clrscr
INVOKE displayBoard, matrixPtr2, matrixRow2 
movzx ax, playerTurn3 ;//move zero extend varibael into ax
mov bl, 2 ;//move 2 into bl
div bl ;//divide
cmp ah, 0 ;//see if even or odd

ja player13 ;//iff odd then player1 turn
push ecx ;//save ecx
INVOKE fillMatrix, matrixPtr2, matrixRow2, playerTwo3, choice32
mov whoWon3, al ;//move al into varibale
pop ecx ;//restore ecx
push eax ;//save eax
mov eax, 2000 ;//move 2000 into eax
call Delay ;//delay the program
pop eax ;//restore eax
jmp endLpvp3

player13:
push ecx ;//save ecx
INVOKE fillMatrix, matrixPtr2, matrixRow2, playerOne3, choice2
mov whoWon3, al ;//move al into variable
pop ecx ;//restore ecx

endLpvp3:
cmp whoWon3, 0 ;//see if nayone won
ja endFunction13
inc playerTurn3;//incrmement - now its the next players turn
loop Lpvp3

call clrscr
INVOKE displayBoard, matrixPtr2, matrixRow2
push edx;//save edx
mov edx, offset option3prompt7 ;//move offset of message into edx
call writestring ;//disay message
pop edx ;//restore edx
call waitmsg
jmp endFunction23

endFunction13:

call clrscr
INVOKE displayBoard, matrixPtr2, matrixRow2 

cmp whoWon3, 1 ;//see if player1 won
ja next3
push edx ;//save edx
mov edx, offset option3prompt4 ;//move offset of message into edx
call writestring ;//display message
mov edx, offset option3prompt6 ;//move offset of message into edx
call writestring ;//display the message
call waitmsg
;///////add one to player one visctory count
push edx ;//save edx
mov edx, wins2 ;//have edx point to variable that holds how many games player 1 won
mov bl, 1 ;//move 1 into bl
add [edx], bl ;//add bl to variable pointed to by edx
pop edx ;//restore edx
jmp endFunction23

next3:
push edx ;//save edx
mov edx, offset option3prompt5 ;//move offset of message into edx
call writestring ;//display the message
mov edx, offset option3prompt6 ;//move offset of message into edx
call writestring ;//display message
pop edx ;//restore edx
call waitmsg 

endFunction23:
;//////add one to the number of games played
push edx ;//save edx
mov edx, numGames2 ;//have edx point to variable that indicates how many games were played
mov bl, 1 ;//move 1 into bl
add [edx], bl ;//add bl to varibale pinted to by edx
pop edx ;//restore edx

ret
playerVcomputer endp
;////////////////////////////////////////////////////////////////////////////////////////////////////////////////
computerVcomputer proc,
matrixPtr3: ptr byte,
matrixRow3: byte
;// Description:  
;// Requires:  
;// Returns:  

.data

player2 byte 0;
playerTurn2 byte 0;
playerOne2 byte 1;
playerTwo2 byte 2;
option2prompt byte 'Computer ', 0h ;//
option2prompt2 byte ' Goes first-[Computer 1 is blue|Computer 2 is yellow] ', 0Ah, 0Dh, 0h ;//
option22prompt3 byte 'Please select a column[1-4]: ', 0ah, 0dh, 0h
option22prompt4 byte 'Computer 1- ', 0h
option22prompt5 byte 'Computer 2- ', 0h
option2prompt6 byte 'HAS WON!', 0ah, 0dh, 0h
option2prompt7 byte 'There has been a DRAW!', 0ah, 0dh, 0h
whoWon2 byte 0;
maxMoves2 byte 16;
columnChoice2 byte 0;
choice3 byte 3

.code

mov edx, matrixPtr3 ;//have edx point to matrix
movzx ebx, matrixRow3 ;//move zero extend the rowsize into ebx
mov whoWon2, 0 ;//clear the variable
INVOKE decideOrder
mov player2, ah ;//move ah into player2
mov playerTurn2, ah ;//move ah into playerTurn2
push edx ;//save edx
mov edx, offset option2prompt ;//move offset of message into edx
call writestring ;//display the message
pop edx ;//restore edx
movzx eax, player2 ;//move zero extend player2 into eax
call writedec ;//display the number
push edx ;//save edx
mov edx, offset option2prompt2 ;//move the offset of the message into edx
call writestring ;//display the message
pop edx ;//restore edx
;////////////////////////////////loop for the game starts here
movzx ecx, maxMoves2 ;//movezero extend varibale into ecx
call waitmsg

Lpvp12:
call clrscr ;//clear the screen
INVOKE displayBoard, matrixPtr3, matrixRow3
push eax ;//save eax
mov eax, 2000 ;//move 2000 into eax
call Delay ;//delay the program for 2 seconds
pop eax ;//restore eax
movzx ax, playerTurn2 ;//move zero extend varibale into ax
mov bl, 2 ;//move 2 into bl
div bl ;//divide
cmp ah, 0 ;//see if even or odd

ja player12
push ecx ;//sae ecx
INVOKE fillMatrix, matrixPtr3, matrixRow3, playerTwo2, choice3
mov whoWon2, al ;//move al into whoWon2
pop ecx ;//restore ecx
jmp endLpvp12

player12:
push ecx ;//save ecx
INVOKE fillMatrix, matrixPtr3, matrixRow3, playerOne2, choice3
mov whoWon2, al ;//move al into varibale
pop ecx ;//restore ecx

endLpvp12:
cmp whoWon2, 0 ;//see if anyone won
ja endFunction12
inc playerTurn2; //increment variable
loop Lpvp12

call clrscr
INVOKE displayBoard, matrixPtr3, matrixRow3
push edx ;//save edx
mov edx, offset option2prompt7 ;//move offset of message into edx
call writestring ;//display the message
pop edx ;//restore edx
call waitmsg
jmp endFunction22


endFunction12:
call clrscr
INVOKE displayBoard, matrixPtr3, matrixRow3

cmp whoWon2, 1 ;//see if playerOne won
ja next12
push edx ;//save edx
mov edx, offset option22prompt4 ;//move offset of message into edx
call writestring ;//display message
mov edx, offset option2prompt6 ;//move offset of mesage into edx
call writestring ;//display message
call waitmsg
;///////add one to player one visctory count
jmp endFunction22

next12:
push edx
mov edx, offset option22prompt5
call writestring
mov edx, offset option2prompt6
call writestring
pop edx
call waitmsg 

endFunction22:
;//////add one to the number of games played

ret
computerVcomputer ENDP
;////////////////////////////////////////////////////////////////////////////////////////////////////////////////
displayBoard proc,
matrixPtr4: dword,
matrixRow4: byte
;// Description: Displays the game board
;// Requires:a pointer to the beginning of the matrix, a varibale containing the rowsize
;// Returns: Nothing, but displays teh board 

.data

saveColor byte 0;
display1 byte '------------------------------', 0ah, 0dh, 0h
display2 byte '      ', 0h

.code
call GetTextColor ;//svae the current console colors
mov saveColor, al 
push eax ;//save eax
movzx eax, matrixRow4
pop eax ;//restore eax
mov esi, matrixPtr4 ;//have esi pointot begining of matrix
push edx ;//save edx
mov edx, offset display1 ;//move offset of display1 into edx
call writestring ;//display
pop edx ;//restore edx
push ecx ;//save ecx
mov ecx, 4 ;//move 4 into ecx

displayL1:
push ecx ;//save ecx
mov ecx, 4 ;//move 4 into ecx
mov al, 7ch ;// move "|" into al;
call writechar ;//display it
	displayL2:
	;push ecx
	mov bl, [esi] ;//mmove element pointed to by esi into bl
	cmp bl, 0 ;//see if its zero
	jne nextDcheck1
	mov edx, offset display2 ;//move the offset of display2 into edx
	call writestring ;//display
	jmp endDisplay2
	nextDcheck1:
	cmp bl, 1 ;//compare bl to 1
	jne nextDcheck2
	mov eax, blue + (blue * 16) ;//move blue into eax
	call SetTextColor
	mov edx, offset display2 ;//move the offset of display2 into edx 
	call writestring ;//display the string with the color
	jmp endDisplay2
	nextDcheck2:
	mov eax, yellow + (yellow * 16 ) ;//move yellow into eax
	call SetTextColor
	mov edx, offset display2 ;//move the offset of display2 into edx
	call writestring ;//display the string witht color
	endDisplay2:
	movzx eax, saveColor ;//restore the ocnsole color
	call SetTextColor
	inc esi ;//point to next element
	mov al, 7ch ;// move "|" into eax
	call writechar
	loop displayL2
call crlf
pop ecx ;//restore ecx
mov edx, offset display1 ;//move the offset of display1 into edx
call writestring ;//display
loop DisplayL1
pop ecx ;//retore ecx

call crlf
call crlf 


ret
displayBoard endp
;//////////////////////////////////////////////////////////////////////////////////////////////////////////
;///////////////////////////////////////////////////////////////////////////////////////////////////////////
clearBoard proc,
matrixPtr5: ptr byte,
matrixRow5: byte
;// Description: this function clears th ematrix and restors it to zeros
;// Requires: [AS ARGUMENTS] pointer to the beginning of the matrix.
;// Returns: The cleared out matrix.


.data
matrixElements byte 16;

.code
movzx eax, matrixRow5
movzx ecx, matrixElements ;//////////////////////////////////CHANGED HERE
mov edx, matrixPtr5 ;//have edx point to beginning of matrix

LclearMatrix:
clearEAX ;//clear eax
mov [edx], al ;//move zero into matrix position
inc edx ;//point to next matrix positon
loop LclearMatrix

ret
clearBoard endp
;///////////////////////////////////////////////////////////////////////////////////////////////////////////
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////

END main

