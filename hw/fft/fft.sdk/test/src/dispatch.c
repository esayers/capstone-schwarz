/*
 * Copyright (c) 2009 Xilinx, Inc.  All rights reserved.
 *
 * Xilinx, Inc.
 * XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" AS A
 * COURTESY TO YOU.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
 * ONE POSSIBLE   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR
 * STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION
 * IS FREE FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE
 * FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.
 * XILINX EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO
 * THE ADEQUACY OF THE IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO
 * ANY WARRANTIES OR REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE
 * FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.
 *
 */

#include "lwip/inet.h"
#include "lwip/ip_addr.h"
#include "lwip/sys.h"

#include "config_apps.h"
#ifdef __arm__
#include "xil_printf.h"
#endif


void print_echo_app_header();


void
print_headers()
{
    xil_printf("\r\n");
    xil_printf("%20s %6s %s\r\n", "Server", "Port", "Connect With..");
    xil_printf("%20s %6s %s\r\n", "--------------------", "------", "--------------------");

    if (INCLUDE_ECHO_SERVER)
        print_echo_app_header();

    xil_printf("\r\n");
}

void echo_application_thread(void *);

void
launch_app_threads()
{
    /* start echo server thread */
    if (INCLUDE_ECHO_SERVER)
        sys_thread_new("echod", echo_application_thread, 0,
            THREAD_STACKSIZE,
            DEFAULT_THREAD_PRIO);
}
