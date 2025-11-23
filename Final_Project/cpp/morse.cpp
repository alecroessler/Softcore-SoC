#include "morse.h" 
#include "chu_init.h"      
#include "ddfs_core.h"

// Constructor
morse::morse(DdfsCore *ddfs_core, int freq) {
    ddfs_p = ddfs_core;
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

void morse::play_sos_test(){
    // S 
    play_dit();
    play_dit();
    play_dit();
    play_letter_space(); 
    // O 
    play_dah();
    play_dah();
    play_dah();
    play_letter_space(); 
    // S 
    play_dit();
    play_dit();
    play_dit();
}