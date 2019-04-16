//           july 5, 1976
//     basic floating point routines
//       for 6502 microprocessor
//       by r. rankin and s. wozniak
//
//     consisting of:
//        natural log
//        common log
//        exponential (e**x)
//        float      fix
//        fadd       fsub
//        fmul       fdiv
//
//
//     floating point representation (4-bytes)
//                    exponent byte 1
//                    mantissa bytes 2-4
//
//     mantissa:    two's complement representation with sign in
//       msb of high-order byte.  mantissa is normalized with an
//       assumed decimal point between bits 5 and 6 of the high-order
//       byte.  thus the mantissa is in the range 1. to 2. except
//       when the number is less than 2**(-128).
//
//     exponent:    the exponent represents powers of two.  the
//       representation is 2's complement except that the sign
//       bit (bit 7) is complemented.  this allows direct comparison
//       of exponents for size since they are stored in increasing
//       numerical sequence ranging from $00 (-128) to $ff (+127)
//       ($ means number is hexadecimal).
//
//     representation of decimal numbers:    the present floating
//       point representation allows decimal numbers in the approximate
//       range of 10**(-38) through 10**(38) with 6 to 7 significant
//       digits.
//
wozfp:
//
//
//     natural log of mant/exp1 with result in mant/exp1
//
log:    lda m1
        beq error
        bpl cont    // if arg>0 ok
error:  rts         // error arg<=0

cont:  jsr swap    // move arg to exp/mant2
       ldx #0      // load x for high byte of exponent
       lda x2      // hold exponent
       ldy #$80
       sty x2      // set exponent 2 to 0 ($80)
       eor #$80    // complement sign bit of original exponent
       sta m1+1    // set exponent into mantissa 1 for float
       bpl *+3     // is exponent negative
       dex         // yes, set x to $ff
       stx m1      // set upper byte of exponent
       jsr float   // convert to floating point
       ldx #3      // 4 byte transfers
sexp1: lda x2,x
       sta zz,x    // copy mantissa to z
       lda x1,x
       sta sexp,x  // save exponent in sexp
       lda r22,x   // load exp/mant1 with sqrt(2)
       sta x1,x
       dex
       bpl sexp1
       jsr fsub    // z-sqrt(2)
       ldx #3      // 4 byte transfer
savet: lda x1,x    // save exp/mant1 as t
       sta t,x
       lda zz,x    // load exp/mant1 with z
       sta x1,x
       lda r22,x   // load exp/mant2 with sqrt(2)
       sta x2,x
       dex
       bpl savet
       jsr fadd    // z+sqrt(2)
       ldx #3      // 4 byte transfer
tm2:   lda t,x
       sta x2,x    // load t into exp/mant2
       dex
       bpl tm2
       jsr fdiv    // t=(z-sqrt(2))/(z+sqrt(2))
       ldx #3      // 4 byte transfer
mit:   lda x1,x
       sta t,x     // copy exp/mant1 to t and
       sta x2,x    // load exp/mant2 with t
       dex
       bpl mit
       jsr fmul    // t*t
       jsr swap    // move t*t to exp/mant2
       ldx #3      // 4 byte transfer
mic:   lda c,x
       sta x1,x    // load exp/mant1 with c
       dex
       bpl mic
       jsr fsub    // t*t-c
       ldx #3      // 4 byte transfer
m2mb:  lda mb,x
       sta x2,x    // load exp/mant2 with mb
       dex
       bpl m2mb
       jsr fdiv    // mb/(t*t-c)
       ldx #3
m2a1:  lda a1,x
       sta x2,x    // load exp/mant2 with a1
       dex
       bpl m2a1
       jsr fadd    // mb/(t*t-c)+a1
       ldx #3      // 4 byte transfer
m2t:   lda t,x
       sta x2,x    // load exp/mant2 with t
       dex
       bpl m2t
       jsr fmul    // (mb/(t*t-c)+a1)*t
       ldx #3      // 4 byte transfer
m2mhl: lda mhlf,x
       sta x2,x    // load exp/mant2 with mhlf (.5)
       dex
       bpl m2mhl
       jsr fadd    // +.5
       ldx #3      // 4 byte transfer
ldexp: lda sexp,x
       sta x2,x    // load exp/mant2 with original exponent
       dex
       bpl ldexp
       jsr fadd    // +expn
       ldx #3      // 4 byte transfer
mle2:  lda le2,x
       sta x2,x    // load exp/mant2 with ln(2)
       dex
       bpl mle2
       jsr fmul    // *ln(2)
       rts         // return result in mant/exp1
//
//     common log of mant/exp1 result in mant/exp1
//
log10: jsr log     // compute natural log
       ldx #3
l10:   lda ln10,x
       sta x2,x    // load exp/mant2 with 1/ln(10)
       dex
       bpl l10
       jsr fmul    // log10(x)=ln(x)/ln(10)
       rts
//
ln10:  .byte $7e, $6f, $2d, $ed // 0.4342945

r22:   .byte $80, $5a, $02, $7a // 1.4142136 sqrt(2)

le2:   .byte $7f, $58, $b9, $0c // 0.69314718 log base e of 2

a1:    .byte $80, $52, $80, 40 // 1.2920074

mb:    .byte $81, $ab, $86, $49 // -2.6398577

c:     .byte $80, $6a, $08, $66 // 1.6567626

mhlf:  .byte $7f, $40, $00, $00 // 0.5

//
       //.res $1e00-*
       //.org $1e00   // starting location for exp
//
//     exp of mant/exp1 result in mant/exp1
//
exp:   ldx #3      // 4 byte transfer
       lda l2e,x
       sta x2,x    // load exp/mant2 with log base 2 of e
       dex
       bpl exp+2
       jsr fmul    // log2(3)*x
       ldx #3      // 4 byte transfer
fsa:   lda x1,x
       sta zz,x    // store exp/mant1 in z
       dex
       bpl fsa     // save z=ln(2)*x
       jsr fix     // convert contents of exp/mant1 to an integer
       lda m1+1
       sta int     // save result as int
       sec         // set carry for subtraction
       sbc #124    // int-124
       lda m1
       sbc #0
       bpl ovflw   // overflow int>=124
       clc         // clear carry for add
       lda m1+1
       adc #120    // add 120 to int
       lda m1
       adc #0
       bpl contin  // if result positive continue
       lda #0      // int<-120 set result to zero and return
       ldx #3      // 4 byte move
zero:  sta x1,x    // set exp/mant1 to zero
       dex
       bpl zero
       rts         // return
//
ovflw: brk         // overflow
//
contin: 
	   jsr float   // float int
       ldx #3
entd:  lda zz,x
       sta x2,x    // load exp/mant2 with z
       dex
       bpl entd
       jsr fsub    // z*z-float(int)
       ldx #3      // 4 byte move
zsav:  lda x1,x
       sta zz,x    // save exp/mant1 in z
       sta x2,x    // copy exp/mant1 to exp/mant2
       dex
       bpl zsav
       jsr fmul    // z*z
       ldx #3      // 4 byte move
la2:   lda a2,x
       sta x2,x    // load exp/mant2 with a2
       lda x1,x
       sta sexp,x  // save exp/mant1 as sexp
       dex
       bpl la2
       jsr fadd    // z*z+a2
       ldx #3      // 4 byte move
lb2:   lda b2,x
       sta x2,x    // load exp/mant2 with b2
       dex
       bpl lb2
       jsr fdiv    // t=b/(z*z+a2)
       ldx #3      // 4 byte move
dload: lda x1,x
       sta t,x     // save exp/mant1 as t
       lda c2,x
       sta x1,x    // load exp/mant1 with c2
       lda sexp,x
       sta x2,x    // load exp/mant2 with sexp
       dex
       bpl dload
       jsr fmul    // z*z*c2
       jsr swap    // move exp/mant1 to exp/mant2
       ldx #3      // 4 byte transfer
ltmp:  lda t,x
       sta x1,x    // load exp/mant1 with t
       dex
       bpl ltmp
       jsr fsub    // c2*z*z-b2/(z*z+a2)
       ldx #3      // 4 byte transfer
ldd:   lda d,x
       sta x2,x    // load exp/mant2 with d
       dex
       bpl ldd
       jsr fadd    // d+c2*z*z-b2/(z*z+a2)
       jsr swap    // move exp/mant1 to exp/mant2
       ldx #3      // 4 byte transfer
lfa:   lda zz,x
       sta x1,x    // load exp/mant1 with z
       dex
       bpl lfa
       jsr fsub    // -z+d+c2*z*z-b2/(z*z+a2)
       ldx #3      // 4 byte transfer
lf3:   lda zz,x
       sta x2,x    // load exp/mant2 with z
       dex
       bpl lf3
       jsr fdiv    // z/(**** )
       ldx #3      // 4 byte transfer
ld12:  lda mhlf,x
       sta x2,x    // load exp/mant2 with .5
       dex
       bpl ld12
       jsr fadd    // +z/(***)+.5
       sec         // add int to exponent with carry set
       lda int     // to multiply by
       adc x1      // 2**(int+1)
       sta x1      // return result to exponent
       rts         // return ans=(.5+z/(-z+d+c2*z*z-b2/(z*z+a2))*2**(int+1)
l2e:   .byte $80, $5c, $55, $1e // 1.4426950409 log base 2 of e

a2:    .byte $86, $57, $6a, $e1 // 87.417497202

b2:    .byte $89, $4d, $3f, $1d // 617.9722695

c2:    .byte $7b, $46, $fa, $70 // .03465735903

d:     .byte $83, $4f, $a3, $03 // 9.9545957821

//
//
//     basic floating point routines
//
       //.res $1f00-*
       //.org $1f00  // start of basic floating point routines
add:   clc         // clear carry
       ldx #$02    // index for 3-byte add
add1:  lda m1,x
       adc m2,x    // add a byte of mant2 to mant1
       sta m1,x
       dex         // advance index to next more signif.byte
       bpl add1    // loop until done.
       rts         // return
md1:   asl sign    // clear lsb of sign
       jsr abswap  // abs val of mant1, then swap mant2
abswap:bit m1     // mant1 neg?
       bpl abswp1  // no,swap with mant2 and return
       jsr fcompl  // yes, complement it.
       inc sign    // incr sign, complementing lsb
abswp1:sec        // set carry for return to mul/div
//
//     swap exp/mant1 with exp/mant2
//
swap:  ldx #$04    // index for 4-byte swap.
swap1: sty e-1,x
       lda x1-1,x  // swap a byte of exp/mant1 with
       ldy x2-1,x  // exp/mant2 and leavea copy of
       sty x1-1,x  // mant1 in e(3bytes). e+3 used.
       sta x2-1,x
       dex         // advance index to next byte
       bne swap1   // loop until done.
       rts
//
//
//
//     convert 16 bit integer in m1(high) and m1+1(low) to f.p.
//     result in exp/mant1.  exp/mant2 uneffected
//
//
float: lda #$8e
       sta x1      // set expn to 14 dec
       lda #0      // clear low order byte
       sta m1+2
       beq norml   // normalize result
norm1: dec x1      // decrement exp1
       asl m1+2
       rol m1+1    // shift mant1 (3 bytes) left
       rol m1
norml: lda m1      // high order mant1 byte
       asl         // upper two bits unequal?
       eor m1
       bmi rts1    // yes,return with mant1 normalized
       lda x1      // exp1 zero?
       bne norm1   // no, continue normalizing
rts1:  rts         // return
//
//
//     exp/mant2-exp/mant1 result in exp/mant1
//
fsub:  jsr fcompl  // cmpl mant1 clears carry unless zero
swpalg:jsr algnsw // right shift mant1 or swap with mant2 on carry
//
//     add exp/mant1 and exp/mant2 result in exp/mant1
//
fadd:  lda x2
       cmp x1      // compare exp1 with exp2
       bne swpalg  // if unequal, swap addends or align mantissas
       jsr add     // add aligned mantissas
addend:bvc norml  // no overflow, normalize results
       bvs rtlog   // ov: shift mant1 right. note carry is correct sign
algnsw:bcc swap   // swap if carry clear, else shift right arith.
rtar:  lda m1      // sign of mant1 into carry for
       asl         // right arith shift
rtlog: inc x1      // incr exp1 to compensate for rt shift
       beq ovfl    // exp1 out of range.
rtlog1:ldx #$fa   // index for 6 byte right shift
ror1:  lda #$80
       bcs ror2
       asl
ror2:  lsr e+3,x   // simulate ror e+3,x
       ora e+3,x
       sta e+3,x
       inx         // next byte of shift
       bne ror1    // loop until done
       rts         // return
//
//
//     exp/mant1 x exp/mant2 result in exp/mant1
//
fmul:  jsr md1     // abs. val of mant1, mant2
       adc x1      // add exp1 to exp2 for product exponent
       jsr md2     // check product exp and prepare for mul
       clc         // clear carry
mul1:  jsr rtlog1  // mant1 and e right.(product and mplier)
       bcc mul2    // if carry clear, skip partial product
       jsr add     // add multiplican to product
mul2:  dey         // next mul iteration
       bpl mul1    // loop until done
mdend: lsr sign    // test sign (even/odd)
normx: bcc norml   // if exen, normalize product, else complement
fcompl: sec        // set carry for subtract
       ldx #$03    // index for 3 byte subtraction
compl1: lda #$00   // clear a
       sbc x1,x    // subtract byte of exp1
       sta x1,x    // restore it
       dex         // next more significant byte
       bne compl1  // loop until done
       beq addend  // normalize (or shift right if overflow)
//
//
//     exp/mant2 / exp/mant1 result in exp/mant1
//
fdiv:  jsr md1     // take abs val of mant1, mant2
       sbc x1      // subtract exp1 from exp2
       jsr md2     // save as quotient exp
div1:  sec         // set carry for subtract
       ldx #$02    // index for 3-byte instruction
div2:  lda m2,x
       sbc e,x     // subtract a byte of e from mant2
       pha         // save on stack
       dex         // next more signif byte
       bpl div2    // loop until done
       ldx #$fd    // index for 3-byte conditional move
div3:  pla         // pull a byte of difference off stack
       bcc div4    // if mant2<e then dont restore mant2
       sta m2+3,x
div4:  inx         // next less signif byte
       bne div3    // loop until done
       rol m1+2
       rol m1+1    // roll quotient left, carry into lsb
       rol m1
       asl m2+2
       rol m2+1    // shift dividend left
       rol m2
       bcs ovfl    // overflow is due to unnormalized divisor
       dey         // next divide iteration
       bne div1    // loop until done 23 iterations
       beq mdend   // normalize quotient and correct sign
md2:   stx m1+2
       stx m1+1    // clr mant1 (3 bytes) for mul/div
       stx m1
       bcs ovchk   // if exp calc set carry, check for ovfl
       bmi md3     // if neg no underflow
       pla         // pop one
       pla         // return level
       bcc normx   // clear x1 and return
md3:   eor #$80    // complement sign bit of exp
       sta x1      // store it
       ldy #$17    // count for 24 mul or 23 div iterations
       rts         // return
ovchk: bpl md3     // if pos exp then no overflow
ovfl:  brk
//
//
//     convert exp/mant1 to integer in m1 (high) and m1+1(low)
//      exp/mant2 uneffected
//
       jsr rtar    // shift mant1 rt and increment expnt
fix:   lda x1      // check exponent
       cmp #$8e    // is exponent 14?
       bne fix-3   // no, shift
rtrn:  rts         // return



