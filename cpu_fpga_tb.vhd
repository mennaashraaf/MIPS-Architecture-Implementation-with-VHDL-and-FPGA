library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;


entity cpu_fpga_tb is
end entity cpu_fpga_tb;

architecture tb of cpu_fpga_tb is

  component cpu_fpga is
    port (
      real_clk, reset: in std_logic;
      ram_L0_rbyte: out std_logic_vector(8-1 downto 0);
      pc_rrip: out std_logic_vector(4-1 downto 0)
      );
  end component;

  signal clk, reset : std_logic := '1';
  signal ram_L0_rbyte : std_logic_vector (8-1 downto 0);
  signal pc_rrip : std_logic_vector (4-1 downto 0);

begin

  cpu_fpga1: cpu_fpga port map(clk, reset, ram_L0_rbyte, pc_rrip);
  clk <= not clk after 0.5 ns;
  
  process
  begin
    wait for 1 ns;
    reset <= '0';
    wait;
  end process;


end tb;
