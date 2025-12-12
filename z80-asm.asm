; =============================================================================
; Z80 MICROPROCESSOR PROGRAMMING - COMPREHENSIVE EXAMPLES
; Based on SPH 2411: Microprocessor-based Systems Lecture Notes
; =============================================================================
; This file demonstrates all major instruction categories:
; 1. Data Transfer Instructions
; 2. Arithmetic Instructions (ADD, ADC, SUB, SBC, INC, DEC)
; 3. Logic Instructions (AND, OR, XOR, CP, CPL)
; 4. Program Flow Control
; 5. I/O Operations
; =============================================================================

        ORG 8000h               ; Program origin at address 8000h

; =============================================================================
; SECTION 1: DATA TRANSFER INSTRUCTIONS
; Instructions that load/move data between registers and memory
; =============================================================================

DataTransferDemo:
        ; ===== IMMEDIATE ADDRESSING =====
        ; Load 8-bit immediate data into registers
        LD A, 23h               ; A ← 23h (Load immediate data to accumulator)
                                ; Opcode: 3E, Operand: 23
                                ; Two-byte instruction
        
        LD B, 67h               ; B ← 67h (Load immediate to register B)
                                ; Opcode: 06, Operand: 67
        
        LD C, 0E5h              ; C ← E5h (Load immediate to register C)
                                ; Note: 0E5h format to avoid confusion with identifier
        
        ; Load 16-bit immediate data into register pairs
        LD HL, 23E4h            ; HL ← 23E4h (Load 16-bit immediate)
                                ; Lower byte first: L ← E4h, H ← 23h
                                ; Opcode: 21, Operands: E4 23
                                ; Three-byte instruction
        
        LD BC, 1234h            ; BC ← 1234h (Load register pair)
        LD DE, 5678h            ; DE ← 5678h
        
        ; ===== REGISTER TO REGISTER =====
        ; Copy data between registers (source unchanged)
        LD A, B                 ; A ← B (Copy B to A, B remains unchanged)
                                ; Opcode: 78
                                ; One-byte instruction
                                ; Addressing mode: Register
        
        LD D, C                 ; D ← C (Copy C to D)
        LD E, A                 ; E ← A (Copy A to E)
        
        ; ===== DIRECT ADDRESSING (MEMORY) =====
        ; Store accumulator to specific memory address
        LD (0840h), A           ; (0840h) ← A (Store A at address 0840h)
                                ; Opcode: 32, Operands: 40 08
                                ; Three-byte instruction
                                ; Addressing mode: Direct
        
        ; Load accumulator from specific memory address
        LD A, (0807h)           ; A ← (0807h) (Load from address 0807h)
                                ; Opcode: 3A, Operands: 07 08
                                ; Three-byte instruction
                                ; Brackets denote "contents of memory location"
        
        ; ===== REGISTER INDIRECT ADDRESSING =====
        ; Use HL register pair as pointer to memory
        LD HL, 9000h            ; HL now points to address 9000h
        LD A, (HL)              ; A ← (HL) (Load byte from address in HL)
                                ; Opcode: 7E
                                ; One-byte instruction
        
        LD (HL), 42h            ; (HL) ← 42h (Store 42h at address in HL)
                                ; Opcode: 36, Operand: 42

; =============================================================================
; SECTION 2: ARITHMETIC INSTRUCTIONS - ADDITION
; Instructions that perform addition operations
; =============================================================================

ArithmeticAddDemo:
        ; ===== ADDITION WITHOUT CARRY (ADD) =====
        ; Example 1: Add immediate data to accumulator
        LD A, 67h               ; A ← 67h (Augend)
        ADD A, 0E5h             ; A ← A + E5h
                                ; Opcode: C6, Operand: E5
                                ; Two-byte instruction
                                ; Result: A = 4Ch, Carry flag SET
                                ; Binary: 01100111 + 11100101 = 01001100 (with carry)
        
        ; Example 2: Add register to accumulator
        LD A, 67h               ; A ← 67h (Reset for new example)
        LD B, 0E5h              ; B ← E5h (Addend in register)
        ADD A, B                ; A ← A + B
                                ; Opcode: 80
                                ; One-byte instruction
                                ; Addressing mode: Register
                                ; Result: A = 4Ch, Carry flag SET
        
        ; Example 3: Add from memory location
        LD HL, AddData1         ; Point HL to data in memory
        LD A, 67h               ; A ← 67h
        ADD A, (HL)             ; A ← A + (HL)
                                ; Opcode: 86
                                ; One-byte instruction
                                ; Addressing mode: Register indirect
        
        ; Example 4: 16-bit addition using HL
        LD HL, 1234h            ; HL ← 1234h
        LD DE, 5678h            ; DE ← 5678h
        ADD HL, DE              ; HL ← HL + DE = 68ACh
                                ; Special 16-bit addition instruction
        
        ; ===== ADDITION WITH CARRY (ADC) =====
        ; Used for multi-byte arithmetic and chained additions
        
        ; Example 5: Demonstrate difference between ADD and ADC
        ; First operation: 67h + E5h = 14Ch (sets carry flag)
        LD A, 67h               ; A ← 67h
        LD B, 0E5h              ; B ← E5h
        LD C, 23h               ; C ← 23h (for second addition)
        
        ADD A, B                ; A ← A + B = 4Ch, Carry = 1
        ADD A, C                ; A ← A + C = 4Ch + 23h = 6Fh
                                ; ADD ignores previous carry flag
        
        ; Now with ADC (Add with Carry)
        LD A, 67h               ; Reset: A ← 67h
        LD B, 0E5h              ; B ← E5h
        LD C, 23h               ; C ← 23h
        
        ADC A, B                ; A ← A + B = 4Ch, Carry = 1
        ADC A, C                ; A ← A + C + Carry = 4Ch + 23h + 1 = 70h
                                ; Opcode: 88
                                ; ADC includes the previous carry in addition
        
        ; Example 6: Multi-byte addition (16-bit addition manually)
        ; Add two 16-bit numbers stored in memory
        ; First number at 8100h-8101h: 34h 12h (1234h in little-endian)
        ; Second number at 8102h-8103h: 78h 56h (5678h in little-endian)
        
        LD HL, 8100h            ; Point to first number low byte
        LD A, (HL)              ; A ← 34h (low byte of first number)
        INC HL                  ; Move to 8101h
        LD B, (HL)              ; B ← 12h (high byte of first number)
        
        INC HL                  ; Move to 8102h
        LD C, (HL)              ; C ← 78h (low byte of second number)
        INC HL                  ; Move to 8103h
        LD D, (HL)              ; D ← 56h (high byte of second number)
        
        LD A, 34h               ; Low byte of first number
        ADD A, 78h              ; Add low bytes: 34h + 78h = ACh
        LD (8104h), A           ; Store result low byte
        
        LD A, 12h               ; High byte of first number
        ADC A, 56h              ; Add high bytes with carry: 12h + 56h + 0 = 68h
        LD (8105h), A           ; Store result high byte
                                ; Result: 68ACh stored at 8104h-8105h
        
        ; ===== INCREMENT (INC) =====
        ; Increase register or memory by 1
        LD A, 10h               ; A ← 10h
        INC A                   ; A ← A + 1 = 11h
                                ; Opcode: 3C
                                ; One-byte instruction
        
        LD B, 0FFh              ; B ← FFh
        INC B                   ; B ← 00h (wraps around)
        
        ; Increment memory location
        LD HL, 8200h            ; Point to memory
        LD (HL), 50h            ; Store 50h at that location
        INC (HL)                ; (HL) ← (HL) + 1 = 51h
                                ; Opcode: 34
        
        ; Increment 16-bit register pair
        LD HL, 0FFFFh           ; HL ← FFFFh
        INC HL                  ; HL ← 0000h (wraps around)

; =============================================================================
; SECTION 3: ARITHMETIC INSTRUCTIONS - SUBTRACTION
; Instructions that perform subtraction operations
; =============================================================================

ArithmeticSubDemo:
        ; ===== SUBTRACTION WITHOUT BORROW (SUB) =====
        ; Example 1: Subtract immediate data from accumulator
        LD A, 67h               ; A ← 67h (Minuend)
        SUB 0E5h                ; A ← A - E5h
                                ; Opcode: D6, Operand: E5
                                ; Two-byte instruction
                                ; Result: A = 82h, Carry flag SET (borrow occurred)
                                ; Binary: 01100111 - 11100101 = 10000010
        
        ; Example 2: Subtract register from accumulator
        LD A, 67h               ; A ← 67h (Reset for new example)
        LD B, 0E5h              ; B ← E5h (Subtrahend)
        SUB B                   ; A ← A - B
                                ; Opcode: 90
                                ; One-byte instruction
                                ; Result: A = 82h, Carry flag SET
        
        ; Example 3: Subtract from memory location
        LD HL, SubData1         ; Point HL to data
        LD A, 67h               ; A ← 67h
        SUB (HL)                ; A ← A - (HL)
                                ; Opcode: 96
                                ; One-byte instruction
        
        ; ===== SUBTRACTION WITH BORROW (SBC) =====
        ; Used for multi-byte arithmetic and chained subtractions
        
        ; Example 4: Demonstrate difference between SUB and SBC
        ; Chain: 67h - E5h - 23h
        LD A, 67h               ; A ← 67h
        LD B, 0E5h              ; B ← E5h
        LD C, 23h               ; C ← 23h
        
        SUB B                   ; A ← A - B = 82h, Carry = 1 (borrow)
        SUB C                   ; A ← A - C = 82h - 23h = 5Fh
                                ; SUB ignores the borrow flag
        
        ; Now with SBC (Subtract with Carry/Borrow)
        LD A, 67h               ; Reset: A ← 67h
        LD B, 0E5h              ; B ← E5h
        LD C, 23h               ; C ← 23h
        
        SBC A, B                ; A ← A - B = 82h, Carry = 1 (borrow)
                                ; Opcode: 98
        SBC A, C                ; A ← A - C - Carry = 82h - 23h - 1 = 5Eh
                                ; SBC includes the previous borrow in subtraction
        
        ; ===== DECREMENT (DEC) =====
        ; Decrease register or memory by 1
        LD A, 20h               ; A ← 20h
        DEC A                   ; A ← A - 1 = 1Fh
                                ; Opcode: 3D
                                ; One-byte instruction
        
        LD B, 00h               ; B ← 00h
        DEC B                   ; B ← FFh (wraps around)
        
        ; Decrement memory location
        LD HL, 8300h            ; Point to memory
        LD (HL), 50h            ; Store 50h
        DEC (HL)                ; (HL) ← (HL) - 1 = 4Fh
                                ; Opcode: 35
        
        ; Decrement 16-bit register pair
        LD HL, 0001h            ; HL ← 0001h
        DEC HL                  ; HL ← 0000h

; =============================================================================
; SECTION 4: LOGIC INSTRUCTIONS
; Instructions that perform logical operations
; =============================================================================

LogicDemo:
        ; ===== LOGICAL AND =====
        ; Bitwise AND operation with accumulator
        LD A, 0E5h              ; A ← 11100101 binary
        AND 67h                 ; A ← A AND 67h
                                ; Opcode: E6, Operand: 67
                                ; 11100101 AND 01100111 = 01100101 = 65h
                                ; Two-byte instruction
                                ; Addressing mode: Immediate
        
        ; AND with register
        LD A, 0E5h              ; A ← E5h (reset)
        LD B, 67h               ; B ← 67h
        AND B                   ; A ← A AND B = 65h
                                ; Opcode: A0
                                ; One-byte instruction
        
        ; ===== LOGICAL OR =====
        ; Bitwise OR operation with accumulator
        LD A, 0E5h              ; A ← 11100101 binary
        OR 67h                  ; A ← A OR 67h
                                ; Opcode: F6, Operand: 67
                                ; 11100101 OR 01100111 = 11100111 = E7h
                                ; Two-byte instruction
        
        ; ===== LOGICAL XOR (EXCLUSIVE OR) =====
        ; Bitwise XOR operation with accumulator
        LD A, 0E5h              ; A ← 11100101 binary
        XOR 67h                 ; A ← A XOR 67h
                                ; Opcode: EE, Operand: 67
                                ; 11100101 XOR 01100111 = 10000010 = 82h
                                ; Two-byte instruction
        
        ; XOR trick: Clear accumulator quickly
        XOR A                   ; A ← A XOR A = 0
                                ; Faster than LD A, 0
        
        ; ===== COMPLEMENT (CPL) =====
        ; Invert all bits in accumulator
        LD A, 55h               ; A ← 01010101 binary
        CPL                     ; A ← NOT A = 10101010 = AAh
                                ; Opcode: 2F
                                ; One-byte instruction
                                ; Addressing mode: Implied

; =============================================================================
; SECTION 5: COMPARE INSTRUCTION
; Compare data with accumulator (performs subtraction without storing result)
; =============================================================================

CompareDemo:
        ; ===== COMPARE (CP) =====
        ; Compare performs A - operand but doesn't store result
        ; Only flags are affected
        
        ; Example 1: Compare with immediate data
        LD A, 50h               ; A ← 50h
        CP 67h                  ; Compare A with 67h (A - 67h)
                                ; Opcode: FE, Operand: 67
                                ; Two-byte instruction
                                ; Result: A < 67h, so Carry flag SET
                                ; Zero flag CLEAR (not equal)
                                ; A remains 50h (unchanged)
        
        ; Example 2: Compare with register
        LD A, 50h               ; A ← 50h
        LD C, 50h               ; C ← 50h
        CP C                    ; Compare A with C
                                ; Opcode: B9
                                ; One-byte instruction
                                ; Result: A == C, so Zero flag SET
        
        ; Example 3: Compare with memory
        LD HL, CompData1        ; Point to data
        LD A, 100               ; A ← 100
        CP (HL)                 ; Compare A with (HL)
                                ; Opcode: BE
        
        ; ===== Using Compare for Decision Making =====
        ; Find maximum of two numbers
FindMax:
        LD A, 75h               ; First number
        LD B, 50h               ; Second number
        CP B                    ; Compare A with B
        JP NC, AIsMax           ; If No Carry (A >= B), jump
        LD A, B                 ; Otherwise, B is larger, copy it to A
AIsMax:
        ; A now contains the maximum value (75h)
        
        ; Check if value equals specific number
        LD A, 42h               ; A ← 42h
        CP 42h                  ; Compare with 42h
        JP Z, IsEqual           ; If Zero flag set, values are equal
        JP IsNotEqual           ; Otherwise, not equal
        
IsEqual:
        LD B, 0FFh              ; Set flag to indicate equality
        JP CompareDone
        
IsNotEqual:
        LD B, 00h               ; Clear flag
        
CompareDone:

; =============================================================================
; SECTION 6: PRACTICAL EXAMPLES FROM LECTURE NOTES
; =============================================================================

; Example 1: Add two numbers (from lecture flowchart example)
; Algorithm:
; 1. Move augend to accumulator
; 2. Move addend to register
; 3. Add the numbers
; 4. Result remains in accumulator

AddTwoNumbers:
        LD A, 08h               ; A ← 08h (augend)
        LD B, 05h               ; B ← 05h (addend)
        ADD A, B                ; A ← A + B = 0Dh
        HALT                    ; Stop execution
        
; Example 2: Add two numbers from memory (exercise from notes)
; Numbers 11H and 15H stored at 0030H and 0031H
; Sum stored at 0032H and copied to register C

AddFromMemory:
        LD HL, 0030h            ; Point to first number
        LD A, (HL)              ; A ← (0030h) = 11h (load first number)
        INC HL                  ; Point to next location
        LD B, (HL)              ; B ← (0031h) = 15h (load second number)
        ADD A, B                ; A ← A + B = 26h (add them)
        INC HL                  ; Point to result location
        LD (HL), A              ; (0032h) ← A (store result)
        LD C, A                 ; C ← A (copy to register C)
        HALT

; Example 3: Multi-byte addition demonstration
; Illustrates proper use of ADC for carrying between bytes

MultiByteAdd:
        ; Add two 3-byte numbers
        ; First:  56h 34h 12h (123456h)
        ; Second: DEh BCh 9Ah (9ABCDEh)
        
        LD A, 12h               ; Low byte of first number
        ADD A, 9Ah              ; Add low byte of second: 12h + 9Ah = ACh
        LD L, A                 ; Store in L
        
        LD A, 34h               ; Middle byte of first number
        ADC A, 0BCh             ; Add middle with carry: 34h + BCh + 0 = F0h
        LD H, A                 ; Store in H
        
        LD A, 56h               ; High byte of first number
        ADC A, 0DEh             ; Add high with carry: 56h + DEh + 0 = 35h, carry = 1
        LD B, A                 ; Store in B
        ; Result: Carry=1, B=35h, H=F0h, L=ACh
        ; Which is: 1_35F0AC (note the final carry)

; =============================================================================
; SECTION 7: DATA SECTION
; Memory data used in examples above
; =============================================================================

        ORG 8500h               ; Data section at different address

AddData1:
        DB 0E5h                 ; Data for addition example

SubData1:
        DB 0E5h                 ; Data for subtraction example

CompData1:
        DB 75h                  ; Data for compare example

TestArray:
        DB 10h, 20h, 30h, 40h, 50h  ; Test array

MemoryNumbers:
        ; Data for memory addition exercise
        ORG 0030h               ; Specific address from exercise
        DB 11h                  ; First number at 0030h
        DB 15h                  ; Second number at 0031h
        DB 00h                  ; Space for result at 0032h

; =============================================================================
; SECTION 8: I/O OPERATIONS WITH 8255 PPI
; Demonstrates Input/Output operations using the 8255 interface chip
; =============================================================================

        ORG 8600h               ; I/O section

; 8255 PPI Port Addresses (assuming base address with A1,A0)
PORT_A      EQU 00h             ; Port A address (A1=0, A0=0)
PORT_B      EQU 01h             ; Port B address (A1=0, A0=1)
PORT_C      EQU 02h             ; Port C address (A1=1, A0=0)
CTRL_WORD   EQU 03h             ; Control Word register (A1=1, A0=1)

IODemo:
        ; ===== CONFIGURE 8255 PPI =====
        ; Control Word format: D7=1 (mode set flag)
        ; D6,D5 = 00 (Port A mode 0)
        ; D4 = 1 (Port A input), 0 (Port A output)
        ; D3 = 0 (Port C upper output)
        ; D2 = 0 (Port B mode 0)
        ; D1 = 0 (Port B output)
        ; D0 = 0 (Port C lower output)
        
        ; Example 1: All ports output (Control Word = 80h)
        LD A, 80h               ; CW: 10000000 = All ports output
        OUT (CTRL_WORD), A      ; Send control word to 8255
                                ; Opcode: D3, Operand: 03
                                ; Two-byte instruction
        
        ; Example 2: Port A input, Ports B and C output (CW = 90h)
        LD A, 90h               ; CW: 10010000
                                ; D4=1 (Port A input)
                                ; D1=0 (Port B output)
                                ; D0=0 (Port C output)
        OUT (CTRL_WORD), A      ; Configure 8255
        
        ; ===== OUTPUT OPERATION =====
        ; Send data to Port A
        LD A, 55h               ; Data to send
        OUT (PORT_A), A         ; Output A to Port A
                                ; Opcode: D3, Operand: 00
                                ; Addressing mode: Direct
        
        ; ===== INPUT OPERATION =====
        ; Read data from Port A
        IN A, (PORT_A)          ; Input from Port A to accumulator
                                ; Opcode: DB, Operand: 00
                                ; Two-byte instruction
                                ; Addressing mode: Direct
        
        ; Process the input data
        ADD A, 10h              ; Add 10h to input
        OUT (PORT_B), A         ; Output result to Port B

; =============================================================================
; NOTES ON INSTRUCTION ENCODING
; =============================================================================
; 
; ONE-BYTE INSTRUCTIONS (opcode only):
; - LD A, B      (78h) - Register to register
; - ADD A, B     (80h) - Register arithmetic
; - SUB B        (90h) - Register subtraction
; - INC A        (3Ch) - Increment
; - DEC A        (3Dh) - Decrement
; - CPL          (2Fh) - Complement
; - HALT         (76h) - Stop execution
;
; TWO-BYTE INSTRUCTIONS (opcode + operand):
; - LD A, n      (3E nn) - Load immediate
; - ADD A, n     (C6 nn) - Add immediate
; - SUB n        (D6 nn) - Subtract immediate
; - AND n        (E6 nn) - AND immediate
; - OR n         (F6 nn) - OR immediate
; - XOR n        (EE nn) - XOR immediate
; - CP n         (FE nn) - Compare immediate
; - OUT (n), A   (D3 nn) - Output to port
; - IN A, (n)    (DB nn) - Input from port
;
; THREE-BYTE INSTRUCTIONS (opcode + address/16-bit data):
; - LD HL, nn    (21 nn nn) - Load 16-bit immediate
; - LD (nn), A   (32 nn nn) - Store accumulator
; - LD A, (nn)   (3A nn nn) - Load accumulator
;
; =============================================================================

        END                     ; End of program
