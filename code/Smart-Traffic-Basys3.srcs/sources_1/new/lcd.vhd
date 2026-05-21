----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/02/2024 06:16:59 AM
-- Design Name: 
-- Module Name: lcd - Behavioral
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



-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lcd is
port(
clk: in std_logic;
reset: in std_logic;
en: out std_logic ;
rs: out std_logic ;
rw: out std_logic ;
common_bus: inout std_logic_vector (63 downto 0);
data:out std_logic_vector(3 downto 0)  --D7,D6,D5,D4
);
end lcd;

architecture Behavioral of lcd is
    type t_state is (START,INIT,WRITE,READY,CLEAR);
    signal state:t_state:=START;
    signal counter:integer:=0;
    constant delay_ms:integer:=100_000;
    constant delay_us:integer:=100;
    constant RESULT_SIZE: integer:=63;
    signal input_buffer:std_logic_vector (7 downto 0):=(others=>'0');
    signal result: std_logic_vector(RESULT_SIZE downto 0);
begin
-- en period 2µs 
-- wait between nibbles and next instruction 40 µs 
process(clk,reset) is
    variable index: integer := RESULT_SIZE;
begin
    if(reset='1') then
        state<=START;
    elsif rising_edge(clk) then
    case state is
        when START=>
            --30ms
            if(counter<30*delay_ms-1) then
                counter<=counter+1;
            else
                state<=INIT;
                counter<=0;
            end if;
        when INIT=>
            -- function set
            if(counter<1*delay_us-1) then
                rs<='0';
                counter<=counter+1;
                rw<='0';
                data<="0010";
                en<='1';
            elsif (counter<(41*delay_us)-1) then
                en<='0';
                counter<=counter+1;
            elsif (counter<(42*delay_us)-1) then
                rs<='0';
                rw<='0';
                counter<=counter+1;
                data<="0010";
                en<='1';
            elsif (counter<(82*delay_us)-1) then
                en<='0';
                counter<=counter+1;
            
            elsif (counter<83*delay_us-1) then
                rs<='0';
                rw<='0';
                counter<=counter+1;
                data<="1000";
                en<='1';
            elsif (counter<(123)*delay_us-1) then
                en<='0';
                counter<=counter+1;
            --display on off control
            elsif (counter<(124)*delay_us-1) then
                rs<='0';
                rw<='0';
                counter<=counter+1;
                data<="0000";
                en<='1';
            elsif (counter<(164)*delay_us-1) then
                en<='0';
                counter<=counter+1;
            elsif (counter<(165)*delay_us-1) then
                rs<='0';
                rw<='0';
                counter<=counter+1;
                data<="1111";
                en<='1';
            elsif (counter<(205)*delay_us-1) then
                en<='0';
                counter<=counter+1;
            --clear display
            elsif (counter<(206)*delay_us-1) then
                rs<='0';
                rw<='0';
                counter<=counter+1;
                data<="0000";
                en<='1';
            elsif (counter<(246)*delay_us-1) then
                en<='0';
                counter<=counter+1;
            elsif (counter<(247)*delay_us-1) then
                rs<='0';
                rw<='0';
                counter<=counter+1;
                data<="0001";
                en<='1';
            elsif (counter<((244)*delay_us+2*delay_ms)-1) then
                en<='0';
                counter<=counter+1;
            
            --entry mode
            elsif (counter<((245)*delay_us+2*delay_ms)-1) then
                rs<='0';
                rw<='0';
                counter<=counter+1;
                data<="0000";
                en<='1';
            elsif (counter<((285)*delay_us+2*delay_ms)-1) then
                en<='0';
                counter<=counter+1;
            elsif (counter<((286)*delay_us+2*delay_ms)-1) then
                rs<='0';
                rw<='0';
                counter<=counter+1;
                data<="0110";
                en<='1';
            elsif (counter<((325)*delay_us+2*delay_ms)-1) then
                en<='0';
                counter<=counter+1;
            else 
                counter<=0;
                state<=READY; 
                
            end if;
        when READY=>
            if(index<7) then
                if(counter<100*delay_ms-1) then
                    counter<=counter+1;
                    state<=READY;
                else
                    counter<=0;
                    state<=CLEAR;
                    index:=RESULT_SIZE;
                end if;
            else
                if(counter<1*delay_ms-1) then
                    counter<=counter+1;
                    input_buffer<=result(index downto (index-7));
                else
                    index:=index-8;
                    state<=WRITE;
                    counter<=0;
                end if;  
            end if;
            
            
        when WRITE =>
            if counter < (1 * delay_us-1) then
                rs <= '1'; rw <= '0'; 
                data(3 downto 0) <= input_buffer(7 downto 4);
                en <= '1';
                counter <= counter + 1;
            elsif counter < (41 * delay_us-1) then
                en <= '0';
                counter <= counter + 1;
            elsif counter < (42 * delay_us-1) then
                rs <= '1'; rw <= '0';
                data(3 downto 0) <= input_buffer(3 downto 0); 
                en <= '1';
                counter <= counter + 1;
            elsif counter < (82 * delay_us-1) then
                en <= '0'; 
                counter <= counter + 1;
            else
                counter <= 0;
                state <= READY; 
            end if;


            when CLEAR=>
                if (counter<((1)*delay_us)-1) then
                    rs<='0';
                    rw<='0';
                    counter<=counter+1;
                    data<="0000";
                    en<='1';
                elsif (counter<((41)*delay_us)-1) then
                    en<='0';
                    counter<=counter+1;
                elsif (counter<((42)*delay_us)-1) then
                    rs<='0';
                    rw<='0';
                    counter<=counter+1;
                    data<="0001";
                    en<='1';
                elsif (counter<((42)*delay_us+2*delay_ms)-1) then
                    en<='0';
                    counter<=counter+1;
                else
                    counter<=0; 
                    state<=READY;
                end if;
            end case;
    end if;
end process;

result <= "00110101" & -- ASCII for '5'
          "01000111" & -- ASCII for 'G'
          "01100001" & -- ASCII for 'a'
          "01100100" &  -- ASCII for 'd'
          "00100000" & -- ASCII for 'SPACE'
           common_bus(63 downto 48) &
          "01100011";  -- c
end Behavioral;