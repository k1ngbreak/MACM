-------------------------------------------------

-- Etage FE

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity etageFE is
  port(
    npc, npc_fw_br : in std_logic_vector(31 downto 0);
    PCSrc_ER, Bpris_EX, GEL_LI, clk : in std_logic;
    pc_plus_4, i_FE : out std_logic_vector(31 downto 0)
);
end entity;


architecture etageFE_arch of etageFE is
  signal pc_inter, pc_reg_in, pc_reg_out, sig_pc_plus_4, sig_4: std_logic_vector(31 downto 0);
begin

  sig_4 <= (2=>'1', others => '0');
  
  add4: entity work.addComplex
    port map(pc_reg_out, sig_4, '0', sig_pc_plus_4);
  
    pc_plus_4 <= sig_pc_plus_4;
    pc_inter <= npc when PCSrc_ER = '1' else
      sig_pc_plus_4;
    
    pc_reg_in <= pc_inter when Bpris_EX='0' else
      npc_fw_br;

    reg_pc: entity work.Reg32
      port map(pc_reg_in, pc_reg_out, GEL_LI, '1', clk);

    mem_inst: entity work.inst_mem
      port map(pc_reg_out, i_FE);

    


end architecture;

-- -------------------------------------------------
-- mettre val dans registre


-- -- Etage DE

 LIBRARY IEEE;
 USE IEEE.STD_LOGIC_1164.ALL;
 USE IEEE.NUMERIC_STD.ALL;

 entity etageDE is
  port(
    i_DE, WD_ER, pc_plus_4 : in std_logic_vector(31 downto 0);
    op3_ER : in std_logic_vector(3 downto 0);
    RegSrc, immSrc : in std_logic_vector(1 downto 0);
    RegWr, clk : in std_logic;
    Reg1, Reg2: out std_logic_vector(3 downto 0);
    Op1, Op2, extlmm : out std_logic_vector(31 downto 0);
    Op3_DE : out std_logic_vector(3 downto 0);

  );
 end entity;

 architecture etageDE_arch of etageDE is
 signal sigOp1, sigOp2 : std_logic_vector(3 downto 0);
  begin
    
    sigOp2 <= i_DE(15 downto 12) when RegSrc(1)='1' else i_DE(3 downto 0);
    sigOp1 <= i_DE(19 downto 16) when Regsrc(0)='0' else i_DE(15);

    




  end architecture;

-- -------------------------------------------------

-- -- Etage EX

-- LIBRARY IEEE;
-- USE IEEE.STD_LOGIC_1164.ALL;
-- USE IEEE.NUMERIC_STD.ALL;

-- entity etageEX is
-- end entity
-- -------------------------------------------------

-- -- Etage ME

-- LIBRARY IEEE;
-- USE IEEE.STD_LOGIC_1164.ALL;
-- USE IEEE.NUMERIC_STD.ALL;

-- entity etageME is
-- end entity
-- -------------------------------------------------

-- -- Etage ER

-- LIBRARY IEEE;
-- USE IEEE.STD_LOGIC_1164.ALL;
-- USE IEEE.NUMERIC_STD.ALL;

-- entity etageER is
-- end entity
