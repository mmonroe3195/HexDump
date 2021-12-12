TITLE PROCS
; procs.asm
; Madison Monroe
; Sunday, Feburary 16th

INCLUDE CS240.INC

.8086

.data
decimal	BYTE	'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
arr 	BYTE	0h, 12h, 3h, 4h, 56h,78h, 99h, 0ABh, 0CDh, 0EFh, 0FFh

oldAX	WORD	?
oldBX	WORD	?
oldCX	WORD	?
oldDX	WORD	?
oldSI	WORD	?
oldDI	WORD	?
oldBP	WORD	?
oldSP	WORD	?
oldCS	WORD	?
oldDS	WORD	?
oldES	WORD	?
oldSS	WORD	?
newsi	WORD  ?
currentSP	WORD ?

oldcarry	BYTE	0
oldadjust	BYTE	0
oldsign		BYTE	0
oldzero		BYTE	0
oldoverflow	BYTE	0
oldparity	BYTE	0
olddirect	BYTE	0
oldinterrupt	BYTE	0
oldtrap		BYTE	0

w0	BYTE	"Register AX's", 0
w1	BYTE	"Register BX's", 0
w2	BYTE	"Register CX's", 0
w3	BYTE	"Register DX's", 0
w4	BYTE	"Register SI's", 0
w5	BYTE	"Register DI's", 0
w6	BYTE	"Register BP's",0
w7	BYTE	"Register SP's", 0
w8	BYTE	"Register CS's", 0
w9	BYTE	"Register DS's", 0
w10	BYTE	"Register ES's", 0
w11	BYTE	"Register SS's", 0
w12	BYTE	"Carry Flag", 0
w13	BYTE	"Adjust Flag", 0
w14	BYTE	"Sign Flag", 0
w15	BYTE	"Zero Flag", 0
w16	BYTE	"Overflow Flag", 0
w17	BYTE	"Parity Flag", 0
w18	BYTE	"Direction Flag", 0
w19	BYTE	"Interrupt Flag", 0
w20	BYTE	"Trap Flag", 0
setval	BYTE	"set", 0
clearval	BYTE	"clear", 0
variables 	WORD	OFFSET w0, OFFSET w1, OFFSET w2, OFFSET w3, OFFSET w4, OFFSET w5, OFFSET w6, OFFSET w7, OFFSET w8, OFFSET w9, OFFSET w10, OFFSET w11
newval		WORD	12 DUP(?)
oldval		WORD	12 DUP(?)
listsize 	WORD 	($ - oldval)
outputp1	BYTE	" value has been changed. Old value: ", 0
outputp2	BYTE	", new value: ",0
oldflags	WORD	?
.code

printarr PROC
push cx
push dx
pushf
push bx
mov cx, 12
top:
	mov dx, [bx]
	add bx, 2
	call	WriteHexWord
	mov		dl, ' '
	call	WriteChar
	loop top

pop bx
popf
pop dx
pop cx
ret
printarr ENDP

main PROC
mov	ax, @data
mov	ds, ax

std
call  dumpregs
call	savemachinestate

;sets the trap flag
PUSHF
MOV BP,SP
OR WORD PTR[BP+0],0100H
POPF

clc
mov	ax, 55000
add	ax, 33300
mov	bx, 1h
mov	cx, 2h
mov	dx, 3h
mov	si, 4h
add	bx, 55h
mov	ax, 12h
add	ax, 0FFh

cld
cli
call	DumpRegs
call	CompareMachineState
;!
mov	ax, 4C00h
int	21h

main ENDP

SaveMachineState PROC
mov	currentSP, sp
push ax
pushf
push bx
push si
pushf

mov	oldSI, si
mov	si, OFFSET oldval
mov	[si], ax
add	si, 2
mov	[si], bx
add	si, 2
mov	[si], cx
add	si, 2
mov	[si], dx
add	si, 2
mov	bx, oldsi
mov	[si], bx
add	si, 2
mov	[si], di
add	si, 2
mov	[si], bp
add	si, 2
add	currentSP, 2
mov	ax, currentSP
mov	[si], ax
add	si, 2
mov	[si], cs
add	si, 2
mov	[si], ds
add	si, 2
mov	[si], es
add	si, 2
mov	[si], ss
pop ax
add	si, 2
mov	oldflags, ax
shr	ax, 1
adc	oldcarry, 0
shr	ax, 1
shr	ax, 1
adc	oldparity, 0
shr	ax, 1
shr	ax, 1
adc	oldadjust, 0
shr  ax, 1
shr  ax, 1
adc  oldzero, 0
shr	ax, 1
adc	oldsign, 0
shr	ax, 1
adc	oldtrap, 0
shr	ax, 1
adc	oldinterrupt, 0
shr	ax, 1
adc	olddirect, 0
shr	ax, 1
adc	oldoverflow, 0
pop si
pop bx
popf
pop ax
ret
SaveMachineState ENDP

CompareMachineState PROC
mov	currentSP, sp
pushf
push	ax
push	bx
push	cx
push	dx
push  si
pushf
mov	newsi, si
mov	si, OFFSET newval
mov	[si], ax
add	si, 2
mov	[si], bx
add	si, 2
mov	[si], cx
add	si, 2
mov	[si], dx
add	si, 2
mov	bx, newsi
mov	[si], bx
add	si, 2
mov	[si], di
add	si, 2
mov	[si], bp
add	si, 2
add	currentSP, 2
mov	ax, currentSP
mov	[si], ax
add	si, 2
mov	[si], cs
add	si, 2
mov	[si], ds
add	si, 2
mov	[si], es
add	si, 2
mov	[si], ss
mov	si, 0
top:
	mov	bx, newval[si]
	cmp bx, oldval[si]
	je next1
	mov	dx, variables[si]
	call	WriteString
	mov	dx, OFFSET outputp1
	call	WriteString
	mov	dx, oldval[si]
	call	WriteHexWord
	mov	dx, OFFSET outputp2
	call	WriteString
	mov	dx, newval[si]
	call	WriteHexWord
	mov	dx, '.'
	call	WriteChar
	call	NewLine

next1:
	add si, 2
	cmp	listsize, si
	ja	top
pop ax ; pops flags into ax
cmp	ax, oldflags
je	endit

shr	ax, 1
mov	dl, 0
adc	dl, 0

cmp	dl, oldcarry
je	goparity

cmp dl, 0
je zerocarry

mov	bx, OFFSET setval
mov	cx, OFFSET clearval
jmp printit

zerocarry:
mov	bx, OFFSET clearval
mov cx, OFFSET setval

printit:
mov	dx, OFFSET w12
call	printflags

goparity:
shr	ax, 1
shr	ax, 1
mov	dl, 0
adc	dl, 0

cmp	dl, oldparity
je	goadjust

cmp dl, 0
je zeroparity

mov	bx, OFFSET setval
mov	cx, OFFSET clearval
jmp printit1

zeroparity:
mov	bx, OFFSET clearval
mov cx, OFFSET setval

printit1:
mov	dx, OFFSET w17
call	printflags

goadjust:
shr	ax, 1
shr	ax, 1
mov	dl, 0
adc	dl, 0

cmp	dl, oldadjust
je	gozero

cmp dl, 0
je zeroadjust

mov	bx, OFFSET setval
mov	cx, OFFSET clearval
jmp printit2

zeroadjust:
mov	bx, OFFSET clearval
mov cx, OFFSET setval

printit2:
mov	dx, OFFSET w13
call	printflags

gozero:
shr	 ax, 1
shr  ax, 1
mov	dl, 0
adc	dl, 0

cmp	dl, oldzero
je	gosign

cmp dl, 0
je zerozero

mov	bx, OFFSET setval
mov	cx, OFFSET clearval
jmp printit3

zerozero:
mov	bx, OFFSET clearval
mov cx, OFFSET setval

printit3:
mov	dx, OFFSET w15
call	printflags

gosign:
shr	ax, 1
mov	dl, 0
adc	dl, 0

cmp	dl, oldsign
je	gotrap

cmp dl, 0
je zerosign

mov	bx, OFFSET setval
mov	cx, OFFSET clearval
jmp printit4

zerosign:
mov	bx, OFFSET clearval
mov cx, OFFSET setval

printit4:
mov	dx, OFFSET w14
call	printflags

gotrap:
shr	ax, 1
mov	dl, 0
adc	dl, 0

cmp	dl, oldtrap
je	gointerrupt

cmp dl, 0
je zerotrap

mov	bx, OFFSET setval
mov	cx, OFFSET clearval
jmp printit5

zerotrap:
mov	bx, OFFSET clearval
mov cx, OFFSET setval

printit5:
mov	dx, OFFSET w20
call	printflags

gointerrupt:
shr	ax, 1
mov	dl, 0
adc	dl, 0

cmp	dl, oldinterrupt
je	godirect

cmp dl, 0
je zerointerrupt

mov	bx, OFFSET setval
mov	cx, OFFSET clearval
jmp printit6

zerointerrupt:
mov	bx, OFFSET clearval
mov cx, OFFSET setval

printit6:
mov	dx, OFFSET w19
call	printflags

godirect:
shr	ax, 1
mov	dl, 0
adc	dl, 0

cmp	dl, olddirect
je	gooverflow

cmp dl, 0
je zerodirect

mov	bx, OFFSET setval
mov	cx, OFFSET clearval
jmp printit7

zerodirect:
mov	bx, OFFSET clearval
mov cx, OFFSET setval

printit7:
mov	dx, OFFSET w18
call	printflags

gooverflow:
shr	ax, 1
mov	dl, 0
adc	dl, 0

cmp	dl, oldoverflow
je	endit

cmp dl, 0
je zerooverflow

mov	bx, OFFSET setval
mov	cx, OFFSET clearval
jmp printit8

zerooverflow:
mov	bx, OFFSET clearval
mov cx, OFFSET setval

printit8:
mov	dx, OFFSET w16
call	printflags

endit:
pop si
pop dx
pop cx
pop bx
pop ax
popf
ret
CompareMachineState ENDP

printflags PROC
push dx
push cx
pushf
call	WriteString
mov	dx, OFFSET outputp1
call	WriteString
mov	dx, cx
call	WriteString
mov	dx, OFFSET outputp2
call	WriteString
mov	dx, bx
call	WriteString
mov	dx, '.'
call	WriteChar
call	NewLine

popf
pop cx
pop dx
ret
printflags ENDP


HexOut PROC
push ax
push bx
push cx
push dx
pushf
jmp	comparison

top:
  mov	al, [bx]
	push  	cx
	mov	cl, 4
	shr	al, cl
	xchg	dl, al
	pop	cx
	call	WriteHexDigit


	mov	dl, [bx]
	call	WriteHexDigit
	cmp	cx, 0
	je	endit

	mov	dl, ' '
	call	WriteChar
	inc	bx
	dec 	cx

comparison:
	cmp 	cx, 0
	ja	top

endit:
popf
pop dx
pop cx
pop bx
pop ax
ret
HexOut ENDP

PrintInt PROC
push	ax
push	bx
push	cx
push	dx
pushf

cmp	ax, 0
jne 	continue

mov	dl, '0'
call	WriteChar
jmp	endproc

continue:
mov	dx, ax
mov	cl, 4
shr	dh, cl
cmp	dh, 8
jb	printdig

twocomp:
not	ax
add	ax, 0001h
mov	dl, '-'
call	WriteChar

printdig:
push ax
call	printdigit
pop ax
;call	WriteInt

endproc:
popf
pop	dx
pop	cx
pop  bx
pop	ax
ret
PrintInt ENDP

printdigit PROC
push	bx
push	cx
push	dx
push	si
pushf

cmp	ax, 0
je	endit

cmp	ax, 9
ja	cont

mov	dx, ax
jmp	printer

cont:
mov	bx, 10
mov dx, 0
div	bx   ;remainder stored in dx
call	printdigit
printer:
mov	si, OFFSET decimal
add	si, dx
mov	dl, [si]
call	WriteChar
endit:
popf
pop	si
pop	dx
pop	cx
pop bx
ret
printdigit ENDP

END
