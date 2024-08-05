library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;


entity ram256x16 is
  port (
    clk, E: in std_logic;
    A: in std_logic_vector(8-1 downto 0);
    W: in std_logic_vector(16-1 downto 0);
    R, ram_L0: out std_logic_vector(16-1 downto 0)
  );
end entity ram256x16;

architecture behav of ram256x16 is
  type mem is array(256-1 downto 0) of std_logic_vector(16-1 downto 0);
  signal ram: mem;
begin
  process (clk)
  begin
    if rising_edge(clk) then 
      if E = '1' then
        ram(to_integer(unsigned(A))) <= W;
      else
        R <= ram(to_integer(unsigned(A)));
        ram_L0 <= ram(0);
      end if;
    end if;
  end process;
end behav;
