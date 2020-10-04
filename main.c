

// XMC1100 XMC_Peripheral_Library GPIO_TOGGLE demo example,
//  modified to work with XMC2GO stick.

#include "xmc_gpio.h"

#define LED1 P1_1
#define LED2 P1_0

void SysTick_Handler(void);


int main(void)
{
  XMC_GPIO_SetMode(LED1, XMC_GPIO_MODE_OUTPUT_PUSH_PULL);
  XMC_GPIO_SetMode(LED2, XMC_GPIO_MODE_OUTPUT_PUSH_PULL);

  //Toggle one of the LEDs for an alternating blink pattern:
  XMC_GPIO_ToggleOutput(LED1);

  // Note: The XMC_GPIO_ToggleOutput() function is defined in
  // Libroot/XMCLib/inc/smc_gpio.h file...
  
  /* System timer configuration */
  SysTick_Config(SystemCoreClock >> 1);

  while(1)
  {
    /* Infinite loop */
  }
}



void SysTick_Handler(void)
{
  XMC_GPIO_ToggleOutput(LED1);
  XMC_GPIO_ToggleOutput(LED2);
}
