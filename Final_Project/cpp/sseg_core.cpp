/*****************************************************************//**
 * @file sseg_core.cpp
 *
 * @brief implementation of SsegCore class
 *
 * @author p chu
 * @version v1.0: initial release
 ********************************************************************/

#include "sseg_core.h"
#include "string.h"

SsegCore::SsegCore(uint32_t core_base_addr) {
   // pattern for "HI"; the order in array is reversed in 7-seg display
   // i.e., HI_PTN[0] is the leftmost led
   const uint8_t HI_PTN[]={0xff,0xf9,0x89,0xff,0xff,0xff,0xff,0xff};
   base_addr = core_base_addr;
   write_8ptn((uint8_t*) HI_PTN);
   set_dp(0x02);
}

SsegCore::~SsegCore() {
}
// not used

void SsegCore::write_led() {
   int i, p;
   uint32_t word = 0;

   // pack left 4 patterns into a 32-bit word
   // ptn_buf[0] is the leftmost led
   for (i = 0; i < 4; i++) {
      word = (word << 8) | ptn_buf[3 - i];
   }
   // incorporate decimal points (bit 7 of pattern)
   for (i = 0; i < 4; i++) {
      p = bit_read(dp, i);
      bit_write(word, 7 + 8 * i, p);
   }
   io_write(base_addr, DATA_LOW_REG, word);
   // pack right 4 patterns into a 32-bit word
   for (i = 0; i < 4; i++) {
      word = (word << 8) | ptn_buf[7 - i];
   }
   // incorporate decimal points
   for (i = 0; i < 4; i++) {
      p = bit_read(dp, 4 + i);
      bit_write(word, 7 + 8 * i, p);
   }
   io_write(base_addr, DATA_HIGH_REG, word);
}

void SsegCore::write_8ptn(uint8_t *ptn_array) {
   int i;

   for (i = 0; i < 8; i++) {
      ptn_buf[i] = *ptn_array;
      ptn_array++;
   }
   write_led();
}

void SsegCore::write_1ptn(uint8_t pattern, int pos) {
   ptn_buf[pos] = pattern;
   write_led();
}

// set decimal points,
// bits turn on the corresponding decimal points
void SsegCore::set_dp(uint8_t pt) {
   dp = ~pt;     // active low
   write_led();
}

// convert a hex digit to
uint8_t SsegCore::h2s(int hex) {
   /* active-low hex digit 7-seg patterns (0-9,a-f); MSB assigned to 1 */
   static const uint8_t PTN_TABLE[16] =
     {0xc0, 0xf9, 0xa4, 0xb0, 0x99, 0x92, 0x82, 0xf8, 0x80, 0x90, //0-9
      0x88, 0x83, 0xc6, 0xa1, 0x86, 0x8e };                       //a-f
   uint8_t ptn;

   if (hex < 16)
      ptn = PTN_TABLE[hex];
   else
      ptn = 0xff;
   return (ptn);
}


uint8_t SsegCore::ascii_to_7seg(char c)
{
    // Convert lowercase to uppercase
    if (c >= 'a' && c <= 'z')
        c = c - 'a' + 'A';
    switch (c)
    {
        case '0': return 0xC0;
        case '1': return 0xF9;
        case '2': return 0xA4;
        case '3': return 0xB0;
        case '4': return 0x99;
        case '5': return 0x92;
        case '6': return 0x82;
        case '7': return 0xF8;
        case '8': return 0x80;
        case '9': return 0x90;
        case 'A': return 0x88;
        case 'B': return 0x83;
        case 'C': return 0xC6;
        case 'D': return 0xA1;
        case 'E': return 0x86;
        case 'F': return 0x8E;
        case 'G': return 0xC2;
        case 'H': return 0x89;
        case 'I': return 0xF9;   
        case 'J': return 0xF1;
        case 'K': return 0x8A;  
        case 'L': return 0xC7;
        case 'M': return 0xAA;   
        case 'N': return 0xAB;   
        case 'O': return 0xC0;
        case 'P': return 0x8C;
        case 'Q': return 0x98;   
        case 'R': return 0xAF;   
        case 'S': return 0x92; 
        case 'T': return 0x87;
        case 'U': return 0xC1;
        case 'V': return 0xE3;   
        case 'W': return 0xB1;   
        case 'X': return 0x89;   
        case 'Y': return 0x91;
        case 'Z': return 0xA4;  

        case '-': return 0xBF;
        case ' ': return 0xFF;   
        default:  return 0xFF;  
    }
}

void SsegCore::clear_all()
{
    for (int i = 0; i < 8; i++)
        write_1ptn(0xFF, i);

    set_dp(0x00);   // turn all decimal points off
}


void SsegCore::write_string(int pos, const char *str)
{
    uint8_t buf[8];

    // start with all blanks
    for (int i = 0; i < 8; i++)
        buf[i] = 0xFF;

    int i = 0;
    while (str[i] != '\0' && (pos + i) < 8)
    {
        buf[7 - (pos + i)] = ascii_to_7seg(str[i]);
        i++;
    }

    write_8ptn(buf);
}


