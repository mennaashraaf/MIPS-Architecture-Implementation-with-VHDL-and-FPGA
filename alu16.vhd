library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.ALL;


entity alu16 is
  port (
    S: in std_logic_vector(3-1 downto 0);
    A, B: in std_logic_vector(16-1 downto 0);
    F: out std_logic_vector(16-1 downto 0);
    C: out std_logic
  );
end entity alu16;

architecture behav of alu16 is
  component mul16 is
    port (
    A, B: in std_logic_vector(16-1 downto 0);
    P: out std_logic_vector(16-1 downto 0)
  );
  end component;
  component div16 is
    port (
    A, B: in std_logic_vector(16-1 downto 0);
    Q: out std_logic_vector(16-1 downto 0)
  );
  end component;

  signal add: std_logic_vector(16 downto 0);
  signal div_Q, mul_P: std_logic_vector (16-1 downto 0);

begin

  add <= ('0'&A) + ('0'&B);
  C <= add(16) and not (s(0) or s(1) or s(2));

  div16_1: div16 port map(A, B, div_Q);
  mul16_1: mul16 port map(A, B, mul_P);

  with S select -- function
    F <= add(F'range) when o"0",
         A - B when o"1",
         mul_P when o"2",
         div_Q when o"3",
         A and B when o"4",
         A or B  when o"5",
         A xor B when o"6",
         not A   when others;
end behav;
