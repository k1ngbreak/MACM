-- commandes a executer
-- ghdl -a combi.vhd mem.vhd proc.vhd reg_bank.vhd etages.vhd testbench.vhd
-- ghdl -e tb_etageFE
-- ghdl -r tb_etageFE --vcd=simu.vcd
library ieee;
use ieee.std_logic_1164.all;

entity tb_etageFE is
end tb_etageFE;

architecture behaviour of tb_etageFE is

    signal npc       : std_logic_vector (31 downto 0);
    signal npc_fw_br : std_logic_vector (31 downto 0);
    signal PCSrc_ER  : std_logic;
    signal Bpris_EX  : std_logic;
    signal GEL_LI    : std_logic;
    signal clk       : std_logic;
    signal pc_plus_4 : std_logic_vector (31 downto 0);
    signal i_FE      : std_logic_vector (31 downto 0);

    constant clk_period : time := 2 ms; 
    signal TbClock : std_logic := '0';

begin
    Fe: entity work.etageFE
    port map (npc, npc_fw_br, PCSrc_ER, Bpris_EX, GEL_LI, clk, pc_plus_4, i_FE);

    -- Generation de l'horloge
    -- clk_process : process
    -- begin
    --   clk <= '0';
    --    wait for clk_period/2;
    --    clk <= '1';
    --   wait for clk_period/2;
    
    -- end process;


    simulation : process
    begin
        npc <= (others =>'0');
        PCSrc_ER <= '1';   
        npc_fw_br <= (others => '1');
        Bpris_EX <= '1';
        GEL_LI <= '1';
        clk <='0';

        wait for clk_period;

        clk <= '1';

wait for clk_period;
wait;

    end process simulation;

end behaviour;