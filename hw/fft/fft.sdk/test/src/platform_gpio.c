/*
 * Copyright (c) 2007 Xilinx, Inc.  All rights reserved.
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

#include "platform_gpio.h"
#include "xparameters.h"
#include "xgpio.h"

static XGpio gpio_leds;
static XGpio_Config *gpio_leds_config;

void platform_init_gpios()
{
	int status;

	gpio_leds_config = XGpio_LookupConfig(XPAR_AXI_GPIO_0_DEVICE_ID);
	status = XGpio_CfgInitialize(&gpio_leds, gpio_leds_config, gpio_leds_config->BaseAddress);

	if (status != XST_SUCCESS)
	{
		xil_printf("Unable to initialize LEDs\n\r");
		return;
	}

	XGpio_SetDataDirection(&gpio_leds, 1, 0xff);
	XGpio_DiscreteWrite(&gpio_leds, 1, 0x00);

}


void set_led(int n)
{
	if (n < 0 || n > 7) return;

	XGpio_DiscreteSet(&gpio_leds, 1, (0x1 >> n));
}

void clear_led(int n)
{
	if (n < 0 || n > 7) return;

	XGpio_DiscreteClear(&gpio_leds, 1, (0x1 >> n));
}
