
@Legg inn tallene i IEE format som du ønsker å addere
num1:   .word   0x40400000
@2,4.0x40000000
@1.0x3F800000
@3.0x40400000

num2:   .word   0x40600000
@4.0x3F010000
@1,2.0x3F800000
@3.0x40600000

@Denne løsningen ser bort ifra sign-bits, altså regner den ikke med negative tall
eks: 	.word 	0x7F800000
des: 	.word 	0x7FFFFF
ledO: 	.word 	0x800000

.text 
.global main

main:

    LDR r0, num1
    LDR r1, num2
    Push {r4, r5, r6}  
    LDR r4, eks @Eksponent-mask
    LDR r5, des @Desimal-mask
    LDR r6, ledO @Leading-one

    @ Maskerer eksponenten fra r0 og flytter det til eksponentplassen
    AND r2, r0, r4
    LSR r2, #23
    
    @ Vi maskerer nå num2 sin eksponent
    AND r7, r1, r4
    LSR r7, #23

    @ Maskerer DECIMALEN til num1
    AND r3, r0, r5
    
    @ Maskerer DECIMALEN til num2
    AND r1, r1, r5

    @ Legger til ledende 1 på desimalen dersom eksponenten ikke er null
    CMP r2, #0
    ORRNE r3, r3, r6 @ orrer desimal med leading one
    
    @ Ledende 1. samme operasjon som i num1
    CMP r7, #0
    ORRNE r1, r1, r6

    POP {r4, r5, r6}
    
sammenligning: 
    @ Sammenligner eksponenten til num2, r7, og eksponenten til num1, r2
    CMP r7, r2
    BMI mindreEnn
    BEQ neste @Sjekker først om de er like, siden GE-flag slår til også dersom de er større eller like. 
    BGE storreEnn
	
	
mindreEnn:
    Push {r4}
    SUB r4, r2, r7
    MOV r7, r2
    LSR r1, r4
    B neste
    
storreEnn: 
	@Trekker fra og skifter med den subtraherte verdien
	SUB r4, r7, r2
	LSR r3, r4
	
    
neste:    
    @ Legger sammen desimalene
    Pop {r4}
    ADD r1, r1, r3

    @ Normaliserer dersom nødvendig
    MOV r5, r1
    LSR r5, #24
    CMP r5, #1
    BEQ shift
	B fjern
	
shift:
    LSR r1, #1
    ADD r7, #1
fjern: 
    MOV r5, #1
    LSL r5, #23
    BIC r1, r1, r5
    LSL r7, #23
    @Lagrer resultatet i r0
    ORR r0, r1, r7
    
	
    BX lr
	

