

library ieee;
use ieee.std_logic_1164.all;

entity tb_etageFE is
end tb_etageFE;

architecture tb of tb_etageFE is

    component etageFE
        port (npc       : in std_logic_vector (31 downto 0);
              npc_fw_br : in std_logic_vector (31 downto 0);
              PCSrc_ER  : in std_logic;
              Bpris_EX  : in std_logic;
              GEL_LI    : in std_logic;
              clk       : in std_logic;
              pc_plus_4 : out std_logic_vector (31 downto 0);
              i_FE      : out std_logic_vector (31 downto 0));
    end component;

    signal npc       : std_logic_vector (31 downto 0);
    signal npc_fw_br : std_logic_vector (31 downto 0);
    signal PCSrc_ER  : std_logic;
    signal Bpris_EX  : std_logic;
    signal GEL_LI    : std_logic;
    signal clk       : std_logic;
    signal pc_plus_4 : std_logic_vector (31 downto 0);
    signal i_FE      : std_logic_vector (31 downto 0);

    constant TbPeriod : time := 1000 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : etageFE
    port map (npc       => npc,
              npc_fw_br => npc_fw_br,
              PCSrc_ER  => PCSrc_ER,
              Bpris_EX  => Bpris_EX,
              GEL_LI    => GEL_LI,
              clk       => clk,
              pc_plus_4 => pc_plus_4,
              i_FE      => i_FE);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        npc <= (others => '0');
        npc_fw_br <= (others => '0');
        PCSrc_ER <= '0';
        Bpris_EX <= '0';
        GEL_LI <= '0';

        -- Reset generation
        --  EDIT: Replace YOURRESETSIGNAL below by the name of your reset as I haven't guessed it
        YOURRESETSIGNAL <= '1';
        wait for 100 ns;
        YOURRESETSIGNAL <= '0';
        wait for 100 ns;

        -- EDIT Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_etageFE of tb_etageFE is
    for tb
    end for;
end cfg_tb_etageFE;