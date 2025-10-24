

# Two Blinks

Consider this blink

```vhdl
entity blink is
    port (
        clock_input : in bit;
        led_out     : out bit
    );
end entity;

architecture rtl of blink is 
    signal counter : integer := 0;
    signal led_reg : bit := '0';
begin

    led_out <= led_reg;


    process (clock_input)
    begin
        if clock_input'event and clock_input = '1' then
            if counter = 24_999_999 then
                led_reg <= not led_reg;
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
end architecture;
```

![[Screenshot from 2025-09-06 04-22-00.png]]


But this version produces something strange

```vhdl
entity blink is
    port (
        clock_input : in bit;
        led_out     : out bit
    );
end entity;

architecture rtl of blink is 
    signal counter : integer := 0;
    signal led_reg : bit := '0';
begin

    led_out <= led_reg;


    process (clock_input)
    begin
        if clock_input'event and clock_input = '1' then
                counter <= counter + 1;
        end if;

        if counter = 24_999_999 then
            led_reg <= not led_reg;
            counter <= 0;
        end if;
    end process;
end architecture;

```


![[Screenshot from 2025-09-06 04-35-31.png]]

To understand this, recall that state of the circuit is the set of states of all signals. The process block changes the state (combo or sequential) whenever the sensitivity list experiences a change.

In the 'strange case', as soon as `clock_input` changes, we see an async/deferred update to counter's value which is current signal + 1. This is because between two rising edges, there is a falling edge and we can model 'update once process block ends logically' onto the physical circuit by using the falling edge + d-flip-flop.

we also see a sync update to the counters state if it is `24_999_999`. In this case, we immediately flip the state of the led (i.e latch `not led_reg`) and also drive counter to zero.
This is because the compare is only true for a tiny propagation window (on the order of nanoseconds), not for a full clock cycle

As a result, the deferred update will use 0 as its input, not `24_999_999` and the led will will latch to `not led` this will be active however for the entire duration equal0 is asserted high, which is almost 0. So we don't see any 

