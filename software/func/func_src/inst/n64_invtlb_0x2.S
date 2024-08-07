#include "asm.h"
#include "regdef.h"
#include "inst_test.h"

LEAF(n64_invtlb_0x2_test)
    addi.w s0, s0, 0x1
    addi.w s2, zero, 0x0

    csrrd  t8, csr_tlbidx 
    li.w   t0, 0x80000000 
    or     t8, t8, t0 
    srli.w t8, t8, TLB_IDX

    invtlb 0x2, zero, zero

    li.w     t1, 0x0c00000c
    li.w     t2, 0x0c000010
    add.w t0, zero, t1
    add.w t4, zero, t2 
1:
    addi.w t1, t0, 0x0
    csrwr t1, csr_tlbidx
    tlbrd
    csrrd t1, csr_tlbehi
#li    t2, 0x0 
    bne   t1, zero, inst_error
    csrrd t1, csr_tlbelo0
#li    t2, 0x0
    bne   t1, zero, inst_error
    csrrd t1, csr_tlbelo1
#li    t2, 0x0
    bne   t1, zero, inst_error
    li.w  t1, 0x3f000000
    csrxchg zero, t1, csr_tlbidx
    csrrd t1, csr_tlbidx
#li    t2, 0x04000000
    srli.w t1, t1, TLB_IDX
    bne   t1, t8, inst_error
    addi.w t0, t0, 0x1  
    bne   t0, t4, 1b

    li.w     t1, 0x0c000000
    li.w     t2, 0x0c00000c
    add.w t0, zero, t1
    add.w t4, zero, t2
2:
    addi.w t1, t0, 0x0
    csrwr t1, csr_tlbidx
    tlbrd
    csrrd t1, csr_tlbidx
    srli.w t1, t1, TLB_IDX
    li.w  t2, (0x0c000000>>TLB_IDX)
    bne   t1, t2, inst_error
    addi.w t0, t0, 0x1  
    bne   t0, t4, 2b

###detect exception
    bne s2, zero, inst_error

#if 0
    li.w    t1, 0xa
    li.w    t2, 0xb
    invtlb 0x0, t1, t2
###detect exception
    beq s2, zero, inst_error
#endif

###score ++
    addi.w s3, s3, 1
###output (s0<<24)|s3
inst_error:  
    slli.w t1, s0, 24
    or t0, t1, s3 
    st.w t0, s1, 0x0
    jirl zero, ra, 0x0
END(n64_invtlb_0x2_test)
