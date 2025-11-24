#include "morse.h" 
#include "chu_init.h"      
#include "ddfs_core.h"

// Constructor
morse::morse(DdfsCore *ddfs_core, SsegCore *sseg_core, int freq) {
    ddfs_p = ddfs_core;
    sseg_p = sseg_core;
    ddfs_setup(freq);
}

// Set starting default values
void morse::ddfs_setup(int freq){
    ddfs_p->set_env_source(0); 
    ddfs_p->set_carrier_freq(freq); 
    ddfs_p->set_offset_freq(0); // No offset
    ddfs_p->set_env(0.0); // Start silent
}

void morse::play_pulse(int duration_ms) {
    ddfs_p->set_env(1.0);
    sleep_ms(duration_ms);
    ddfs_p->set_env(0.0);
    sleep_ms(SYMBOL_SPACE_MS);
}

// Helper functions
void morse::play_dit() {
    play_pulse(DIT_MS);
}
void morse::play_dah() {
    play_pulse(DAH_MS);
}
void morse::play_letter_space() {
    sleep_ms(LETTER_SPACE_MS);
}

static const char* MORSE_TABLE[36] = {
    ".-", "-...", "-.-.", "-..", ".", "..-.", "--.", "....", "..", ".---",  // A-J
    "-.-", ".-..", "--", "-.", "---", ".--.", "--.-", ".-.", "...", "-",     // K-T
    "..-", "...-", ".--", "-..-", "-.--", "--..",                            // U-Z
    "-----", ".----", "..---", "...--", "....-", ".....", "-....", "--...", "---..", "----." // 0-9
};


void morse::play_message(const char *msg)
{
    io_write(sseg_p->get_base_addr(), 2, 1);
    for (int i = 0; i < 8 && msg[i] != '\0'; i++) {

        io_write(sseg_p->get_base_addr(), 3, 7 - i); // Write led num to register 3

        char c = msg[i];
        int idx = -1;

        if (c >= 'A' && c <= 'Z') idx = c - 'A';      // letters
        else if (c >= '0' && c <= '9') idx = 26 + (c - '0'); // digits
        else continue;  // skip unsupported characters

        const char *morse_code = MORSE_TABLE[idx];

        // Play each symbol in the letter
        for (int j = 0; morse_code[j] != '\0'; j++) {
            if (morse_code[j] == '.') play_dit();
            else if (morse_code[j] == '-') play_dah();

            // short pause between symbols
            if (morse_code[j+1] != '\0') sleep_ms(SYMBOL_SPACE_MS);
        }

        // Space between letters
        play_letter_space();
    }
    io_write(sseg_p->get_base_addr(), 2, 0);
}


