/*****************************************************************//**
 * @file main_sampler_test.cpp
 *
 * @brief Basic test of nexys4 ddr mmio cores
 *
 * @author p chu
 * @version v1.0: initial release
 *********************************************************************/

// #define _DEBUG
#include "chu_init.h"
#include "gpio_cores.h"
#include "sseg_core.h"
#include "ddfs_core.h"
#include "morse.h"


/**
 * uart transmits test line.
 * @note uart instance is declared as global variable in chu_io_basic.h
 */
void uart_check() {
   static int loop = 0;

   uart.disp("uart test #");
   uart.disp(loop);
   uart.disp("\n\r");
   loop++;
}

/**
 * Test pattern in 7-segment LEDs
 * @param sseg_p pointer to 7-seg LED instance
 */

void sseg_check(SsegCore *sseg_p) {
   int i, n;
   uint8_t dp;

   //turn off led
   for (i = 0; i < 8; i++) {
      sseg_p->write_1ptn(0xff, i);
   }
   //turn off all decimal points
   sseg_p->set_dp(0x00);

   // display 0x0 to 0xf in 4 epochs
   // upper 4  digits mirror the lower 4
   for (n = 0; n < 4; n++) {
      for (i = 0; i < 4; i++) {
         sseg_p->write_1ptn(sseg_p->h2s(i + n * 4), 3 - i);
         sseg_p->write_1ptn(sseg_p->h2s(i + n * 4), 7 - i);
         sleep_ms(300);
      } // for i
   }  // for n
      // shift a decimal point 4 times
   for (i = 0; i < 4; i++) {
      bit_set(dp, 3 - i);
      sseg_p->set_dp(1 << (3 - i));
      sleep_ms(300);
   }
   //turn off led
   for (i = 0; i < 8; i++) {
      sseg_p->write_1ptn(0xff, i);
   }
   //turn off all decimal points
   sseg_p->set_dp(0x00);

}



/**
 * play primary notes with ddfs
 * @param ddfs_p pointer to ddfs core
 * @note: music tempo is defined as beats of quarter-note per minute.
 *        60 bpm is 1 sec per quarter note
 * @note "click" sound due to abrupt stop of a note
 *
 */
void ddfs_check(DdfsCore *ddfs_p, GpoCore *led_p) {
   int i, j;
   float env;

   //vol = (float)sw.read_pin()/(float)(1<<16),
   ddfs_p->set_env_source(0);  // select envelop source
   ddfs_p->set_env(0.0);   // set volume
   sleep_ms(500);
   ddfs_p->set_env(1.0);   // set volume
   ddfs_p->set_carrier_freq(262);
   sleep_ms(2000);
   ddfs_p->set_env(0.0);   // set volume
   sleep_ms(2000);
   // volume control (attenuation)
   ddfs_p->set_env(0.0);   // set volume
   env = 1.0;
   for (i = 0; i < 1000; i++) {
      ddfs_p->set_env(env);
      sleep_ms(10);
      env = env / 1.0109; //1.0109**1024=2**16
   }
   // frequency modulation 635-912 800 - 2000 siren sound
   ddfs_p->set_env(1.0);   // set volume
   ddfs_p->set_carrier_freq(635);
   for (i = 0; i < 5; i++) {               // 10 cycles
      for (j = 0; j < 30; j++) {           // sweep 30 steps
         ddfs_p->set_offset_freq(j * 10);  // 10 Hz increment
         sleep_ms(25);
      } // end j loop
   } // end i loop
   ddfs_p->set_offset_freq(0);
   ddfs_p->set_env(0.0);   // set volume
   sleep_ms(1000);
}

SsegCore sseg(get_slot_addr(BRIDGE_BASE, S8_SSEG));
DdfsCore ddfs(get_slot_addr(BRIDGE_BASE, S12_DDFS));
const int FREQ = 600;
morse morse_player(&ddfs, FREQ); 

int main() {
   
   while (1) {
       morse_player.play_sos_test();
       sleep_ms(5000);
   } //while
} //main

