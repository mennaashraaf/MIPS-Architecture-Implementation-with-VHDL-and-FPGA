library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity cu is
  port ( -- skip reading this and continue to PART I
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
end entity cu;

----------------------------------------------------------
-- please, read the instructions table in lab manual PDF -
-- to understand the commands is implemented below -------
----------------------------------------------------------

----------------------------------------------------------
--- this control unit uses a modulo sequence counter -----
--- exactly like the one in book or slides ---------------
----------------------------------------------------------

architecture behav of cu is
  signal step : std_logic_vector (2-1 downto 0); -- step counter
  signal inst_opcode: std_logic_vector (4-1 downto 0); -- inst_opcode
  signal inst_Rs_A, inst_Rt_A, inst_Rd_A, inst_alu_F: std_logic_vector(3-1 downto 0);
  signal inst_RRI_imm, inst_RI_imm: std_logic_vector(16-1 downto 0);
  signal inst_RI_UJ_addr, inst_CJ_addr: std_logic_vector(8-1 downto 0);
  signal step0, step1, step2, step3: std_logic;
  signal FR: std_logic_vector (3-1 downto 0);
begin

  ---------------------------
  --  PART I
  --  MUXs and mapping ports
  ---------------------------
  
  -- splitting instruction into meaningful parts (naming the wires.. nothing more)
  inst_opcode <= IR(15 downto 12); -- opcode ADD, SM, BEQ, BLT, etc..
  inst_Rs_A <= IR(11 downto 9); -- Source register address
  inst_Rt_A <= IR(8 downto 6); -- Another source register address
  inst_Rd_A <= IR(5 downto 3); -- Destination register address
  inst_alu_F <= IR(2 downto 0); -- ALU opcode like addition, division, etc..

  -- immediate data sign-extend MUX (RRI case used for ADDI, SUBI, etc..)
  with IR(6-1) select
    inst_RRI_imm <= "1111" & "1111" & "11" & IR(6-1 downto 0) when '1', -- sign extend
                    "0000" & "0000" & "00" & IR(6-1 downto 0) when others;

  -- immediate data sign-extend MUX (RI case used for LI command)
  with IR(9-1) select
    inst_RI_imm <= "1111" & "111" & IR(9-1 downto 0) when '1',
                   "0000" & "000" & IR(9-1 downto 0) when others;

  inst_RI_UJ_addr <= IR(8-1 downto 0); -- RI and uncondtional jump address
  inst_CJ_addr <= "00" & IR(6-1 downto 0); -- conditional jump address

  -- ALU left operand MUX
  with inst_opcode select
    alu_B <= reg_R2 when x"1" | x"A" | x"B" | x"C", -- arith RRR and cond jumping
             inst_RRI_imm  when others; -- arith RRI

  -- ALU op select MUX
  with inst_opcode select
    alu_S <= inst_alu_F when x"1", -- ADD, SUB, DIV, MUL, etc..
             o"0" when x"2", -- ADDI
             inst_alu_F(alu_S'range) when x"4" | x"5" | x"6", -- ANDI, ORI, XORI
             o"1" when others; -- SUB, BEQ, BLT, BGT (all these commands subtracts)

  -- register file writing data port MUX
  with inst_opcode select
    reg_W <= mem_R when x"8", -- load memory --> register file (only LM command)
             inst_RI_imm when x"7", -- load immediate data --> register file (only LI command)
             alu_F when others; -- for other commands like ADD, SUB, .., ADDI, XORI, etc..

  -- register file writing address MUX
  with inst_opcode select
    reg_WA <= inst_Rd_A when x"1", -- arith RRR (commands like ADD, MUL, AND, etc..)
              inst_Rs_A when x"7" | x"8", -- load imm, load mem (commands LI, LM only)
              inst_Rt_A when others; -- arith RRI (commands like ADDI, SUBI, XORI, etc..)

  -- new PC MUX
  with inst_opcode select
    PC_new <= inst_RI_UJ_addr when x"F", -- uncondtional jump (command BR)
             inst_CJ_addr when others;  -- conditional jump (commands BEQ, BLT, BGT, BC, BZ, ..)

  -- mapping ram address
  mem_A <= inst_RI_UJ_addr;

  -- mapping register file reading addresses
  reg_RA1 <= inst_Rs_A;
  reg_RA2 <= inst_Rt_A;


  -----------------
  -- PART II
  -- sequence modulo counter 
  -----------------

  -- sequence modulo counter decoder
  step0 <= not step(0) and not step(1);
  step1 <= step(0) and not step(1);
  step2 <= not step(0) and step(1);
  step3 <= step(0) and step(1);

  -- memory write enable MUX
  with inst_opcode select
    mem_E <= '1' when x"9", -- memory write only (command SM)
             '0' when others;

  -- register write enable MUX
  with inst_opcode select
    reg_E <= step2 when x"1" | x"2" | x"3" | x"4" | x"5" | x"6" | x"7" | x"8", -- commands like ADD, SUB, .., ADDI, .., LI and LM
             '0' when others;

  -- PC next address MUX of combinational circuits
  with inst_opcode select
    PC_changed <= step3 and FR(0) when x"A", -- third_clock_tick and equal_flag
                  step3 and not FR(2) and not FR(0) when x"B", -- third_clock and greater (not equal_flag and not sign_flag)
                  step3 and FR(2) when x"C", -- third_clock and less (sign_flag)
                  FR(1) when x"D", -- carry_flag
                  FR(0) when x"E", -- zero_flag
                  '1' when x"F", -- uncondtional jump
                  '0' when others; -- other non-jumping commands does not affect PC

  -- when executing clock cycle end, a signal is sent to update PC in CPU (the master component)
  with inst_opcode select
    exe_done <= step3 when x"A" | x"B" | x"C", -- BEQ, BLT, BGT each takes 3 clocks
                                               -- (1st load registers... 2nd subtract them.. 3rd decide to jump or not based on new FR)
                step1 when x"D" | x"E" | x"F", -- BC, BZ, BR each takes 1 clock
                                               -- (1st decide to jump or not based on old FR)
                step2 when others; -- other commands take 2 clock each
                                   -- for example arith (1st load registers and select ALU op.. 2nd store ALU output in a register)

  -- the only seqential processes in this control unit
  process (clk)
  begin
    -- each CPU clock
    if rising_edge (clk) then

      -- refresh modulo step counter
      if executing = '1' then
        step <= step + 1; -- if still executing then increment step_counter
      else
        step <= "00"; -- if not executing (means finished) then reset step_counter
      end if;

      -- refresh flag registers
      case inst_opcode is
       when x"1" | x"2" | x"3" | x"4" | x"5" | x"6" | x"A" | x"B" | x"C" => -- arith and cond jump causes flag register FR to refresh its values
         case alu_F is
           when x"0000" => FR(0) <= '1'; -- Zero_flag is set true if last ALU's output is zero
           when others =>  FR(0) <= '0'; -- otherwise it is false (means positive or negative output)
         end case;
         FR(1) <= alu_C; -- carry_flag
         FR(2) <= alu_F(15); -- sign_flag (sign bit)
       when others =>
      end case;

    end if;
  end process;
end behav;
