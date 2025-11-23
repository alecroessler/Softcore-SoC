#include "ddfs_core.h"


#define DIT_MS 100
#define DAH_MS (3 * DIT_MS)
#define SYMBOL_SPACE_MS DIT_MS // Space between parts of same letter
#define LETTER_SPACE_MS (3 * DIT_MS) // Space between letters

class morse {
private:
    DdfsCore *ddfs_p;
    void ddfs_setup(int freq);
    void play_pulse(int duration_ms);
    void play_dit();
    void play_dah();
    void play_letter_space();
    
public:
    morse(DdfsCore *ddfs_core, int freq);
    void play_sos_test();
};