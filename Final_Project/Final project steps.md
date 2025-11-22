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







## 2\. UART Communication with Computer:

#### 

##### 2.1 Basic UART Test via Chu's main\_sampler-







#### 2.2 UART Understanding-

Read book and summarize





##### 2.3 Receiving from Computer and Displaying in ASCII on Seven Segment Display-





2.3.1 Test Program-













## 3\. Morse Code Logic:

























