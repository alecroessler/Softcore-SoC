Final project steps SoC





mmi and bit are in final\_app\_vitis -> \_ide -> bitstream





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





##### 1.3 Creating short and long pulses for Morse Code-

Build off of the function from Chu's main sampler cpp file for this. Understand it and adapt to standard Morse Code durations. This will not include the Morse Code logic yet, just generated short and long pulses that play to the speaker.





## 2\. UART Communication with Computer:

#### 

##### 2.1 Basic UART Test via Chu's main\_sampler-







#### 2.2 UART Understanding-

Read book and summarize





##### 2.3 Receiving from Computer and Displaying in ASCII on Seven Segment Display-





###### 2.3.1 Test Program-





##### 2.4 Storage Buffer for Characters while Morse Logic Plays-



I plan on sending a message to the computer over UART that says "Enter you Morse Code message using alphanumeric characters, up to 8". Then after the user inputs their message and presses enter, the message is stored on the processor/ hardware. Then this gets sent to the morse code logic where it plays one character at a time. 





## 3\. Message Display on Seven Segment Displays-

I also want to incorporate the sseg file from Chu to display the entire message the 8 seven segment displays and the character that's being sent i want to flash it. I would like to only have this as a hardware component with a case statement to determine which seven segment output to show and somehow work in a counter at like 200 ms on 50 ms off or something that flashes the current transmitting character.



3.2 Testing sseg mux (slot 8)-



3.1 Modifying Slot 8 for Flash Mask-

In order to flash the corresponding transmitting character, we would need to alter the time in which is delayed for cycling through each seven segment. The easiest way would be to bypass all hardware and implement it on the software side. However, inputting time delays in software will affect the timing needed for the morse code sound transmission that is happening concurrently. The solution is to use what we did in earlier labs to write to a hardware register from software. The software will know which of the characters is currently being played using the morse code / ddfs system and can convert that to a 8 bit vector that has a 1 for the position of the seven segment that is being played and will thus need to flash. We can write this to a register in a new slot, example slot 4 as I did on lab3. Alternatively we can keep the slot 8 compact and use its register using addr, etc. Address 00 write characters as currently done then address 01 is responsible for the flash mask.





## 4\. Morse Code Logic:







## 5\. Output Speaker and Amplifier:





















