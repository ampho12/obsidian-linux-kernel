


# Keywords


## Package

```vhdl
package logic_pkg is
  constant DEFAULT_DELAY : time := 10 ns;
  function nand_func(a, b : std_logic) return std_logic;
end package;

package body logic_pkg is
  function nand_func(a, b : std_logic) return std_logic is
  begin
    return not (a and b);
  end function;
end package body;

```

can be used as
```vhdl
library work;
use work.logic_pkg.all;

```


## Entity

defines the the interface for the project

### Reusing Entities

Entities live in a library. E.g.

say we have entity half_adder in the work tree

```vhdl
entity half_adder is
  port (
    a, b : in  std_logic;
    s    : out std_logic;
    c    : out std_logic
  );
end entity;

architecture rtl of half_adder is
begin
  s <= a xor b;
  c <= a and b;
end architecture;
```


We can create a full adder as
```vhdl
entity full_adder is
  port (
    a, b, cin : in  std_logic;
    s, cout   : out std_logic
  );
end entity;

architecture structural of full_adder is
  signal s1, c1, c2 : std_logic;
begin
  -- instantiate two half adders
  ha1: entity work.half_adder(rtl)
    port map (a => a, b => b, s => s1, c => c1);

  ha2: entity work.half_adder(rtl)
    port map (a => s1, b => cin, s => s, c => c2);

  cout <= c1 or c2;
end architecture;
```


### Port

Each line defines a physical input/output line which can be multibit or single bit

e.g.

```vhdl

port (
    leds        : out bit_vector(7 downto 0); -- 8 leds
    switches    : in  bit_vector(4 downto 0); -- 4 switches
    
    bus_data    : inout bit(31 downto 0); -- 32 input / output lines for bus
    bus_clk     : in bit
)
```




## Architecture


Defines the internal working of the entity, like the implementation of the entity. An entity must have at least one architecture, but can have more than 1.


```vhdl
architecture rtl of blinker is
    signal counter : integer := 0;
    signal cur_state : bit := '0';
    procedure reset is
    begin
        integer: = 1;
    end procedure;
begin
end architecture;
```

Architecture blocks can have procedures before the begin block

> Note that signals in the port are also accessible inside

we can have combinational logic outisde processes


### Others

This keyword is catch all for array types (referes to all remainig elements)

```vhdl
signal ctrl : std_logic_vector(3 downto 0);

ctrl <= (0 => '1', others => '0');  -- ctrl = "0001"
```

### Processes

An architecture has one or more processes. Each process is driven by a signal. 

```vhdl
architecture rtl of my_component is
    -- ...
begin
    
    process(switch_0)
    begin
       -- ... 
    end process;
    
    process (switch_1, switch_2)
    -- ...
    end process;
    
    -- General syntax
    process (<comma separated sensitivity list>)
    -- ..
    end process
```

a process is triggered whenever the input signal(s) change.

Think of the state of the circuit as the values of each signal. (i.e asserted or not asserted). The state remains active until its changed again (i.e state is active for a level, not an edge)

The process block triggers whenever a signal in its sensitivity list changes. Once this happens, we either
1. change the state immediately (combinational logic). This is the default until sequential logic is inferred.
2. schedule a change of state (sequential logic). This schedule takes effect as follows
    1. In simulation, it is at the end of the process block after the process suspends (this time period is called delta cycle).
    2. In synethesis, this corresponds to wiring that drives the D input a flip-flop and will update the output signal Q at the active clock edge. This is same as circuit level behavior with a master-slave D-flip flop.
    3. Circuit level, it is implemented as the master-slave latch. When the current rising edge occured, the master latch entered opaque state and there is no change to the stored value. Then the falling edge occurs and the master latch registers the update but the slave latch is opaque. At the next edge, the master latch becomes opaque and the slave latch becomes transparent. 


By default, signal assignments in a process are interpreted as combinational logic unless the code structure makes it clear that they should be sequential registers.
- Combinational logic is inferred when outputs are defined purely as a function of current inputs (no edge checks, all paths covered).
- Sequential logic (flip-flops) is inferred only when assignments are explicitly inside a clock edge condition (e.g. if rising_edge(clk) then).
- Latches are inferred when assignments depend on a level-sensitive condition but are not covered in all cases.

To make dual edge logic, it's hard to infer it directly from process blocks and quartus will fail to compile it. Instead, we use DDR ip blocks directly.

# Hardware


## Latches

Latches have two states

1. Transparent (open): behaves like a wire, in that output = input.
2. Opaque (closed): behaves like a storage element where the output is the input that was latched at the time of closing. Changing the input of an opaque latch doesn't change the output.
# Literals

## Bit

Can take values `'0'` or `'1'` not `0` or `1` (the latter 2 are integers, not bit signals)


## Signals
These are wires, registers, latches

## Variables
These exist only inside a process and 


# Library

A library in vhdl is is a named collection of design units (entities, architectures, packages)

Every design unit that is compiled ALWAYS ends up in a library. The default libarary is called `work`.


## Using a Library

1. Declare the library that will be used
```vhdl
library ieee;
```
2. import each module
```vhdl
-- use <libarary-name>.<package-name>.<entities and architectures>
use ieee.std_logic_1164.all;
```

the `library std;` is always imported and has things like `bit, boolean, integer, character`.



## Creating a Library

Create source files with the needed packages.

In quartus, it is cleaner to put these into a directory and then go to 

```
Assignments -> Settings -> Compiler Settings -> VHDL Input 
```

Here we can specify which file goes into which library.


compile everything in that directory into a library. Quartus needs to be told a compile a library different than work.




# Best Practices

Within processes, we can do something like this
```vhdl
process(clk)
begin
    if clk = '1' then
        counter <= counter + 1;
    end if;
end process;
```

This would infer a register clocked by `clk`. However this is discouraged because if someone adds a new signal to the sensitivity list, we would now also edge trigger on that

so our actual logic would look like

```vhdl
if clk = '1' and (clk event or any other signal event)
```

therefore we would update whenever another signal changes but clock didn't change as was 1



