library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.ALL;


entity cpu is
  port (
    clk, reset: in std_logic;
    ram_L0: out std_logic_vector(16-1 downto 0);
    pc_rrip: out std_logic_vector(4-1 downto 0)
  );
end entity cpu;


architecture behav of cpu is
  component alu16 is
  port (
    S: in std_logic_vector(3-1 downto 0);
    A, B: in std_logic_vector(16-1 downto 0);
    F: out std_logic_vector(16-1 downto 0);
    C: out std_logic
  );
  end component;
  component ram256x16 is
  port (
    clk, E: in std_logic;
    A: in std_logic_vector(8-1 downto 0);
    W: in std_logic_vector(16-1 downto 0);
    R, ram_L0: out std_logic_vector(16-1 downto 0)
  );
  end component;
  component reg8x16 is
  port (
    clk, E: in std_logic;
    RA1, RA2, WA: in std_logic_vector(3-1 downto 0);
    W: in std_logic_vector(16-1 downto 0);
    R1, R2: out std_logic_vector(16-1 downto 0)
  );
  end component;
  component rom256x16 is
  port (
    clk: in std_logic;
    A: in std_logic_vector(8-1 downto 0);
    D: out std_logic_vector(16-1 downto 0)
  );
  end component;
  component cu is
  port(
    clk, executing: in std_logic;
    exe_done, PC_changed: out std_logic;
    PC_new: out std_logic_vector(8-1 downto 0);
    IR: in std_logic_vector(16-1 downto 0);
    alu_S: out std_logic_vector(3-1 downto 0);
    alu_B: out std_logic_vector(16-1 downto 0);
    alu_F: in std_logic_vector(16-1 downto 0);
    alu_C: in std_logic;
    mem_A: out std_logic_vector(8-1 downto 0);
    mem_E: out std_logic;
    mem_R: in std_logic_vector(16-1 downto 0);
    reg_W: out std_logic_vector(16-1 downto 0);
    reg_WA, reg_RA1, reg_RA2: out std_logic_vector(3-1 downto 0);
    reg_R2: in std_logic_vector(16-1 downto 0);
    reg_E: out std_logic
  );
  end component;

  signal alu_C, mem_E, reg_E: std_logic;
  signal alu_S, reg_WA, reg_RA1, reg_RA2 : std_logic_vector (3-1 downto 0);
  signal alu_B, alu_F, reg_R1, reg_R2, reg_W, mem_R, IR: std_logic_vector (16-1 downto 0);
  signal mem_A, PC, cu_PC_new: std_logic_vector (8-1 downto 0);
  signal cu_executing, cu_exe_done, cu_PC_changed: std_logic;
begin

  pc_rrip <= PC(pc_rrip'range);
  alux: alu16 port map(alu_S, reg_R1, alu_B, alu_F, alu_C);
  regx: reg8x16 port map(clk, reg_E, reg_RA1, reg_RA2, reg_WA, reg_W, reg_R1, reg_R2);
  memx: ram256x16 port map(clk, mem_E, mem_A, reg_R1, mem_R, ram_L0);
  romx: rom256x16 port map(clk, PC, IR);
  cux: cu port map(clk, cu_executing, cu_exe_done, cu_PC_changed, cu_PC_new, IR, alu_S, alu_B, alu_F, alu_C,
                  mem_A, mem_E, mem_R, reg_W, reg_WA, reg_RA1, reg_RA2, reg_R2, reg_E);
  process (clk, reset)
  begin
    if reset = '1' then
      PC <= x"00";
      cu_executing <= '1';
    elsif rising_edge(clk) then
      if cu_executing = '0' then -- fetch stage
        PC <= PC + 1;
        cu_executing <= '1';
      else -- decode and execute stages for cu
        cu_executing <= not cu_exe_done;
      end if;
      if cu_PC_changed = '1' then
        PC <= cu_PC_new;
        cu_executing <= '1';
      end if;
    end if;
  end process;
end behav;
