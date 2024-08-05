library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity div16 is
  port (
    A, B: in std_logic_vector(16-1 downto 0);
    Q: out std_logic_vector(16-1 downto 0)
  );
end entity div16;


architecture behav of div16 is
  type mat is array(0 to 14) of std_logic_vector(A'range);
  signal top, diff: mat;
  signal us_A, us_B : std_logic_vector (A'range);
begin

  Q(15) <= A(15) xor B(15); -- sign
  

  with A(15) select
    us_A <= 0 - A when '1',
            A when others;

  with B(15) select
    us_B <= 0 - B when '1',
            B when others;

  top(0) <= o"00000" & us_A(14);
  diff(0) <= top(0) - us_B;

  gsub: for i in 1 to 14 generate
    top(i)(15) <= '0';
    top(i)(0) <= us_A(14-i);
    with diff(i - 1)(16-1) select -- sign control MUX
      top(i)(14 downto 1) <= diff(i - 1)(13 downto 0) when '0',
                             top(i - 1)(13 downto 0) when others;
    diff(i) <= top(i) - us_B;
    end generate gsub;

    gQ: for i in 0 to 14 generate
      Q(14 - i) <= NOT diff(i)(15);
    end generate gQ;
 

end behav;
