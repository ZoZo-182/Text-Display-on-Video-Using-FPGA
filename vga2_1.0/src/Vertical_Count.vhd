----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/09/2024 02:58:25 PM
-- Design Name: 
-- Module Name: Horizontal_count - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity Vertical_count is
    port(
        Clock_in_25Mhz: in std_logic;
        Vertical_Sync_En: in std_logic;
        Vertical_count_value : out unsigned(9 downto 0)
    
    );
end Vertical_count;

architecture Behavioral of Vertical_count is
----------------------------------------------------------------------------------

--Signals--
signal V_sync_value: unsigned(9 downto 0); --524 == x"020C"



begin

Vertical_count_value <= V_sync_value;

MainVProcess: process(Clock_in_25Mhz,Vertical_Sync_En)
begin
    if rising_edge(Clock_in_25Mhz) and Vertical_Sync_En = '1' then      --Checks for signal from Horizontal Counter
        if(V_sync_value < 524) then                 --If H_sync_value < 799 then add 1 else reset back to 0
             V_sync_value <= V_sync_value + 1;
--             EN_V_sync_counter <= '0';                  
        else
             V_sync_value <= (others => '0');
--             EN_V_sync_counter <= '1';                  --Toggles V_sync channel to +1
        end if;
    end if;
end process;


end Behavioral;
