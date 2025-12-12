# undergrad-microprocessors-asm
# Z80 Assembly Language

A comprehensive introduction to Z80 assembly programming covering registers, basic operations, and fundamental concepts.

## Table of Contents

- [Z80 Registers](#-z80-registers)
- [Loading Data](#-loading-data-ld-instruction)
- [Adding Data](#-adding-data)
- [Copying Data](#-copying-data)
- [Comparing Data](#-comparing-data)
- [Basic Arithmetic](#-basic-arithmetic)
- [Program Structure](#-program-structure)
- [Quick Reference](#-quick-reference)

---

## Z80 Registers

The Z80 has several types of registers that store data and addresses:

### 8-Bit General Purpose Registers

| Register | Name | Purpose |
|----------|------|---------|
| **A** | Accumulator | Primary register for arithmetic and logic operations |
| **B** | General | Often used as a counter in loops |
| **C** | General | General purpose storage |
| **D** | General | General purpose storage |
| **E** | General | General purpose storage |
| **H** | High | High byte of HL pair, used for memory addressing |
| **L** | Low | Low byte of HL pair, used for memory addressing |

### 16-Bit Register Pairs

Registers can be combined to work with 16-bit values (useful for addresses):

| Pair | Usage |
|------|-------|
| **BC** | B and C combined - often used for counters and data |
| **DE** | D and E combined - often used for destination addresses |
| **HL** | H and L combined - primary memory pointer |

**Example:**
```assembly
LD HL, 8000h    ; HL now contains 16-bit address 8000h
                ; H = 80h, L = 00h
```

### Special Purpose Registers

| Register | Name | Purpose |
|----------|------|---------|
| **SP** | Stack Pointer | Points to top of stack in memory |
| **PC** | Program Counter | Points to next instruction to execute |
| **IX** | Index X | 16-bit index register for addressing with offsets |
| **IY** | Index Y | 16-bit index register for addressing with offsets |
| **F** | Flags | Status flags (Zero, Carry, Sign, Parity, etc.) |

### Shadow Registers

The Z80 has a duplicate set of registers (A', F', B', C', D', E', H', L') that you can quickly swap with the main set:

```assembly
EX AF, AF'      ; Exchange A and F with their shadows
EXX             ; Exchange BC, DE, HL with their shadows
```

---

## Loading Data (LD Instruction)

The `LD` (Load) instruction is the most common - it moves data around.

### Loading Immediate Values

Put a specific number directly into a register:

```assembly
LD A, 42        ; Load decimal 42 into A
LD B, 0FFh      ; Load hexadecimal FF into B
LD C, 10101010b ; Load binary into C
LD D, 'X'       ; Load ASCII code of 'X' into D
```

### Loading Between Registers

Copy data from one register to another:

```assembly
LD A, B         ; Copy B into A (B stays unchanged)
LD C, D         ; Copy D into C
LD E, A         ; Copy A into E
```

**Important:** You CANNOT directly load between all registers:
```assembly
LD B, C         ; ✓ Valid
LD H, L         ; ✓ Valid
LD B, H         ; ✓ Valid
; Most 8-bit registers can transfer to each other
```

### Loading 16-Bit Values

```assembly
LD BC, 1234h    ; Load 1234h into BC register pair
LD HL, 8000h    ; Load 8000h into HL
LD SP, 0FFFFh   ; Set stack pointer to FFFFh
```

### Loading from Memory

Use parentheses `()` to indicate "the value AT this address":

```assembly
LD A, (8000h)   ; Load the byte at memory address 8000h into A
LD A, (HL)      ; Load the byte at address in HL into A
LD B, (HL)      ; Load the byte at address in HL into B
```

**Example:**
```assembly
LD HL, 9000h    ; HL = address 9000h
LD A, (HL)      ; A = the byte stored at address 9000h
```

### Storing to Memory

```assembly
LD (8000h), A   ; Store A at memory address 8000h
LD (HL), A      ; Store A at address pointed to by HL
LD (HL), 42     ; Store immediate value 42 at address in HL
```

### Loading with Index Registers

```assembly
LD A, (IX+5)    ; Load from address (IX + 5 bytes) into A
LD (IY+10), B   ; Store B at address (IY + 10 bytes)
```

**Practical Example:**
```assembly
; Access an array element
LD IX, MyArray  ; Point to array base
LD A, (IX+0)    ; Get first element
LD B, (IX+1)    ; Get second element
LD C, (IX+2)    ; Get third element
```

---

## Adding Data

### Basic Addition (ADD)

```assembly
ADD A, B        ; A = A + B
ADD A, 5        ; A = A + 5
ADD A, (HL)     ; A = A + value at address in HL
```

**Example:**
```assembly
LD A, 10        ; A = 10
LD B, 25        ; B = 25
ADD A, B        ; A = 35 (10 + 25)
```

### Addition with Carry (ADC)

Includes the Carry flag in the addition (useful for multi-byte math):

```assembly
ADC A, B        ; A = A + B + Carry flag
ADC A, 5        ; A = A + 5 + Carry flag
```

**Example - Adding 16-bit numbers manually:**
```assembly
; Add two 16-bit numbers
; First number: BC = 1234h
; Second number: DE = 5678h
; Result will be in BC

LD A, C         ; Get low byte of BC
ADD A, E        ; Add low byte of DE
LD C, A         ; Store result low byte

LD A, B         ; Get high byte of BC
ADC A, D        ; Add high byte with carry
LD B, A         ; Store result high byte
; BC now contains 68ACh (1234h + 5678h)
```

### 16-Bit Addition

The HL register has special 16-bit add instructions:

```assembly
ADD HL, BC      ; HL = HL + BC (16-bit addition)
ADD HL, DE      ; HL = HL + DE
ADD HL, HL      ; HL = HL + HL (double HL, useful for multiplication by 2)
```

### Increment

Add 1 to a register:

```assembly
INC A           ; A = A + 1
INC B           ; B = B + 1
INC HL          ; HL = HL + 1 (16-bit increment)
INC (HL)        ; Increment the value at address in HL
```

---

## 📋 Copying Data

### Register to Register

```assembly
LD B, A         ; Copy A to B
LD C, B         ; Copy B to C
LD D, C         ; Copy C to D
```

### Memory Block Copies

The Z80 has special instructions for copying memory blocks:

#### LDIR - Load, Increment, Repeat

Copies a block of memory:

```assembly
; Copy 100 bytes from 8000h to 9000h
LD HL, 8000h    ; Source address
LD DE, 9000h    ; Destination address
LD BC, 100      ; Number of bytes to copy
LDIR            ; Copy! (repeats until BC = 0)
```

**What LDIR does each iteration:**
1. Copy byte from (HL) to (DE)
2. Increment HL
3. Increment DE
4. Decrement BC
5. Repeat until BC = 0

#### LDI - Load, Increment (single byte)

```assembly
LDI             ; Copy one byte from (HL) to (DE), increment both, decrement BC
```

#### LDDR - Load, Decrement, Repeat

Like LDIR but goes backwards (useful for overlapping moves):

```assembly
LD HL, 80FFh    ; Source end address
LD DE, 90FFh    ; Destination end address
LD BC, 100      ; Number of bytes
LDDR            ; Copy backwards
```

### Copying Strings Example

```assembly
; Copy a null-terminated string
LD HL, SourceString
LD DE, DestBuffer

CopyLoop:
    LD A, (HL)      ; Load character from source
    LD (DE), A      ; Store to destination
    CP 0            ; Check if null terminator
    RET Z           ; Return if we hit the null
    INC HL          ; Next source
    INC DE          ; Next destination
    JP CopyLoop     ; Continue

SourceString:
    DB "Hello!", 0
DestBuffer:
    DS 20           ; Reserve 20 bytes
```

---

## 🔍 Comparing Data

### CP - Compare

Compares A with another value by performing a subtraction without storing the result. Sets flags based on the comparison:

```assembly
CP B            ; Compare A with B
CP 10           ; Compare A with 10
CP (HL)         ; Compare A with value at address in HL
```

**Flags set by CP:**
- **Z (Zero)** - Set if values are equal
- **C (Carry)** - Set if A < compared value
- **S (Sign)** - Set if result would be negative

### Using Comparisons with Jumps

```assembly
LD A, 10
CP 5
JP Z, Equal     ; Jump if A == 5
JP C, Less      ; Jump if A < 5
JP NC, Greater  ; Jump if A >= 5
```

**Practical Example - Find Maximum:**
```assembly
; Find max of two numbers in A and B
CP B            ; Compare A with B
JP NC, AIsMax   ; If A >= B, A is max
LD A, B         ; Otherwise, copy B to A
AIsMax:
; A now contains the maximum value
```

### Comparing 16-Bit Values

The Z80 doesn't have direct 16-bit compare, so subtract:

```assembly
; Compare HL with BC
OR A            ; Clear carry flag
SBC HL, BC      ; HL = HL - BC (sets flags)
JP Z, Equal     ; If zero, they were equal
ADD HL, BC      ; Restore HL (since SBC modified it)
```

---

## Basic Arithmetic

### Subtraction

```assembly
SUB B           ; A = A - B
SUB 5           ; A = A - 5
SUB (HL)        ; A = A - value at address in HL
```

```assembly
SBC A, B        ; A = A - B - Carry flag
```

### Decrement

```assembly
DEC A           ; A = A - 1
DEC B           ; B = B - 1
DEC HL          ; HL = HL - 1 (16-bit)
DEC (HL)        ; Decrement value at address in HL
```

### Multiplication

The Z80 has NO built-in multiply instruction! You must use repeated addition:

```assembly
; Multiply A by B, result in A
; Save original A in C
LD C, A
LD A, 0         ; Clear result
MultLoop:
    ADD A, C    ; Add original value
    DJNZ MultLoop ; Decrement B and loop if not zero
; A now contains A * B
```

### Division

Also no divide instruction - use repeated subtraction:

```assembly
; Divide A by B, quotient in A, remainder in C
LD C, 0         ; Clear quotient
DivLoop:
    CP B        ; Compare A with B
    JP C, DivDone ; If A < B, we're done
    SUB B       ; A = A - B
    INC C       ; Increment quotient
    JP DivLoop
DivDone:
    ; C = quotient, A = remainder
    LD A, C     ; Move quotient to A if desired
```

---

## Program Structure

### Basic Template

```assembly
        ORG 8000h           ; Program starts at address 8000h

Start:
        ; Your code here
        LD A, 10
        LD B, 20
        ADD A, B
        
        HALT                ; Stop execution

        END Start           ; End of program, entry point
```

### Defining Data

```assembly
MyByte:     DB 42           ; Define single byte
MyWord:     DW 1234h        ; Define 16-bit word
MyString:   DB "Hello", 0   ; Define string with null terminator
MyArray:    DB 1,2,3,4,5    ; Define array
Buffer:     DS 50           ; Reserve 50 bytes (uninitialized)
```

### Using Labels

```assembly
        LD HL, MyData       ; Load address of MyData into HL
        LD A, (HL)          ; Load value at MyData into A
        JP Loop             ; Jump to Loop label

Loop:
        ; Loop code here
        JP Loop

MyData:
        DB 100
```

---

## Quick Reference

### Most Common Instructions

| Instruction | Example | Description |
|-------------|---------|-------------|
| **LD** | `LD A, 5` | Load data |
| **ADD** | `ADD A, B` | Add to A |
| **SUB** | `SUB B` | Subtract from A |
| **INC** | `INC A` | Increment by 1 |
| **DEC** | `DEC B` | Decrement by 1 |
| **CP** | `CP 10` | Compare with A |
| **JP** | `JP 8000h` | Jump to address |
| **JR** | `JR Loop` | Jump relative (short) |
| **CALL** | `CALL Sub` | Call subroutine |
| **RET** | `RET` | Return from subroutine |
| **PUSH** | `PUSH BC` | Push to stack |
| **POP** | `POP BC` | Pop from stack |
| **HALT** | `HALT` | Stop processor |

### Number Formats

```assembly
LD A, 42        ; Decimal
LD A, 2Ah       ; Hexadecimal (0-9, A-F)
LD A, 0010101b  ; Binary
LD A, 'A'       ; ASCII character
```

### Condition Codes (for JP, JR, CALL, RET)

| Code | Meaning | When Used |
|------|---------|-----------|
| **Z** | Zero | Result was zero / values equal |
| **NZ** | Not Zero | Result was not zero / values not equal |
| **C** | Carry | Carry occurred / unsigned less than |
| **NC** | No Carry | No carry / unsigned greater or equal |
| **M** | Minus | Result is negative (bit 7 = 1) |
| **P** | Plus | Result is positive (bit 7 = 0) |
| **PE** | Parity Even | Even number of 1 bits |
| **PO** | Parity Odd | Odd number of 1 bits |

### Memory Addressing Summary

```assembly
LD A, 5         ; Immediate: A = 5
LD A, B         ; Register: A = B
LD A, (8000h)   ; Direct: A = byte at address 8000h
LD A, (HL)      ; Indirect: A = byte at address in HL
LD A, (IX+3)    ; Indexed: A = byte at address (IX + 3)
```


# Intel 8085 Assembly Programming Guide

## Overview

The Intel 8085 is an 8-bit microprocessor introduced in 1976. It has a 16-bit address bus (can address 64KB of memory) and an 8-bit data bus. This guide covers the fundamental assembly language instructions you need to start programming the 8085.

## Register Architecture

The 8085 has several registers available for programming:

### General Purpose Registers (8-bit)
- **A (Accumulator)**: Primary register for arithmetic and logical operations
- **B, C, D, E, H, L**: Can be used individually or in pairs (BC, DE, HL)

### Special Purpose Registers
- **SP (Stack Pointer)**: 16-bit register pointing to the top of the stack
- **PC (Program Counter)**: 16-bit register containing the address of the next instruction
- **Flags**: 5 flags indicating the status of operations
  - **S (Sign)**: Set if result is negative (bit 7 = 1)
  - **Z (Zero)**: Set if result is zero
  - **AC (Auxiliary Carry)**: Used for BCD operations
  - **P (Parity)**: Set if result has even parity
  - **CY (Carry)**: Set if there's a carry/borrow

## Basic Instruction Categories

### 1. Data Transfer Instructions

These instructions move data between registers, memory, and I/O ports.

#### MOV (Move/Copy)
Copies data from source to destination.

**Syntax**: `MOV destination, source`

**Examples**:
```asm
MOV A, B        ; Copy contents of B to A
MOV C, A        ; Copy contents of A to C
MOV M, A        ; Copy A to memory location pointed by HL
MOV A, M        ; Copy from memory (HL) to A
```

**Key Points**:
- Both registers remain unchanged except the destination
- `M` represents memory location pointed to by HL register pair
- Cannot do `MOV M, M` (illegal instruction)

#### MVI (Move Immediate)
Loads an 8-bit value directly into a register or memory.

**Syntax**: `MVI destination, 8-bit-data`

**Examples**:
```asm
MVI A, 25H      ; Load hexadecimal 25 into A
MVI B, 10       ; Load decimal 10 into B
MVI M, FFH      ; Load FFH into memory location (HL)
```

**Key Points**:
- Data is specified directly in the instruction
- Requires 2 bytes (opcode + data)

#### LDA (Load Accumulator Direct)
Loads accumulator from a specific memory address.

**Syntax**: `LDA 16-bit-address`

**Example**:
```asm
LDA 2050H       ; Load A from memory address 2050H
```

#### STA (Store Accumulator Direct)
Stores accumulator contents to a specific memory address.

**Syntax**: `STA 16-bit-address`

**Example**:
```asm
STA 3000H       ; Store A to memory address 3000H
```

#### LDAX (Load Accumulator Indirect)
Loads accumulator from memory address in BC or DE pair.

**Examples**:
```asm
LDAX B          ; Load A from address in BC
LDAX D          ; Load A from address in DE
```

#### STAX (Store Accumulator Indirect)
Stores accumulator to memory address in BC or DE pair.

**Examples**:
```asm
STAX B          ; Store A to address in BC
STAX D          ; Store A to address in DE
```

#### LXI (Load Register Pair Immediate)
Loads 16-bit data into a register pair.

**Syntax**: `LXI pair, 16-bit-data`

**Examples**:
```asm
LXI H, 2050H    ; HL = 2050H
LXI B, 1234H    ; BC = 1234H
LXI SP, 3FFFH   ; SP = 3FFFH (initialize stack)
```

### 2. Arithmetic Instructions

#### ADD (Add to Accumulator)
Adds register or memory contents to accumulator.

**Syntax**: `ADD source`

**Examples**:
```asm
ADD B           ; A = A + B
ADD M           ; A = A + (HL)
```

**Flags Affected**: All (S, Z, AC, P, CY)

#### ADI (Add Immediate)
Adds 8-bit data to accumulator.

**Syntax**: `ADI 8-bit-data`

**Example**:
```asm
ADI 05H         ; A = A + 05H
```

#### ADC (Add with Carry)
Adds register/memory and carry flag to accumulator.

**Syntax**: `ADC source`

**Example**:
```asm
ADC B           ; A = A + B + CY
```

**Use Case**: Multi-byte addition

#### SUB (Subtract from Accumulator)
Subtracts register or memory from accumulator.

**Syntax**: `SUB source`

**Examples**:
```asm
SUB C           ; A = A - C
SUB M           ; A = A - (HL)
```

#### SUI (Subtract Immediate)
Subtracts 8-bit data from accumulator.

**Example**:
```asm
SUI 10H         ; A = A - 10H
```

#### INR (Increment)
Increments register or memory by 1.

**Syntax**: `INR destination`

**Examples**:
```asm
INR A           ; A = A + 1
INR B           ; B = B + 1
INR M           ; (HL) = (HL) + 1
```

**Key Points**:
- Does NOT affect Carry flag
- Affects S, Z, AC, P flags

#### DCR (Decrement)
Decrements register or memory by 1.

**Syntax**: `DCR destination`

**Examples**:
```asm
DCR C           ; C = C - 1
DCR M           ; (HL) = (HL) - 1
```

#### INX (Increment Register Pair)
Increments 16-bit register pair by 1.

**Examples**:
```asm
INX H           ; HL = HL + 1
INX B           ; BC = BC + 1
```

**Key Point**: No flags affected

#### DCX (Decrement Register Pair)
Decrements 16-bit register pair by 1.

**Examples**:
```asm
DCX H           ; HL = HL - 1
DCX SP          ; SP = SP - 1
```

### 3. Logical Instructions

#### ANA (AND with Accumulator)
Performs bitwise AND with accumulator.

**Syntax**: `ANA source`

**Example**:
```asm
ANA B           ; A = A AND B
```

**Flags**: CY is reset, others affected

#### ANI (AND Immediate)
ANDs 8-bit data with accumulator.

**Example**:
```asm
ANI 0FH         ; A = A AND 0FH (masks upper nibble)
```

#### ORA (OR with Accumulator)
Performs bitwise OR with accumulator.

**Example**:
```asm
ORA C           ; A = A OR C
```

#### ORI (OR Immediate)
ORs 8-bit data with accumulator.

**Example**:
```asm
ORI 80H         ; A = A OR 80H (sets bit 7)
```

#### XRA (XOR with Accumulator)
Performs bitwise XOR with accumulator.

**Example**:
```asm
XRA A           ; A = A XOR A = 00H (clear A)
```

**Common Trick**: `XRA A` is the fastest way to clear accumulator

#### CMP (Compare with Accumulator)
Compares register/memory with accumulator by subtracting (A - source).

**Syntax**: `CMP source`

**Examples**:
```asm
CMP B           ; Compare A with B
CMP M           ; Compare A with (HL)
```

**Result**:
- If A = source: Z flag = 1
- If A < source: CY flag = 1
- If A > source: CY flag = 0, Z flag = 0

**Key Point**: Accumulator is NOT modified, only flags change

#### CPI (Compare Immediate)
Compares 8-bit data with accumulator.

**Example**:
```asm
CPI 50H         ; Compare A with 50H
```

### 4. Branch Instructions

#### JMP (Unconditional Jump)
Jumps to specified address.

**Syntax**: `JMP 16-bit-address`

**Example**:
```asm
JMP 2000H       ; Jump to address 2000H
```

#### Conditional Jumps

**JZ** (Jump if Zero): Jump if Z = 1
```asm
JZ LABEL        ; Jump if result was zero
```

**JNZ** (Jump if Not Zero): Jump if Z = 0
```asm
JNZ LABEL       ; Jump if result was not zero
```

**JC** (Jump if Carry): Jump if CY = 1
```asm
JC LABEL        ; Jump if carry occurred
```

**JNC** (Jump if No Carry): Jump if CY = 0
```asm
JNC LABEL       ; Jump if no carry
```

**JP** (Jump if Positive): Jump if S = 0
```asm
JP LABEL        ; Jump if result positive
```

**JM** (Jump if Minus): Jump if S = 1
```asm
JM LABEL        ; Jump if result negative
```

### 5. Stack Operations

The stack grows downward in memory (SP decrements when pushing).

#### PUSH
Pushes register pair onto stack.

**Syntax**: `PUSH pair`

**Example**:
```asm
PUSH B          ; Push BC onto stack
                ; (SP-1) = B, (SP-2) = C, SP = SP - 2
```

#### POP
Pops from stack into register pair.

**Example**:
```asm
POP D           ; Pop into DE
                ; E = (SP), D = (SP+1), SP = SP + 2
```

### 6. Subroutine Instructions

#### CALL
Calls a subroutine at specified address.

**Syntax**: `CALL 16-bit-address`

**Example**:
```asm
CALL DELAY      ; Call subroutine at DELAY
```

**What Happens**:
1. Push current PC onto stack
2. Load new address into PC

#### RET (Return from Subroutine)
Returns from subroutine.

**Example**:
```asm
RET             ; Pop address from stack into PC
```

### 7. Special Instructions

#### HLT (Halt)
Stops processor execution.

**Example**:
```asm
HLT             ; Stop execution
```

#### NOP (No Operation)
Does nothing, used for timing delays.

**Example**:
```asm
NOP             ; Waste one instruction cycle
```

## Number Systems

The 8085 uses different number representations:

- **Hexadecimal**: Suffix with `H` (e.g., `2AH`, `FFH`)
- **Decimal**: No suffix (e.g., `42`, `255`)
- **Binary**: Suffix with `B` (e.g., `10101010B`)

## Memory Addressing Modes

1. **Direct**: Address specified in instruction (`LDA 2050H`)
2. **Indirect**: Address in register pair (`MOV A, M`)
3. **Immediate**: Data in instruction (`MVI A, 25H`)
4. **Register**: Register to register (`MOV A, B`)

## Common Programming Patterns

### Adding Two Numbers
```asm
MVI A, 15H      ; Load first number
MVI B, 20H      ; Load second number
ADD B           ; A = A + B = 35H
```

### Finding Sum of Array
```asm
LXI H, 2050H    ; Point to array start
MVI C, 05H      ; Counter = 5 elements
XRA A           ; Clear accumulator (sum = 0)
LOOP: ADD M     ; Add array element to sum
INX H           ; Point to next element
DCR C           ; Decrement counter
JNZ LOOP        ; Repeat if counter != 0
```

### Comparing Two Numbers
```asm
LDA 2050H       ; Load first number
MOV B, A        ; Save it
LDA 2051H       ; Load second number
CMP B           ; Compare with first
JZ EQUAL        ; Jump if equal
JC LESS         ; Jump if A < B
; Otherwise A > B
```

## Tips for Beginners

1. **Always initialize registers** before using them
2. **Use meaningful labels** for addresses and loops
3. **Initialize stack pointer** at the beginning of your program
4. **Remember the HL pair** is your main pointer to memory
5. **XRA A** is faster than `MVI A, 00H` to clear accumulator
6. **INR/DCR don't affect carry flag** - use carefully in loops
7. **Compare operations modify flags, not accumulator**

## Example: Complete Program Structure

```asm
        ORG 2000H       ; Program starts at 2000H
        LXI SP, 3FFFH   ; Initialize stack pointer
        
        ; Your code here
        MVI A, 10H
        MVI B, 20H
        ADD B
        STA 3000H       ; Store result
        
        HLT             ; Stop execution
        END             ; End of program
```
