--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use ieee.numeric_std.all;


--entity vga_sync is
--port (
--clk, reset      : in std_logic;
--I_CLK_50MHZ     : in std_logic;

--hsync, vsync    : out std_logic;
--XY_address : out std_logic_vector(15 downto 0);
--I_data : in std_logic_vector(7 downto 0);
--R : out std_logic_vector(3 downto 0);
--G : out std_logic_vector(3 downto 0);
--B : out std_logic_vector(3 downto 0)
--);            
--end vga_sync;

--architecture Behavioral of vga_sync is

--component Clock_Divider is
--port ( 
--    clk : in std_logic;
----    reset: in std_logic;
--    clock_out_25Mhz: out std_logic);
--end component;

--component Vertical_count is
--    port(
--        Clock_in_25Mhz: in std_logic;
--        Vertical_Sync_En: in std_logic;
--        Vertical_count_value : out unsigned(9 downto 0)
--    );
--end component;

--signal clock_25mhz : std_logic;
--signal H_sync_count:  unsigned(9 downto 0); --range 0 to 799 :=0; --
--signal V_sync_count:  unsigned(9 downto 0);-- range 0 to 524 :=0; --
--signal EN_V_sync_counter: std_logic;

--signal X_addr: unsigned(9 downto 0);
--signal Y_addr: unsigned(9 downto 0);


---- status signal
--signal video_on : std_logic;
--signal current_bit : std_logic;

--begin
--	XY_address <= std_logic_vector(to_unsigned((to_integer(Y_addr) * 80) + (to_integer(X_addr + 1) / 8), 16));
--    current_bit <= I_data(to_integer(X_addr) mod 8);

--R <= x"0" when (H_sync_count > 143 and H_sync_count < 784 and V_sync_count > 34 and V_sync_count < 515) and current_bit = '1'  else
--     x"0";         
--G <= x"F" when (H_sync_count > 143 and H_sync_count < 784 and V_sync_count > 34 and V_sync_count < 515) and current_bit = '1' else
--     x"0";  
--B <= x"F" when (H_sync_count > 143 and H_sync_count < 784 and V_sync_count > 34 and V_sync_count < 515)and current_bit = '1'  else
--     x"0";  

---- video on/off
--video_on <= '1' when (H_sync_count > 143 and H_sync_count < 784 ) and (V_sync_count > 34 and V_sync_count < 515) else '0';
--X_addr <= (others => '0') when (H_sync_count < 143 and H_sync_count > 783) else
--            (H_sync_count - 144);
--Y_addr <= (others => '0') when (V_sync_count < 34 and V_sync_count > 515) else
--            (V_sync_count - 35);


--MainHProcess: process(clock_25mhz)
--begin
--    if rising_edge(clock_25mhz) then
--        if(H_sync_count < 799) then                 --If H_sync_value < 799 then add 1 else reset back to 0
--             H_sync_count <= H_sync_count + 1;
--             EN_V_sync_counter <= '0';                  
--        else
--             H_sync_count <= (others => '0');
--             EN_V_sync_counter <= '1';                  --Toggles V_sync channel to +1
--        end if;
--    end if;
--end process;

----Main Hsync and Vsync output
--HSync <= '0' when (H_sync_count < 96) else                                         -- '0' when 0 to 96
--         '1';                                                                          

--VSync <= '0' when (V_sync_count < 2) else                                         -- '0' when 0 to 2
--         '1';  
         
         
         
----INSTS--
--INST_Clock_divider: Clock_Divider
--port map ( 
--    clk => I_CLK_50MHZ,
----    reset: in std_logic;
--    clock_out_25Mhz => clock_25mhz
--    );
    
--INST_V_COUNT: Vertical_count 
--    port map(
--        Clock_in_25Mhz => clock_25mhz,
--        Vertical_Sync_En => EN_V_sync_counter,
--        Vertical_count_value => V_sync_count
    
--    );

 
--end Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity vga_sync is
 port(
          clk, reset: in std_logic;
          --I_CLK_125MHZ : in std_logic;
          bram_data_in : in std_logic_vector(7 downto 0);
          bram_addr_out : out std_logic_vector(15 downto 0);
          vga_r : out std_logic_vector(3 downto 0);
          vga_g : out std_logic_vector(3 downto 0);
          vga_b : out std_logic_vector(3 downto 0);

         hsync, vsync: out std_logic

 );
end vga_sync;

architecture arch of vga_sync is
 -- VGA 640-by-480 sync parameters
 constant HD: integer:= 640;  --horizontal display area
 constant HF: integer:= 16 ;  --h. front porch
 constant HR: integer:= 96 ;  --h. retrace
 constant HB: integer:= 48 ;  --h. back porch
 constant VD: integer:= 480;  --vertical display area
 constant VF: integer:= 10;   --v. front porch
 constant VR: integer:= 2;    --v. retrace
 constant VB: integer:= 33;   --v. back porch
 
 -- mod-2 counter
 signal mod2_reg, mod2_next: std_logic;
 -- sync counters
 signal v_count_reg, v_count_next: unsigned(9 downto 0);
 signal h_count_reg, h_count_next: unsigned(9 downto 0);
 -- output buffer
 signal v_sync_reg, h_sync_reg: std_logic;
 signal v_sync_next, h_sync_next: std_logic;
 -- status signal
 signal h_end, v_end, pixel_tick: std_logic;
 -- signals moved from top level
 signal video_on, p_tick: std_logic;
 signal pixel_x, pixel_y: std_logic_vector(9 downto 0);
 -- red, blue, green signals
 signal vga_r_sig: std_logic_vector(3 downto 0);
 signal vga_b_sig: std_logic_vector(3 downto 0);
 signal vga_g_sig: std_logic_vector(3 downto 0);
 -- temporary bram signals
 signal bram_addr :std_logic_vector(15 downto 0);
 signal result : integer;
 signal count: std_logic;
 
 begin
     process (clk, reset)
     begin
     if reset = '1' then
        mod2_reg <= '0';
         v_count_reg <= (others=>'0');
         h_count_reg <= (others=>'0');
         v_sync_reg <= '0';
         h_sync_reg <= '0';
     elsif (clk'event and clk='1') then
         mod2_reg <= mod2_next;
         v_count_reg <= v_count_next;
         h_count_reg <= h_count_next;
         v_sync_reg <= v_sync_next;
         h_sync_reg <= h_sync_next;
     end if;
 end process;
 
     -- mod-2 circuit to generate 25 MHz enable tick
     mod2_next <= not mod2_reg;
     -- 25 MHz pixel tick
     pixel_tick <= '1' when mod2_reg='1' else '0';
     -- status
     h_end <= -- end of horizontal counter
     '1' when h_count_reg=(HD+HF+HR+HB-1) else --799
     '0';
     v_end <= -- end of vertical counter
     '1' when v_count_reg=(VD+VF+VR+VB-1) else --524
     '0';
 
 -- mod-800 horizontal sync counter
 process (h_count_reg, h_end, pixel_tick)
     begin
     if pixel_tick='1' then -- 25 MHz tick
     if h_end='1' then
     h_count_next <= (others=>'0');
     else
     h_count_next <= h_count_reg + 1;
     end if;
     else
     h_count_next <= h_count_reg;
     end if;
 end process;
 
  -- mod-525 vertical sync counter
     process (v_count_reg, h_end, v_end, pixel_tick)
     begin
     if pixel_tick='1' and h_end='1' then
     if (v_end='1') then
     v_count_next <= (others=>'0');
     else
     v_count_next <= v_count_reg + 1;
     end if;
     else
     v_count_next <= v_count_reg;
     end if;
     end process;
 
 -- horizontal and vertical sync, buffered to avoid glitch
     h_sync_next <=
     '0' when (h_count_reg >= (HD+HF)) --656
     and (h_count_reg <= (HD+HF+HR-1)) else --751
     '1';
         
     v_sync_next <=
     '0' when (v_count_reg >= (VD+VF)) --490
     and (v_count_reg <= (VD+VF+VR-1)) else --491
     '1';
     -- video on/off
     video_on <=
     '1' when (h_count_reg<HD) and (v_count_reg<VD) else
     '0';

count <= bram_data_in(to_integer(unsigned(pixel_x)) mod 8);
   
   
   
    process(count, video_on)
    begin
     if reset = '1' then
    vga_r_sig <= (others=>'0');
    vga_b_sig <= (others=>'0');
    vga_g_sig <= (others=>'0');
   
     else
        if (count = '1' ) then
            vga_r_sig <= (others=>'0');
            vga_b_sig <= (others=>'0');
            vga_g_sig <= (others=>'0');

        elsif (count = '0') then
            vga_r_sig <= (others=>'1');
            vga_b_sig <= (others=>'1');
            vga_g_sig <= (others=>'1');
 
        end if;
    end if;

   end process;
   
 vga_r <= vga_r_sig when video_on='1' else "0000";
 vga_b <= vga_b_sig when video_on='1' else "0000";
 vga_g <= vga_g_sig when video_on='1' else "0000";

 result <= (to_integer(unsigned(pixel_x)) / 8) + (to_integer(unsigned(pixel_y)) * 80);
 bram_addr <= std_logic_vector(to_unsigned(result, bram_addr'length));
 
 -- output signal
     hsync <= h_sync_reg;
     vsync <= v_sync_reg;
     pixel_x <= std_logic_vector(h_count_reg);
     pixel_y <= std_logic_vector(v_count_reg);
     p_tick <= pixel_tick;
     bram_addr_out <= bram_addr;
     
end arch; 
