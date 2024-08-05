library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.ALL;

entity mul16 is
  port (
    A, B: in std_logic_vector(16-1 downto 0);
    P: out std_logic_vector(16-1 downto 0)
  );
end entity mul16;


architecture behav of mul16 is
  signal ans : std_logic_vector (15*2-1 downto 0);
  signal us_A, us_B : std_logic_vector (A'range);
begin

  P(15) <= A(15) xor B(15);

  with A(15) select
    us_A <= 0 - A when '1',
            A when others;

  with B(15) select
    us_B <= 0 - B when '1',
            B when others;

  ans <= us_A(15-1 downto 0) * us_B(15-1 downto 0);

  P(14 downto 0) <= ans(14 downto 0);

end behav;
