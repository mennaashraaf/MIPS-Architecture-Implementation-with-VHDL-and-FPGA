library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;


entity reg8x16 is
  port (
    clk, E: in std_logic;
    RA1, RA2, WA: in std_logic_vector(3-1 downto 0);
    W: in std_logic_vector(16-1 downto 0);
    R1, R2: out std_logic_vector(16-1 downto 0)
  );
end entity reg8x16;

architecture behav of reg8x16 is
  type mem is array(8-1 downto 0) of std_logic_vector(16-1 downto 0);
  signal reg_arr: mem;
begin
  process (clk)
  begin
    if rising_edge(clk) then 
      if E = '1' then
        reg_arr(to_integer(unsigned(WA))) <= W;
      end if;
      R1 <= reg_arr(to_integer(unsigned(RA1)));
      R2 <= reg_arr(to_integer(unsigned(RA2)));
    end if;
  end process;
end behav;
