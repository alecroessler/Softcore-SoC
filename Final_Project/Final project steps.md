Final project steps SoC





mmi and bit are in final\_app\_vitis -> \_ide -> bitstream



FILES MODIFIED:

mmio\_sys\_sampler.sv

main\_sampler.cpp

sseg.h

sseg.cpp

morse.h

morse.cpp





# **Outline of work:**

1. ## DDFS Sound Core and adaptation to Morse Code:



Talk about overview of choosing DDFS core and what it is.



##### 1.1 Initial Testing of Sound (DDFS CORE) with Chu's Test System-



First, i wanted to ensure i could get the sound output to work as searching online yielded discussions that this may prove to be difficult. However, I noticed that Chu did have a sound core called the ddfs core and covered it in his textbook



Files I needed for ddfs core:

**chu\_ddfs\_core.sv** (wrapper)

**ddfs.sv** (handles frequency calculations)

**ds\_1bit\_dac.sv** (converts 16 bit digital sine wave into 1 bit PDM signal for headphone jack)

**sin\_rom.sv** (stores shape of sine wave)

**sin\_table.txt** (data file loaded into rom)

**ddfs\_core.h** (defines ddfs core class)

**ddfs\_core.cpp** (implements logic software driver core)

**mmio\_sys\_sampler.sv** (instantiate ddfs core at slot 12 and modified assigning read registers to 0 for unused slots, also deleting all spi i2c etc for testing)

**mcs\_top\_sampler.sv** (connects pdm output wire to top-level port audio\_pdm

**Nexys4\_DDR\_chu.xdc** (constraints file)



The first testing included using Chus main sampler system to run his ddfs test function. Modifed mmio\_sys\_sampler.sv for slot 12 instantiation. This creates a sine wave mimicking a siren and replays 5 times. I initially had trouble getting the sin\_rom.sv file to successfully load in the sin\_table.txt in Vivado as I tried to make it a .mem file instead of .txt. I was able to load it in eventually as txt and the test worked flawlessly. Remember to put in there have to change path of **/inst** to delete it to find CPU for mmi file.





##### 1.2 Understanding DDFS Core-

Read book and summarize chapter





##### 1.3 Creating pulse for Morse Code-

Build off of the function from Chu's main sampler cpp file for this. Understand it and adapt to standard Morse Code durations. This will not include the Morse Code logic yet, just generated pulses that play to the speaker. Talk about setting constant carrier frequency and relate to section 1.2





###### 1.3.1 Software Test-





###### **Software (main\_sampler.cpp)-**

const int FREQ = 600;

morse morse\_player(\&ddfs, FREQ); 



int main() {

&nbsp;  

&nbsp;  while (1) {

&nbsp;      morse\_player.play\_sos\_test();

&nbsp;      sleep\_ms(5000);

&nbsp;  } //while

} //main





###### **morse.h-**

\#include "ddfs\_core.h"



\#define DIT\_MS 100

\#define DAH\_MS (3 \* DIT\_MS)

\#define SYMBOL\_SPACE\_MS DIT\_MS // Space between parts of same letter

\#define LETTER\_SPACE\_MS (3 \* DIT\_MS) // Space between letters



class morse {

private:

&nbsp;   DdfsCore \*ddfs\_p;

&nbsp;   void ddfs\_setup(int freq);

&nbsp;   void play\_pulse(int duration\_ms);

&nbsp;   void play\_dit();

&nbsp;   void play\_dah();

&nbsp;   void play\_letter\_space();

&nbsp;   

public:

&nbsp;   morse(DdfsCore \*ddfs\_core, int freq);

&nbsp;   void play\_sos\_test();

};



###### **morse.cpp-**

\#include "morse.h" 

\#include "chu\_init.h"      

\#include "ddfs\_core.h"



// Constructor

morse::morse(DdfsCore \*ddfs\_core, int freq) {

&nbsp;   ddfs\_p = ddfs\_core;

&nbsp;   ddfs\_setup(freq);

}



// Set starting default values

void morse::ddfs\_setup(int freq){

&nbsp;   ddfs\_p->set\_env\_source(0); 

&nbsp;   ddfs\_p->set\_carrier\_freq(freq); 

&nbsp;   ddfs\_p->set\_offset\_freq(0); // No offset

&nbsp;   ddfs\_p->set\_env(0.0); // Start silent

}



void morse::play\_pulse(int duration\_ms) {

&nbsp;   ddfs\_p->set\_env(1.0);

&nbsp;   sleep\_ms(duration\_ms);

&nbsp;   ddfs\_p->set\_env(0.0);

&nbsp;   sleep\_ms(SYMBOL\_SPACE\_MS);

}



// Helper functions

void morse::play\_dit() {

&nbsp;   play\_pulse(DIT\_MS);

}

void morse::play\_dah() {

&nbsp;   play\_pulse(DAH\_MS);

}

void morse::play\_letter\_space() {

&nbsp;   sleep\_ms(LETTER\_SPACE\_MS);

}



void morse::play\_sos\_test(){

&nbsp;   // S 

&nbsp;   play\_dit();

&nbsp;   play\_dit();

&nbsp;   play\_dit();

&nbsp;   play\_letter\_space(); 

&nbsp;   // O 

&nbsp;   play\_dah();

&nbsp;   play\_dah();

&nbsp;   play\_dah();

&nbsp;   play\_letter\_space(); 

&nbsp;   // S 

&nbsp;   play\_dit();

&nbsp;   play\_dit();

&nbsp;   play\_dit();

}







## 2\. UART Communication with Computer:

#### 

##### 2.1 Basic UART Test via Chu's main\_sampler-

Chu's function-

void uart\_check() {

&nbsp;  static int loop = 0;



&nbsp;  uart.disp("uart test #");

&nbsp;  uart.disp(loop);

&nbsp;  uart.disp("\\n\\r");

&nbsp;  loop++;

}



main-

int main() {

&nbsp;  while (1) {

&nbsp;      uart\_check();

&nbsp;  } //while

} //main



Using mobaxterm as I used it for massively parallel programming course and am familiar with it along with being a better GUI than putty

in mobaxterm:

&nbsp;	1. Click session

&nbsp;	2. Serial

&nbsp;	3. Identify COM Port (for me it was com4)

&nbsp;	4. Set baud rate (9600 from Chu's default setting in uart\_core.cpp)



successfully saw "uart test #1" printed and looping

NOTE: Do not need to explicity construct UART core as Chu already does this in chu\_init.h and is thus globally defined







#### 2.2 UART Understanding-

Read book and summarize, talk about receiving bits





##### 2.3 Receiving from Computer and Displaying in ASCII on Seven Segment Display-

###### **sseg.h-**

void write\_string(int pos, const char \*str);

void clear\_all();

uint8\_t ascii\_to\_7seg(char c); // private





###### **sseg.cpp-**

uint8\_t SsegCore::ascii\_to\_7seg(char c)

{

&nbsp;   // Convert lowercase → uppercase

&nbsp;   if (c >= 'a' \&\& c <= 'z')

&nbsp;       c = c - 'a' + 'A';

&nbsp;   switch (c)

&nbsp;   {

&nbsp;       case '0': return 0xC0;

&nbsp;       case '1': return 0xF9;

&nbsp;       case '2': return 0xA4;

&nbsp;       case '3': return 0xB0;

&nbsp;       case '4': return 0x99;

&nbsp;       case '5': return 0x92;

&nbsp;       case '6': return 0x82;

&nbsp;       case '7': return 0xF8;

&nbsp;       case '8': return 0x80;

&nbsp;       case '9': return 0x90;

&nbsp;       case 'A': return 0x88;

&nbsp;       case 'B': return 0x83;

&nbsp;       case 'C': return 0xC6;

&nbsp;       case 'D': return 0xA1;

&nbsp;       case 'E': return 0x86;

&nbsp;       case 'F': return 0x8E;

&nbsp;       case 'G': return 0xC2;

&nbsp;       case 'H': return 0x89;

&nbsp;       case 'I': return 0xF9;   

&nbsp;       case 'J': return 0xF1;

&nbsp;       case 'K': return 0x8A;  

&nbsp;       case 'L': return 0xC7;

&nbsp;       case 'M': return 0xAA;   

&nbsp;       case 'N': return 0xAB;   

&nbsp;       case 'O': return 0xC0;

&nbsp;       case 'P': return 0x8C;

&nbsp;       case 'Q': return 0x98;   

&nbsp;       case 'R': return 0xAF;   

&nbsp;       case 'S': return 0x92; 

&nbsp;       case 'T': return 0x87;

&nbsp;       case 'U': return 0xC1;

&nbsp;       case 'V': return 0xE3;   

&nbsp;       case 'W': return 0xB1;   

&nbsp;       case 'X': return 0x89;   

&nbsp;       case 'Y': return 0x91;

&nbsp;       case 'Z': return 0xA4;  



&nbsp;       case '-': return 0xBF;

&nbsp;       case ' ': return 0xFF;   

&nbsp;       default:  return 0xFF;  

&nbsp;   }

}



void SsegCore::clear\_all()

{

&nbsp;   for (int i = 0; i < 8; i++)

&nbsp;       write\_1ptn(0xFF, i);



&nbsp;   set\_dp(0x00);   // turn all decimal points off

}





void SsegCore::write\_string(int pos, const char \*str)

{

&nbsp;   uint8\_t buf\[8];



&nbsp;   // start with all blanks

&nbsp;   for (int i = 0; i < 8; i++)

&nbsp;       buf\[i] = 0xFF;



&nbsp;   int i = 0;

&nbsp;   while (str\[i] != '\\0' \&\& (pos + i) < 8)

&nbsp;   {

&nbsp;       buf\[7 - (pos + i)] = ascii\_to\_7seg(str\[i]);

&nbsp;       i++;

&nbsp;   }



&nbsp;   write\_8ptn(buf);

}





###### 2.3.1 Test Program Show String-

###### **main\_sampler\_test.cpp-**

int main() {



&nbsp;  while (1) {

&nbsp;      sseg.clear\_all();

&nbsp;      sseg.write\_string(0, "HELLO");

&nbsp;  } //while

} //main











###### 2.3.2 Show User Input Text Via UART-

###### **main\_sampler\_test.cpp-**

int get\_user\_message(char \*buffer) {

&nbsp;   char c;

&nbsp;   int idx = 0;

&nbsp;   int data;

&nbsp;   

&nbsp;   // 1. Initial Setup

&nbsp;   sseg.clear\_all();               

&nbsp;   uart.disp("\\r\\nEnter Message (Max 8 chars, Only 0-9 A-Z a-z or space): "); 



&nbsp;   // 2. Input 

&nbsp;   while(1) {

&nbsp;       data = uart.rx\_byte();

&nbsp;       if (data != -1) {

&nbsp;           c = static\_cast<char>(data);

&nbsp;           // Convert lowercase → uppercase

&nbsp;           if (c >= 'a' \&\& c <= 'z')

&nbsp;               c = c - 'a' + 'A';



&nbsp;           // Case A: Enter Key 

&nbsp;           if (c == '\\r' || c == '\\n') {

&nbsp;               buffer\[idx] = '\\0';   

&nbsp;               uart.disp("\\r\\n");

&nbsp;               return idx;           

&nbsp;           }

&nbsp;           

&nbsp;           // Case B: Backspace 

&nbsp;           else if (c == '\\b' || c == 0x7f) {

&nbsp;               if (idx > 0) {

&nbsp;                   idx--;            

&nbsp;                   buffer\[idx] = ' '; // 

&nbsp;                   sseg.write\_string(0, buffer); 

&nbsp;                   uart.tx\_byte('\\b');

&nbsp;                   uart.tx\_byte(' ');

&nbsp;                   uart.tx\_byte('\\b');

&nbsp;               }

&nbsp;           }

&nbsp;           

&nbsp;           // Case C: Normal Character 

&nbsp;           else if (idx < 8) {       

&nbsp;               if ((c >= 'a' \&\& c <= 'z') || (c >= 'A' \&\& c <= 'Z') || 

&nbsp;                   (c >= '0' \&\& c <= '9') || (c == ' ')) 

&nbsp;               {

&nbsp;                   buffer\[idx] = c;     

&nbsp;                   idx++;                

&nbsp;                   buffer\[idx] = '\\0';  

&nbsp;                   sseg.write\_string(0, buffer); 

&nbsp;                   uart.tx\_byte(c);

&nbsp;               }

&nbsp;           }

&nbsp;       }

&nbsp;   }

}



###### **Test Program-**

int main() {

&nbsp;   char message\[64];  // Allow longer messages

&nbsp;   int len;



&nbsp;   while (1) {

&nbsp;       // 1. Get message from user

&nbsp;       len = get\_user\_message(message); 

&nbsp;       if (len == 0) continue;  // Skip rest if empty message



&nbsp;       // 2. Display message on 7-segment

&nbsp;       sseg.write\_string(0, message);





&nbsp;       sleep\_ms(5000);

&nbsp;   } //while

} //main







##### 2.4 Storage Buffer for Characters while Morse Logic Plays-



I plan on sending a message to the computer over UART that says "Enter you Morse Code message using alphanumeric characters, up to 8". Then after the user inputs their message and presses enter, the message is stored on the processor/ hardware. Then this gets sent to the morse code logic where it plays one character at a time. 









## 3\. Morse Code Logic:

* Dit: 1 unit
* Dah: 3 units
* Intra-character space (the gap between dits and dahs within a character): 1 unit
* Inter-character space (the gap between the characters of a word): 3 units
* Word space (the gap between two words): 7 units



Use website here for calculating words per minute: [https://morsecode.world/international/timing/](https://morsecode.world/international/timing/)

Talk about the time unit I choose as a good balance.





Code:

1. Add play\_message function to morse class
   

void morse::play\_message(const char \*msg)

{

&nbsp;   for (int i = 0; i < 8 \&\& msg\[i] != '\\0'; i++) {

&nbsp;       char c = msg\[i];

&nbsp;       int idx = -1;



&nbsp;       if (c >= 'A' \&\& c <= 'Z') idx = c - 'A';      // letters

&nbsp;       else if (c >= '0' \&\& c <= '9') idx = 26 + (c - '0'); // digits

&nbsp;       else continue;  // skip unsupported characters



&nbsp;       const char \*morse\_code = MORSE\_TABLE\[idx];



&nbsp;       // Play each symbol in the letter

&nbsp;       for (int j = 0; morse\_code\[j] != '\\0'; j++) {

&nbsp;           if (morse\_code\[j] == '.') play\_dit();

&nbsp;           else if (morse\_code\[j] == '-') play\_dah();



&nbsp;           // short pause between symbols

&nbsp;           if (morse\_code\[j+1] != '\\0') sleep\_ms(SYMBOL\_SPACE\_MS);

&nbsp;       }



&nbsp;       // Space between letters

&nbsp;       play\_letter\_space();

&nbsp;   }

}



2\. Add Morse lookup table to morse.cpp



static const char\* MORSE\_TABLE\[36] = {

&nbsp;   ".-", "-...", "-.-.", "-..", ".", "..-.", "--.", "....", "..", ".---",  // A-J

&nbsp;   "-.-", ".-..", "--", "-.", "---", ".--.", "--.-", ".-.", "...", "-",     // K-T

&nbsp;   "..-", "...-", ".--", "-..-", "-.--", "--..",                            // U-Z

&nbsp;   "-----", ".----", "..---", "...--", "....-", ".....", "-....", "--...", "---..", "----." // 0-9

};





3\. Add main logic

morse\_player.play\_message(message);







## 4\. Message Display on Seven Segment Displays-

I also want to incorporate the sseg file from Chu to display the entire message the 8 seven segment displays and the character that's being sent i want to flash it. I would like to only have this as a hardware component with a case statement to determine which seven segment output to show and somehow work in a counter at like 200 ms on 50 ms off or something that flashes the current transmitting character.



3.2 Testing sseg mux (slot 8)-



3.1 Modifying Slot 8 for Flash Mask-

In order to flash the corresponding transmitting character, we would need to alter the time in which is delayed for cycling through each seven segment. The easiest way would be to bypass all hardware and implement it on the software side. However, inputting time delays in software will affect the timing needed for the morse code sound transmission that is happening concurrently. The solution is to use what we did in earlier labs to write to a hardware register from software. The software will know which of the characters is currently being played using the morse code / ddfs system and can convert that to a 8 bit vector that has a 1 for the position of the seven segment that is being played and will thus need to flash. We can write this to a register in a new slot, example slot 4 as I did on lab3. Alternatively we can keep the slot 8 compact and use its register using addr, etc. Address 00 write characters as currently done then address 01 is responsible for the flash mask.





Software Side:

sseg.h: To get private base\_addr

uint32\_t get\_base\_addr() const { return base\_addr; }



morse.h:

add sseg pointer to constructor and private data member



morse.cpp- offset is 2 becuase first register are used to disern which 4 7-segment chunk is being written to. 

io\_write(sseg\_p->get\_base\_addr(), 2, 7 - i); // Write led num to register 3







Hardware Side:

led\_mux8.sv-

Have access to 18 bit counter which uses 3 most significant bits or multiplexing seven segment displays which at bit 16 equals ~1600Hz. We want a notiable blink so we'll choose around 150ms or around 7 Hz. This means we'll need from formula 7Hz = 100 MHz / 2N -> N = 23.77 ~ 24

We only have an 18 bit counter so will have to extend to 24 and alter the 3 bits use for the normal multiplexing

\*\*\*\* MUST CHANGE CHU'S DEODING OF D0 AND D1 REGISTERS WITH WR\_DATA \*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*





add enable bit in separate register



# **ADD SUPPORT FOR SPACE !!!!!!!!!!!!!!!!!!!!!!!!!**

## 5\. Output Speaker and Amplifier:





















