#include "chu_init.h"
#include "gpio_cores.h"
#include "sseg_core.h"
#include "ddfs_core.h"
#include "morse.h"

SsegCore sseg(get_slot_addr(BRIDGE_BASE, S8_SSEG));
DdfsCore ddfs(get_slot_addr(BRIDGE_BASE, S12_DDFS));
const int FREQ = 600;
morse morse_player(&ddfs, &sseg, FREQ); 

int get_user_message(char *buffer) {
    char c;
    int idx = 0;
    int data;
    
    // 1. Initial Setup
    sseg.clear_all();               
    uart.disp("\r\nEnter Message (Max 8 chars, Only 0-9 A-Z a-z or space): "); 

    // 2. Input 
    while(1) {
        data = uart.rx_byte();
        if (data != -1) {
            c = static_cast<char>(data);
            // Convert lowercase → uppercase
            if (c >= 'a' && c <= 'z')
                c = c - 'a' + 'A';

            // Case A: Enter Key 
            if (c == '\r' || c == '\n') {
                buffer[idx] = '\0';   
                uart.disp("\r\n");
                return idx;           
            }
            
            // Case B: Backspace 
            else if (c == '\b' || c == 0x7f) {
                if (idx > 0) {
                    idx--;            
                    buffer[idx] = ' '; // 
                    sseg.write_string(0, buffer); 
                    uart.tx_byte('\b');
                    uart.tx_byte(' ');
                    uart.tx_byte('\b');
                }
            }
            
            // Case C: Normal Character 
            else if (idx < 8) {       
                if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || 
                    (c >= '0' && c <= '9') || (c == ' ')) 
                {
                    buffer[idx] = c;     
                    idx++;                
                    buffer[idx] = '\0';  
                    sseg.write_string(0, buffer); 
                    uart.tx_byte(c);
                }
            }
        }
    }
}

int main() {
    char message[64];  // Allow longer messages
    int len;

    while (1) {
        // 1. Get message from user
        len = get_user_message(message); 
        if (len == 0) continue;  // Skip rest if empty message

        // 2. Display message on 7-segment
        sseg.write_string(0, message);
        sleep_ms(200);

        // 3. Play message as Encoded Morse Code
        morse_player.play_message(message);

    } //while
} //main



