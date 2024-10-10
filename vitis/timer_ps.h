/************************************************************************/
/*																		*/
/*	timer_ps.h	--	Timer Delay	for Zynq systems						*/
/*																		*/
/************************************************************************/
/*	Author: Sam Bobrowicz												*/
/*	Copyright 2014, Digilent Inc.										*/
/************************************************************************/
/*  Module Description: 												*/
/*																		*/
/*		Implements an accurate delay function using the scu	timer.     	*/
/*		Code from this module will cause conflicts with other code that */
/*		requires the Zynq's scu timer.									*/
/*																		*/
/*		This module contains code from the Xilinx Demo titled			*/
/*		"xscutimer_polled_example.c"									*/
/*																		*/
/************************************************************************/
/*  Revision History:													*/
/* 																		*/
/*		2/14/2014(SamB): Created										*/
/*																		*/
/************************************************************************/
#ifndef TIMER_PS_H_
#define TIMER_PS_H_

#include "xil_types.h"
#include "xscutimer.h"
#include "xparameters.h"

/* ------------------------------------------------------------ */
/*					Miscellaneous Declarations					*/
/* ------------------------------------------------------------ */

//#define TIMER_FREQ_HZ (XPAR_CPU_CORTEXA9_0_CPU_CLK_FREQ_HZ / 2) // parameter from <xparameters.h> no longer exists
#define TIMER_FREQ_HZ (XPAR_CPU_CORE_CLOCK_FREQ_HZ / 2) // 650,000,000 / 2 -> 325,000,000

// divide by two explanation: (https://support.xilinx.com/s/question/0D54U00006VHGRGSA5/xscutimer-with-interrupt-timerloadvalue?language=en_US)
// AMD: 
// - XSCUTimer is APU private timer.​ From UG585 Ch8, we know that this timer is clocked at 1/2 of CPU frequency.
// - "Each Cortex-A9 processor has its own private 32-bit timer and 32-bit watchdog timer."
// - "Both processors share a global 64-bit timer. These timers are always clocked at 1/2 of the CPU frequency (CPU_3x2x)."

/* ------------------------------------------------------------ */
/*					Procedure Declarations						*/
/* ------------------------------------------------------------ */

//int TimerInitialize(u16 TimerDeviceId);
int TimerInitialize(XScuTimer *TimerInstancePtr, UINTPTR BaseAddress);
void TimerDelay(u32 uSDelay);

/* ------------------------------------------------------------ */

/************************************************************************/


#endif /* TIMER_H_ */
