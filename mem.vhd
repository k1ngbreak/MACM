---------------------------------------

-- Memory read port

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity ReadPort is
  port(
    BusIn : in std_logic_vector(31 downto 0);
    address : in std_logic_vector(31 downto 0);
    LireMem_W, LireMem_UB, LireMem_SB, LireMem_UH, LireMem_SH : in std_logic;
    BusOut : out std_logic_vector(31 downto 0)
    );
end entity;


architecture arch_ReadPort_simple of ReadPort is
  signal b7, b15 : STD_LOGIC;
  signal HW : STD_LOGIC_VECTOR(15 downto 0);
  signal B : std_logic_vector(7 downto 0);
  signal ones_16, zeros_16 : STD_LOGIC_VECTOR(15 downto 0);
  signal ones_24, zeros_24 : STD_LOGIC_VECTOR(23 downto 0);
  signal C : std_logic_vector(6 downto 0);
begin
   -- Validation signals for tri-state gates
  C(0) <= LireMem_W;
  C(1) <= LireMem_UB or LireMem_SB;
  C(2) <= LireMem_UH or LireMem_SH;
--  C(3) <= LireMem_UB or (LireMem_SB and not b7);
--  C(4) <= LireMem_SB and b7;
  C(5) <= LireMem_UB or (LireMem_SB and not b7) or LireMem_SH or (LireMem_SH and not b15);
  C(6) <= (LireMem_SB and b7) or (LireMem_SH and b15);


  ones_16 <= (others => '1');
  zeros_16 <= (others => '0');
  ones_24 <= (others => '1');
  zeros_24 <= (others => '0');

  HW <= BusIn(15 downto 0) when address(1)= '0' else
        BusIn(31 downto 0);

  B <= BusIn(7 downto 0) when (address(1)= '0') and (address(0)= '0') else
       BusIn(15 downto 8) when (address(1)= '0') and address(0)= '1' else
       BusIn(23 downto 16) when address(1)= '1' and (address(0)= '0') else
       BusIn(31 downto 24);
  
  b7 <= B(7);
  b15 <= HW(15);
  
  BusOut <= BusIn when C(0)= '1' else
            ones_16 & HW when C(2)= '1' and C(6)='1' else
            zeros_16 & HW when C(2)= '1' and C(5)='1' else
            ones_24 & B when C(1)='1' and C(6)='1' else
            zeros_24 & B;
end architecture;

-------------------------------------------------------

-- Memory write port

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity WritePort is
  port(
    address, data_in, current_mem : in std_logic_vector(31 downto 0);
    
    EcrireMem_W, EcrireMem_H, EcrireMem_B : std_logic;
    data_out : out std_logic_vector(31 downto 0)
    );
end entity;

architecture arch_WP of WritePort is
begin
  data_out <= data_in when EcrireMem_W='1' else
              current_mem(31 downto 16) & data_in(15 downto 0) when EcrireMem_H= '1' and address(1)='0' else
              data_in(15 downto 0) & current_mem(15 downto 0) when EcrireMem_H='1' and address(1)='1' else
              current_mem(31 downto 8) & data_in(7 downto 0) when EcrireMem_B='1' and (address(0)='0') and (address(1)='0') else
              current_mem(31 downto 16) & data_in(7 downto 0)&current_mem(7 downto 0)  when EcrireMem_B= '1' and address(0)='1' and (address(1)='0') else
              current_mem(31 downto 24) & data_in(7 downto 0)&current_mem(15 downto 0)  when EcrireMem_B='1' and (address(0)='0') and address(1)='1' else
              data_in(7 downto 0)&current_mem(23 downto 0)  when EcrireMem_B='1' and address(0)='1' and address(1)='1' else
              (others => 'X');
end architecture;
              
-------------------------------------------------------

-- Memory

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;



entity memory is
  port(
    address : in std_logic_vector(31 downto 0);
    CS, WE, OE, CLK : in std_logic;
    LireMem_W, LireMem_UB, LireMem_SB, LireMem_UH, LireMem_SH : in std_logic;
    EcrireMem_W, EcrireMem_H, EcrireMem_B : std_logic;
    data_in : in std_logic_vector(31 downto 0);
    data_out : out std_logic_vector(31 downto 0)
    );
end entity;

architecture arch_memory of memory is
  TYPE memory_array IS ARRAY(NATURAL RANGE<>) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal mem : memory_array(0 to 2047); -- 64KBytes
  signal output_sig, s_addr : STD_LOGIC_VECTOR(31 downto 0);
  signal word : std_logic_vector(31 downto 0);
  signal to_write : std_logic_vector(31 downto 0);
begin

  
  --Reading from memory
  data_out <= (others=> 'Z') when CS = '1' or OE = '1' else
              (others=> '0') when  WE = '0' else
              (others=> 'X') when (to_integer(unsigned(s_addr)) > 2047) else
              output_sig;
  s_addr <= address(31 downto 2);
  word <= mem(to_integer(unsigned(s_addr)));
  memRdCtrl : entity work.ReadPort
    port map(word, address, LireMem_W, LireMem_UB, LireMem_SB, LireMem_UH, LireMem_SH, output_sig);

  memWrCtrl : entity work.WritePort
    port map(address, data_in, word, EcrireMem_W, EcrireMem_H, EcrireMem_B, to_write);
  --Writing to memory
  process(CLK)
    variable addr : integer := to_integer(unsigned(address(31 downto 2)));
  begin
    if(rising_edge(CLK) and WE = '0' and CS = '0') then
      mem(addr) <= to_write;
    end if;
  end process;
end architecture;


-------------------------------------------------------

-- Simplified memory interface

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


entity inst_mem is
  port (
    addr : in std_logic_vector(31 downto 0);
    clk: in std_logic;
    instr : out std_logic_vector(31 downto 0)
    );
end entity;


architecture arch_inst_mem of inst_mem is

begin

  mem: entity work.memory
    port map(
      address => addr,
      CS =>'0',
      WE =>'1',
      OE =>'0',
      CLK => clk,
      LireMem_W => '1',
      LireMem_UB => '0',
      LireMem_SB => '0',
      LireMem_UH => '0',
      LireMem_SH => '0',
      EcrireMem_W => '0',
      EcrireMem_H => '0',
      EcrireMem_B => '0',
      data_in => (others=>'0'),
      data_out => instr
      );
end architecture;
