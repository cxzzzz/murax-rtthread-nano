
#include "cpuport.h"

.global crtStart
.global main
.global irqCallback

    .section	.start_jump,"ax",@progbits
crtStart:
  //long jump to allow crtInit to be anywhere
  //do it always in 12 bytes
  li  a0 , 0x1234abcd
  nop
  nop
  nop
  csrw mepc, a0
  nop
  lui x2,       %hi(crtInit)
  addi x2, x2,  %lo(crtInit)
  jalr x1,x2
  nop

.section .text

.global  trap_entry
.align 5

trap_entry:
    addi sp, sp, -32 * REGBYTES

    sw x1,   1 * REGBYTES(sp)
    li    t0,   0x80
    sw t0,   2 * REGBYTES(sp)

    sw x4,   4 * REGBYTES(sp)
    sw x5,   5 * REGBYTES(sp)
    sw x6,   6 * REGBYTES(sp)
    sw x7,   7 * REGBYTES(sp)
    sw x8,   8 * REGBYTES(sp)
    sw x9,   9 * REGBYTES(sp)
    sw x10, 10 * REGBYTES(sp)
    sw x11, 11 * REGBYTES(sp)
    sw x12, 12 * REGBYTES(sp)
    sw x13, 13 * REGBYTES(sp)
    sw x14, 14 * REGBYTES(sp)
    sw x15, 15 * REGBYTES(sp)
    sw x16, 16 * REGBYTES(sp)
    sw x17, 17 * REGBYTES(sp)
    sw x18, 18 * REGBYTES(sp)
    sw x19, 19 * REGBYTES(sp)
    sw x20, 20 * REGBYTES(sp)
    sw x21, 21 * REGBYTES(sp)
    sw x22, 22 * REGBYTES(sp)
    sw x23, 23 * REGBYTES(sp)
    sw x24, 24 * REGBYTES(sp)
    sw x25, 25 * REGBYTES(sp)
    sw x26, 26 * REGBYTES(sp)
    sw x27, 27 * REGBYTES(sp)
    sw x28, 28 * REGBYTES(sp)
    sw x29, 29 * REGBYTES(sp)
    sw x30, 30 * REGBYTES(sp)
    sw x31, 31 * REGBYTES(sp)

    move  s0, sp

    /* switch to interrupt stack */
    la    sp, _sp

    /* interrupt handle */

  /*
    call  rt_interrupt_enter
    csrr  a0, mcause
    csrr  a1, mepc
    mv    a2, sp
    csrrw ra, 0x07ED, ra
    call  rt_interrupt_leave
   */

    call irqCallback


    /* switch to from thread stack */
    move  sp, s0

    /* need to switch new thread */
    la    s0, rt_thread_switch_interrupt_flag
    lw    s2, 0(s0)
    beqz  s2, spurious_interrupt
    /* clear switch interrupt flag */
    sw    zero, 0(s0)

    csrr  a0, mepc
    sw a0, 0 * REGBYTES(sp)

    la    s0, rt_interrupt_from_thread
    lw  s1, 0(s0)
    sw sp, 0(s1)

    la    s0, rt_interrupt_to_thread
    lw  s1, 0(s0)
    lw  sp, 0(s1)

    lw  a0,  0 * REGBYTES(sp)
    csrw  mepc, a0

spurious_interrupt:
    lw  x1,   1 * REGBYTES(sp)

    /* Remain in M-mode after mret */
    li    t0, 0x00001800
    csrs  mstatus, t0
    lw  t0,   2 * REGBYTES(sp)
    csrs  mstatus, t0

    lw  x4,   4 * REGBYTES(sp)
    lw  x5,   5 * REGBYTES(sp)
    lw  x6,   6 * REGBYTES(sp)
    lw  x7,   7 * REGBYTES(sp)
    lw  x8,   8 * REGBYTES(sp)
    lw  x9,   9 * REGBYTES(sp)
    lw  x10, 10 * REGBYTES(sp)
    lw  x11, 11 * REGBYTES(sp)
    lw  x12, 12 * REGBYTES(sp)
    lw  x13, 13 * REGBYTES(sp)
    lw  x14, 14 * REGBYTES(sp)
    lw  x15, 15 * REGBYTES(sp)
    lw  x16, 16 * REGBYTES(sp)
    lw  x17, 17 * REGBYTES(sp)
    lw  x18, 18 * REGBYTES(sp)
    lw  x19, 19 * REGBYTES(sp)
    lw  x20, 20 * REGBYTES(sp)
    lw  x21, 21 * REGBYTES(sp)
    lw  x22, 22 * REGBYTES(sp)
    lw  x23, 23 * REGBYTES(sp)
    lw  x24, 24 * REGBYTES(sp)
    lw  x25, 25 * REGBYTES(sp)
    lw  x26, 26 * REGBYTES(sp)
    lw  x27, 27 * REGBYTES(sp)
    lw  x28, 28 * REGBYTES(sp)
    lw  x29, 29 * REGBYTES(sp)
    lw  x30, 30 * REGBYTES(sp)
    lw  x31, 31 * REGBYTES(sp)

    addi  sp, sp, 32 * REGBYTES
    mret

crtInit:
  .option push
  .option norelax
  la gp, __global_pointer$
  .option pop
  la sp, _stack_start

  //配置中断跳转地址
  la t0, trap_entry
  //la t0,irqCallback
  csrw mtvec, t0 

bss_init:
  la a0, _bss_start
  la a1, _bss_end
bss_loop:
  beq a0,a1,bss_done
  sw zero,0(a0)
  add a0,a0,4
  j bss_loop
bss_done:

ctors_init:
  la a0, _ctors_start
  addi sp,sp,-4
ctors_loop:
  la a1, _ctors_end
  beq a0,a1,ctors_done
  lw a3,0(a0)
  add a0,a0,4
  sw a0,0(sp)
  jalr  a3
  lw a0,0(sp)
  j ctors_loop
ctors_done:
  addi sp,sp,4


  li a0, 0x880     //880 enable timer + external interrupts
  csrw mie,a0
  li a0, 0x1808     //1808 enable interrupts
  csrw mstatus,a0

  //call main
  call entry
  //call main_test
infinitLoop:
  j infinitLoop
