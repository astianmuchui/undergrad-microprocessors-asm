; ============================================================================
; INTEL 8085 ASSEMBLY LANGUAGE - COMPREHENSIVE EXAMPLES
; ============================================================================
; This file demonstrates fundamental 8085 assembly operations with extensive
; comments explaining each instruction and programming concept.
; ============================================================================

; ----------------------------------------------------------------------------
; PROGRAM 1: BASIC DATA TRANSFER OPERATIONS
; ----------------------------------------------------------------------------
; Purpose: Demonstrate MOV, MVI, LDA, STA instructions
; Starting Address: 2000H
; ----------------------------------------------------------------------------

        ORG 2000H               ; Origin - program starts at memory address 2000H

; --- Initialize Stack Pointer ---
; The stack is used for PUSH/POP and CALL/RET operations
; We initialize it to the top of available RAM (grows downward)
        LXI SP, 3FFFH           ; Load Stack Pointer with 3FFFH
                                ; SP now points to address 3FFFH

; --- Example 1: Moving Immediate Data ---
; MVI loads a constant value directly into a register
        MVI A, 25H              ; Move Immediate: Load 25H (37 decimal) into Accumulator
                                ; A = 25H
        
        MVI B, 10H              ; Load 10H (16 decimal) into register B
                                ; B = 10H
        
        MVI C, FFH              ; Load FFH (255 decimal) into register C
                                ; C = FFH

; --- Example 2: Register to Register Transfer ---
; MOV copies data from one register to another
        MOV D, A                ; Copy contents of A to D
                                ; D = 25H (same as A)
                                ; Note: A still contains 25H (source unchanged)
        
        MOV E, B                ; Copy B to E
                                ; E = 10H
        
        MOV A, C                ; Copy C to A
                                ; A = FFH (overwrites previous value)

; --- Example 3: Memory Operations using HL Pair ---
; HL register pair acts as a memory pointer (H = high byte, L = low byte)
        LXI H, 2050H            ; Load HL pair with address 2050H
                                ; H = 20H, L = 50H
                                ; HL now points to memory location 2050H
        
        MVI M, 3AH              ; Move Immediate to Memory
                                ; Store 3AH at memory location pointed by HL (2050H)
                                ; Memory[2050H] = 3AH
        
        MOV A, M                ; Move from Memory to Accumulator
                                ; Load A with contents of memory at address HL
                                ; A = 3AH (reads from Memory[2050H])
        
        INX H                   ; Increment HL pair by 1
                                ; HL = 2051H (now points to next memory location)
        
        MOV M, A                ; Copy A to memory location 2051H
                                ; Memory[2051H] = 3AH

; --- Example 4: Direct Memory Addressing ---
; LDA and STA use 16-bit addresses directly in the instruction
        LDA 2050H               ; Load Accumulator Direct
                                ; A = Memory[2050H] = 3AH
        
        STA 3000H               ; Store Accumulator Direct
                                ; Memory[3000H] = 3AH (contents of A)

; --- Example 5: Indirect Addressing with BC and DE ---
; LDAX and STAX use BC or DE pairs as address pointers
        LXI B, 2051H            ; Load BC with address 2051H
                                ; BC = 2051H
        
        LDAX B                  ; Load Accumulator Indirect using BC
                                ; A = Memory[2051H] = 3AH
        
        LXI D, 3001H            ; Load DE with address 3001H
                                ; DE = 3001H
        
        STAX D                  ; Store Accumulator Indirect using DE
                                ; Memory[3001H] = 3AH (contents of A)

        HLT                     ; Halt - stop program execution


; ----------------------------------------------------------------------------
; PROGRAM 2: ARITHMETIC OPERATIONS
; ----------------------------------------------------------------------------
; Purpose: Demonstrate ADD, SUB, INR, DCR, multi-byte addition
; Starting Address: 2100H
; ----------------------------------------------------------------------------

        ORG 2100H               ; Start new program at 2100H

; --- Example 1: Simple Addition ---
        MVI A, 15H              ; A = 15H (21 decimal)
        MVI B, 2AH              ; B = 2AH (42 decimal)
        ADD B                   ; Add B to A
                                ; A = A + B = 15H + 2AH = 3FH (63 decimal)
                                ; Flags affected: S, Z, AC, P, CY
        
        STA 3010H               ; Store result at 3010H
                                ; Memory[3010H] = 3FH

; --- Example 2: Addition with Immediate Data ---
        MVI A, 50H              ; A = 50H (80 decimal)
        ADI 30H                 ; Add Immediate: A = A + 30H
                                ; A = 50H + 30H = 80H (128 decimal)
                                ; No carry generated

; --- Example 3: Addition Causing Carry ---
        MVI A, F0H              ; A = F0H (240 decimal)
        MVI B, 20H              ; B = 20H (32 decimal)
        ADD B                   ; A = F0H + 20H = 110H
                                ; Result: A = 10H (only 8 bits stored)
                                ; CY flag = 1 (carry generated)
                                ; This indicates overflow in 8-bit addition

; --- Example 4: Multi-byte Addition (16-bit) ---
; Add two 16-bit numbers: 1234H + 5678H
; Lower bytes stored at 2050H, 2052H
; Higher bytes stored at 2051H, 2053H

        LXI H, 2050H            ; Point to first number's lower byte
        LXI D, 2052H            ; Point to second number's lower byte
        
        ; Store test data
        MVI M, 34H              ; Memory[2050H] = 34H (lower byte of 1234H)
        INX H
        MVI M, 12H              ; Memory[2051H] = 12H (higher byte of 1234H)
        
        MVI A, 78H              
        STAX D                  ; Memory[2052H] = 78H (lower byte of 5678H)
        INX D
        MVI A, 56H
        STAX D                  ; Memory[2053H] = 56H (higher byte of 5678H)
        
        ; Perform 16-bit addition
        LXI H, 2050H            ; Reset HL to point to first number
        LXI D, 2052H            ; Reset DE to point to second number
        
        MOV A, M                ; A = 34H (lower byte of first number)
        LDAX D                  ; Load lower byte of second number
        MOV B, A                ; B = 78H
        MOV A, M                ; A = 34H again
        ADD B                   ; A = 34H + 78H = ACH
                                ; CY = 0 (no carry from lower byte addition)
        
        STA 3020H               ; Store lower byte of result
                                ; Memory[3020H] = ACH
        
        INX H                   ; Point to higher byte of first number
        INX D                   ; Point to higher byte of second number
        
        MOV A, M                ; A = 12H (higher byte of first number)
        LDAX D                  ; Temporarily load second number's higher byte
        MOV B, A                ; B = 56H
        MOV A, M                ; A = 12H again
        ADC B                   ; Add with Carry: A = 12H + 56H + CY
                                ; A = 12H + 56H + 0 = 68H
                                ; Result: 68ACH (1234H + 5678H = 68ACH)
        
        STA 3021H               ; Store higher byte of result
                                ; Memory[3021H] = 68H
                                ; Complete result: 68ACH at addresses 3020H-3021H

; --- Example 5: Subtraction ---
        MVI A, 50H              ; A = 50H (80 decimal)
        MVI B, 20H              ; B = 20H (32 decimal)
        SUB B                   ; Subtract: A = A - B = 50H - 20H = 30H
                                ; A = 30H (48 decimal)
        
        SUI 10H                 ; Subtract Immediate: A = A - 10H
                                ; A = 30H - 10H = 20H (32 decimal)

; --- Example 6: Subtraction with Borrow ---
        MVI A, 20H              ; A = 20H (32 decimal)
        MVI B, 30H              ; B = 30H (48 decimal)
        SUB B                   ; A = 20H - 30H = F0H (2's complement)
                                ; CY flag = 1 (borrow generated, result negative)
                                ; In signed arithmetic: -16 decimal

; --- Example 7: Increment and Decrement ---
        MVI C, 0AH              ; C = 0AH (10 decimal)
        INR C                   ; Increment C by 1
                                ; C = 0BH (11 decimal)
                                ; Note: CY flag NOT affected by INR
        
        INR C                   ; C = 0CH (12 decimal)
        INR C                   ; C = 0DH (13 decimal)
        
        DCR C                   ; Decrement C by 1
                                ; C = 0CH (12 decimal)
                                ; Note: CY flag NOT affected by DCR

; --- Example 8: 16-bit Increment/Decrement ---
        LXI H, 2000H            ; HL = 2000H
        INX H                   ; Increment HL pair
                                ; HL = 2001H
                                ; No flags affected
        
        INX H                   ; HL = 2002H
        
        DCX H                   ; Decrement HL pair
                                ; HL = 2001H
                                ; No flags affected

        HLT                     ; Halt


; ----------------------------------------------------------------------------
; PROGRAM 3: LOGICAL OPERATIONS
; ----------------------------------------------------------------------------
; Purpose: Demonstrate AND, OR, XOR operations and bit manipulation
; Starting Address: 2200H
; ----------------------------------------------------------------------------

        ORG 2200H               ; Start at address 2200H

; --- Example 1: AND Operation (Masking) ---
; AND is used to clear specific bits or extract bit patterns
        MVI A, 0F5H             ; A = 0F5H = 11110101B
        ANI 0FH                 ; AND Immediate with 0FH = 00001111B
                                ; A = 11110101B AND 00001111B = 00000101B
                                ; A = 05H (lower nibble extracted, upper cleared)
                                ; Use case: Extract lower 4 bits

        MVI A, 0F5H             ; A = 0F5H = 11110101B
        ANI F0H                 ; AND with F0H = 11110000B
                                ; A = 11110101B AND 11110000B = 11110000B
                                ; A = F0H (upper nibble extracted, lower cleared)
                                ; Use case: Extract upper 4 bits

; --- Example 2: OR Operation (Setting Bits) ---
; OR is used to set specific bits to 1
        MVI A, 05H              ; A = 05H = 00000101B
        ORI 80H                 ; OR Immediate with 80H = 10000000B
                                ; A = 00000101B OR 10000000B = 10000101B
                                ; A = 85H (bit 7 is now set to 1)
                                ; Use case: Set specific bits without affecting others

        MVI A, 0AH              ; A = 0AH = 00001010B
        MVI B, 05H              ; B = 05H = 00000101B
        ORA B                   ; OR with register B
                                ; A = 00001010B OR 00000101B = 00001111B
                                ; A = 0FH

; --- Example 3: XOR Operation (Toggling Bits) ---
; XOR is used to toggle bits or compare values
        MVI A, F0H              ; A = F0H = 11110000B
        XRI 0FFH                ; XOR Immediate with FFH = 11111111B
                                ; A = 11110000B XOR 11111111B = 00001111B
                                ; A = 0FH (all bits inverted/complemented)
                                ; Use case: Complement/invert bits

        MVI A, 25H              ; A = 25H
        XRA A                   ; XOR A with itself
                                ; A = 25H XOR 25H = 00H
                                ; A = 00H (cleared to zero)
                                ; This is the FASTEST way to clear accumulator!
                                ; CY and AC flags are reset

; --- Example 4: Practical Bit Manipulation ---
; Check if a number is even or odd by testing bit 0
        MVI A, 47H              ; A = 47H = 01000111B (odd number)
        ANI 01H                 ; Mask all bits except bit 0
                                ; A = 01H (bit 0 is 1, so number is odd)
        
        MVI A, 46H              ; A = 46H = 01000110B (even number)
        ANI 01H                 ; Mask all bits except bit 0
                                ; A = 00H (bit 0 is 0, so number is even)
                                ; Z flag = 1 when even, Z flag = 0 when odd

        HLT                     ; Halt


; ----------------------------------------------------------------------------
; PROGRAM 4: COMPARISON AND CONDITIONAL OPERATIONS
; ----------------------------------------------------------------------------
; Purpose: Demonstrate CMP, CPI, and conditional jumps
; Starting Address: 2300H
; ----------------------------------------------------------------------------

        ORG 2300H               ; Start at address 2300H

; --- Example 1: Compare Two Numbers ---
        MVI A, 30H              ; A = 30H (48 decimal)
        MVI B, 30H              ; B = 30H (48 decimal)
        CMP B                   ; Compare A with B (performs A - B)
                                ; Result: A = B, so Z flag = 1
                                ; A is NOT modified, only flags change
        
        JZ EQUAL1               ; Jump if Zero flag = 1
                                ; This jump will be taken
        
        MVI C, 01H              ; This won't execute
        JMP NEXT1
        
EQUAL1: MVI C, FFH              ; C = FFH (indicates numbers are equal)

NEXT1:  NOP                     ; No operation (placeholder)

; --- Example 2: Compare - Less Than ---
        MVI A, 20H              ; A = 20H (32 decimal)
        MVI B, 30H              ; B = 30H (48 decimal)
        CMP B                   ; Compare A with B
                                ; A < B, so CY flag = 1 (borrow needed)
        
        JC LESS1                ; Jump if Carry = 1 (A < B)
                                ; This jump will be taken
        
        MVI D, 01H              ; This won't execute
        JMP NEXT2
        
LESS1:  MVI D, FFH              ; D = FFH (indicates A < B)

NEXT2:  NOP

; --- Example 3: Compare - Greater Than ---
        MVI A, 50H              ; A = 50H (80 decimal)
        MVI B, 30H              ; B = 30H (48 decimal)
        CMP B                   ; Compare A with B
                                ; A > B, so CY = 0 and Z = 0
        
        JNC GREATER1            ; Jump if No Carry (A >= B)
                                ; This jump will be taken
        JMP NEXT3
        
GREATER1: 
        CPI 30H                 ; Compare A with immediate value 30H
                                ; A > 30H, so CY = 0, Z = 0
        JZ NEXT3                ; Jump if equal (won't be taken)
        MVI E, FFH              ; E = FFH (indicates A > B)

NEXT3:  NOP

; --- Example 4: Find Maximum of Two Numbers ---
; Store at 2050H and 2051H, result at 3030H
        MVI A, 45H
        STA 2050H               ; First number = 45H
        MVI A, 67H
        STA 2051H               ; Second number = 67H
        
        LDA 2050H               ; Load first number into A
        MOV B, A                ; Save it in B
        LDA 2051H               ; Load second number into A
        CMP B                   ; Compare second with first
        
        JNC MAX_OK              ; If A >= B, A has maximum
        MOV A, B                ; Otherwise, B has maximum
        
MAX_OK: STA 3030H               ; Store maximum at 3030H
                                ; Result: 67H stored at 3030H

        HLT                     ; Halt


; ----------------------------------------------------------------------------
; PROGRAM 5: LOOPS AND ARRAY OPERATIONS
; ----------------------------------------------------------------------------
; Purpose: Demonstrate loops using counters and flags
; Starting Address: 2400H
; ----------------------------------------------------------------------------

        ORG 2400H               ; Start at address 2400H

; --- Example 1: Simple Loop - Count from 1 to 10 ---
        MVI B, 0AH              ; Initialize counter B = 10 (loop 10 times)
        XRA A                   ; Clear accumulator (A = 0)
        
LOOP1:  INR A                   ; Increment A (A = A + 1)
                                ; After iterations: A = 1, 2, 3, ..., 10
        DCR B                   ; Decrement counter (B = B - 1)
                                ; Z flag set when B becomes 0
        JNZ LOOP1               ; Jump if Not Zero (if B != 0, repeat loop)
                                ; Loop executes 10 times
        
        STA 3040H               ; Store final count (0AH) at 3040H

; --- Example 2: Sum of Array Elements ---
; Array: 5 bytes starting at 2500H
; Store sum at 3041H
        
        ; First, initialize array with test data
        MVI A, 10H
        STA 2500H               ; Array[0] = 10H
        MVI A, 15H
        STA 2501H               ; Array[1] = 15H
        MVI A, 20H
        STA 2502H               ; Array[2] = 20H
        MVI A, 0AH
        STA 2503H               ; Array[3] = 0AH
        MVI A, 05H
        STA 2504H               ; Array[4] = 05H
        
        ; Now calculate sum
        LXI H, 2500H            ; HL points to start of array
        MVI C, 05H              ; Counter = 5 elements
        XRA A                   ; Clear accumulator (sum = 0)
        
SUMLOOP:ADD M                   ; Add current array element to sum
                                ; First iteration: A = 0 + 10H = 10H
                                ; Second iteration: A = 10H + 15H = 25H
                                ; Third iteration: A = 25H + 20H = 45H
                                ; Fourth iteration: A = 45H + 0AH = 4FH
                                ; Fifth iteration: A = 4FH + 05H = 54H
        INX H                   ; Move to next array element (HL = HL + 1)
        DCR C                   ; Decrement counter
        JNZ SUMLOOP             ; Repeat if counter != 0
        
        STA 3041H               ; Store sum (54H = 84 decimal) at 3041H

; --- Example 3: Count Positive Numbers in Array ---
; Same array at 2500H, store count at 3042H
        LXI H, 2500H            ; HL points to array start
        MVI C, 05H              ; Counter = 5 elements
        MVI B, 00H              ; B will hold count of positive numbers
        
COUNTLOOP:
        MOV A, M                ; Load current array element
        ANI 80H                 ; Check bit 7 (sign bit)
                                ; If bit 7 = 0, number is positive
        JNZ SKIP                ; If bit 7 = 1, skip (negative/signed)
        INR B                   ; Increment positive count
        
SKIP:   INX H                   ; Next element
        DCR C                   ; Decrement counter
        JNZ COUNTLOOP           ; Repeat if counter != 0
        
        MOV A, B                ; Move count to A
        STA 3042H               ; Store count at 3042H
                                ; All numbers are positive, so count = 5

        HLT                     ; Halt


; ----------------------------------------------------------------------------
; PROGRAM 6: SUBROUTINES AND STACK OPERATIONS
; ----------------------------------------------------------------------------
; Purpose: Demonstrate CALL, RET, PUSH, POP
; Starting Address: 2500H
; ----------------------------------------------------------------------------

        ORG 2500H               ; Start at address 2500H
        
        LXI SP, 3FFFH           ; Initialize stack pointer (IMPORTANT!)

; --- Main Program ---
        MVI A, 15H              ; A = 15H
        MVI B, 25H              ; B = 25H
        
        CALL ADD_SUB            ; Call subroutine at ADD_SUB
                                ; PC is pushed onto stack
                                ; (SP-1) = high byte of return address
                                ; (SP-2) = low byte of return address
                                ; SP = SP - 2
                                ; PC = address of ADD_SUB
        
        STA 3050H               ; Store result at 3050H
        
        MVI A, 50H              ; A = 50H
        MVI B, 30H              ; B = 30H
        
        CALL ADD_SUB            ; Call subroutine again
        
        STA 3051H               ; Store result at 3051H
        
        HLT                     ; Halt main program

; --- Subroutine: Add Two Numbers ---
; Input: A and B contain numbers to add
; Output: A contains sum
; Registers used: A, D
ADD_SUB:
        PUSH D                  ; Save D register on stack (preserve it)
                                ; (SP-1) = D, SP = SP - 1
                                ; Important: Save registers you'll modify!
        
        MOV D, A                ; Save A in D temporarily
        ADD B                   ; A = A + B (add the two numbers)
        
        POP D                   ; Restore D register from stack
                                ; D = (SP), SP = SP + 1
                                ; D is now back to its original value
        
        RET                     ; Return to caller
                                ; Pop return address from stack into PC
                                ; Low byte = (SP), High byte = (SP+1)
                                ; SP = SP + 2
                                ; Execution continues after CALL instruction

; --- Example of Nested Subroutine Calls ---
        ORG 2600H               ; New section at 2600H
        
        LXI SP, 3FFFH           ; Initialize SP
        
        MVI A, 10H              ; A = 10H
        CALL LEVEL1             ; Call first level subroutine
        
        HLT                     ; Halt

LEVEL1: PUSH PSW                ; Push A and Flags onto stack
                                ; PSW = Program Status Word (A + Flags)
                                ; (SP-1) = A, (SP-2) = Flags, SP = SP - 2
        
        MVI A, 20H              ; A = 20H
        CALL LEVEL2             ; Call second level subroutine
                                ; Stack now has: return address for LEVEL2,
                                ; then return address for LEVEL1, then PSW
        
        POP PSW                 ; Restore A and Flags
                                ; Flags = (SP), A = (SP+1), SP = SP + 2
                                ; A restored to 10H
        
        RET                     ; Return to main program

LEVEL2: INR A                   ; A = 21H
        RET                     ; Return to LEVEL1
                                ; Each RET pops the correct return address


; ----------------------------------------------------------------------------
; PROGRAM 7: PRACTICAL EXAMPLE - BCD ADDITION
; ----------------------------------------------------------------------------
; Purpose: Add two 2-digit BCD numbers with decimal adjust
; Starting Address: 2700H
; ----------------------------------------------------------------------------

        ORG 2700H               ; Start at 2700H

; Add 29 + 17 in BCD (result should be 46 in BCD)
        MVI A, 29H              ; A = 29H (BCD for 29 decimal)
                                ; NOT 29 in hex! Each nibble is 0-9
        MVI B, 17H              ; B = 17H (BCD for 17 decimal)
        ADD B                   ; A = 29H + 17H = 40H (incorrect in BCD!)
                                ; In BCD, this should be 46H
        
        DAA                     ; Decimal Adjust Accumulator
                                ; Corrects binary sum to proper BCD
                                ; A = 46H (correct BCD result)
                                ; DAA checks if lower/upper nibble > 9
                                ; and adds 06H to that nibble if needed
        
        STA 3060H               ; Store BCD result (46H) at 3060H

        HLT                     ; Halt


; ----------------------------------------------------------------------------
; PROGRAM 8: COMPREHENSIVE EXAMPLE - COMPLETE APPLICATION
; ----------------------------------------------------------------------------
; Purpose: Find largest number in array and store its position
; Array: 10 bytes at 2800H
; Result: Largest value at 3070H, position at 3071H
; Starting Address: 2750H
; ----------------------------------------------------------------------------

        ORG 2750H               ; Start at 2750H
        
        LXI SP, 3FFFH           ; Initialize stack pointer

; --- Initialize test array ---
        LXI H, 2800H            ; Point to array start
        MVI M, 23H              ; Array[0] = 23H
        INX H
        MVI M, 67H              ; Array[1] = 67H
        INX H
        MVI M, 45H              ; Array[2] = 45H
        INX H
        MVI M, 89H              ; Array[3] = 89H (largest)
        INX H
        MVI M, 12H              ; Array[4] = 12H
        INX H
        MVI M, 34H              ; Array[5] = 34H
        INX H
        MVI M, 56H              ; Array[6] = 56H
        INX H
        MVI M, 78H              ; Array[7] = 78H
        INX H
        MVI M, 9AH              ; Array[8] = 9AH (Error: A is not a BCD digit, but valid hex)
        INX H
        MVI M, 0BH              ; Array[9] = 0BH

; --- Find maximum element ---
        LXI H, 2800H            ; Reset HL to array start
        MVI C, 0AH              ; Counter = 10 elements
        MVI B, 00H              ; B = position counter (0-based index)
        MVI D, 00H              ; D = position of maximum
        MOV A, M                ; A = first element (assume it's max initially)
        
FINDMAX:
        CMP M                   ; Compare A with current element
        JNC NOTMAX              ; Jump if A >= M (current element not larger)
        
        ; Current element is larger than A
        MOV A, M                ; Update maximum value in A
        MOV D, B                ; Update position of maximum
        
NOTMAX: INX H                   ; Move to next array element
        INR B                   ; Increment position counter
        DCR C                   ; Decrement element counter
        JNZ FINDMAX             ; Repeat if more elements remain
        
        ; Store results
        STA 3070H               ; Store largest value at 3070H
                                ; Result: 9AH
        MOV A, D                ; Load position into A
        STA 3071H               ; Store position at 3071H
                                ; Result: 08H (position 8, 9th element)

        HLT                     ; Halt - Program complete!

