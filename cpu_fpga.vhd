library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity cpu_fpga is
  generic (
    REAL_CLK_SPEED: positive := 10 -- Hz (gtkwave simulation version is 10 Hz)
    --REAL_CLK_SPEED: positive := 50e6 -- Hz (real FPGA clock is 50 MHz)
);
  port (
  real_clk, reset: in std_logic;
  ram_L0_rbyte: out std_logic_vector(8-1 downto 0);
  pc_rrip: out std_logic_vector(4-1 downto 0)
);
end entity cpu_fpga;

architecture behv of cpu_fpga is

  component cpu is
  port (
    clk, reset: in std_logic;
    ram_L0: out std_logic_vector(16-1 downto 0);
    pc_rrip: out std_logic_vector(4-1 downto 0)
  );
  end component;

  signal ram_L0 : std_logic_vector (16-1 downto 0);
  signal clk_count : integer;
  signal slow_clk : std_logic;

begin

  -- cpu1: cpu port map(slow_clk, reset, ram_L0, pc_rrip);
  cpu1: cpu port map(real_clk, reset, ram_L0, pc_rrip);
  ram_L0_rbyte <= ram_L0(ram_L0_rbyte'range);

  process (real_clk, reset)
  begin
    if reset = '1' then
      clk_count <= 1;
      slow_clk <= '0';
    elsif rising_edge(real_clk) then 
      if clk_count = REAL_CLK_SPEED/2 then -- half high and half low
        clk_count <= 1;
        slow_clk <= not slow_clk;
      else
        clk_count <= clk_count + 1;
      end if;
    end if;
  end process;

end behv;
