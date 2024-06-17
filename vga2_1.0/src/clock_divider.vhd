library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
  
entity Clock_Divider is
port ( 
    clk : in std_logic;
    clock_out_25Mhz: out std_logic);
end Clock_Divider;
  
architecture bhv of Clock_Divider is

signal count: integer range 0 to 2 :=0;  -- Count == 1 means 25Mhz clock;
signal tmp : std_logic := '1';

  
begin
  
process(clk)
begin

    if rising_edge(clk)then
        count <=count+1;
        if (count = 1) then
            tmp <= NOT tmp;
            count <= 1;
            clock_out_25Mhz <= tmp;
        end if;
    end if;
    

end process;


end bhv;
