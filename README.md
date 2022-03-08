# AHB lite Slave Verification Project

## Documentation



https://www.edaplayground.com/x/bRMm



## Transaction

The transaction class has listed all stimuli created as randomizable logic. They can be randomized in the scope where they are created.
Default values are set to what we could do in a reset transaction.
Randomizable values are subject to constraints defined in the constraint block. It also has a function to print transactions wherever/whenever needed.

### Addressable points:

Q: Can I run predefined sequences? (e.g. reset sequence, random write sequence, random read/write bursts, a directed test)
A: predef_sequence in the class constructor of the generator, with a default value of 0 can be used to send the required sequence. The sequence can be set to:
0: for default (completely randomized with no constraints defined outside of transaction
1: for random transactions with just write (hwrite=1’b1)
2: for random transactions with just read (hwrite=1’b0)
3: for random transactions with no constraint on read/write but is burst (trans=2’b11)
Q: Can I debug easily if my test fails?
A: This point is not covered yet!
Q: Do I need one or multiple transactions for bursts?
A: We need multiple transactions created in the generator and sent to the driver for bursts. But no additional configuration has to be made. Whenever the burst comes up, a separate routing is followed where the first transaction is manually set to NONSEQ, and the rest of the burst with SEQ in transfer type.

## Generator

The generator class contains a transaction class which is randomized and sent to the driver once an instance is created. It also obtains a handle of a mailbox that it shares with the driver.
Another important feature of generator is to handle the different types of burst types. When the transfer type is SEQuential, and apart from the SINGLE burst type, we need to send multiple transactions to the driver to send the whole burst.It should have a proper starting NONSEQ transaction followed by the SEQ ones for the rest of the burst.
Another important job of a generator is to send only the set number of transactions which is obtained in the class constructor from the environment it is declared in. So, when there is a burst, there is a chance that total number of transactions would exceed the set limit, and it would hamper the proper finishing of the rest of simulation because the rest of  the components of environment (i.e. driver, monitor, and scoreboard) won’t know how many transactions to process. Therefore, a burst is sent only if the total number of transactions are not exceeded.

### Addressable points:

Q: How to control how many transactions get generated?
A: Number of transactions is set in test program where the no. is passed on to all parts of an environment and not just the generator.
Q: Sometimes random transactions are not needed. How do I generate non-random transactions when required?
A: NO, but a task needs to be added for this purpose in the transaction class or generator class.

## Driver

A driver has a proper address and data phase. So when it gets a transaction from the generator, it applies the stimuli in the address phase, and waits for the next clocking event. Upon the next clocking event (which happens on the positive clock edge of the main clock) the data is applied and the loop continues.
Driver drives after the environment has used its reset routine in pre_test. The reset routing waits for the reset signal from the testbench and resets the DUT.
Driver drives for the set number of transactions.

### Addressable points:

Q: Are the interface signals driven according to the spec?
A: YES
Q: Does the transaction have proper address/data Phases?
A: YES
Q: Do I need to sample inputs to decide whether to drive outputs or not on the next clocking event?
A: NOT YET



## Monitor

Upon the simultaneous start of the simulation environment, the monitor starts reading transactions from the interface from the second clock edge so that the first reset is ignored.
Monitor reads the address phase and samples the read/write data in the data phase which is packed into a single transaction and sent to the scoreboard.

### Addressable points:

Q: Are the interface signals sampled according to the spec?
A: YES
Q: Does the transaction have proper address/data Phases?
A: YES



## Scoreboard

Scoreboard is the component where data written to the DUT is compared with the data read from it. Whenever there is a write transaction, data is also written to scoreboard memory which is a (virtual) copy of DUT’s memory.
The reset states of both DUT and scoreboard’s memory are set to the same values, so that all randomly ordered read/write transactions are performed on the same initial set of data.

### Addressable points:

Q: Does the scoreboard implement proper endianness?
A: YES
Q: How to change endianness if required?
A: A variable (type bit) named endianness switches between the two. By default it is 0. It can be manually changed by editing in the code, and be sent through the class constructor. Again, in the constructor it is set to 0 (i.e. little endian) by default.
Q: How to not compare reset values and to compare only those memory locations which have already been written?
A: Using an associative array as the data structure of our scoreboard memory can make sure that only locations written to should be read.
Q: Should scoreboard memory be static or dynamic?
A: Dynamic memory is better than static memory due to the reason mentioned in the previous question’s answer.

## Environment

The environment class contains all generator, driver, monitor, scoreboard classes along with two mailboxes, and an interface sent from the test program. Processes are run simultaneously using fork/join/join_any for proper flow of execution.
Sequence can be set by setting the predef_sequence to value (0:3) detail of which is mentioned Transaction’s Addressable Points.


## Minute Change
To add a covergroup to the environment, a class is defined that contains all the relevant bins for relevant coverpoints. The class is created in the testbench where the interface is also passed to it, so that the data can be sampled on the main clock (clk’s) positive edge.

