--================================================================================================================================
-- Copyright 2024 UVVM
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
--
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
-- an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and limitations under the License.
--================================================================================================================================
-- Note : Any functionality not explicitly described in the documentation is subject to change at any time
----------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- use work.crc_pif_pkg.all;
use work.pkg_crc_regs.all;

entity crc is
  port(
    -- DSP interface and general control signals
    clk   : in  std_logic;
    arst  : in  std_logic;
    -- CPU interface
    cs    : in  std_logic;
    addr  : in  unsigned(2 downto 0);
    wr    : in  std_logic;
    rd    : in  std_logic;
    rack  : out std_logic;
    wack  : out std_logic;

    wdata : in  std_logic_vector(31 downto 0);
    rdata : out std_logic_vector(31 downto 0) := (others => '0')
  );
begin
end crc;

architecture rtl of crc is

  -- PIF-core interface
  signal hwif_in : t_addrmap_crc_regs_in;                   --
  signal hwif_out : t_addrmap_crc_regs_out;                   --

  signal pi_s_top : t_crc_regs_m2s;
  signal po_s_top : t_crc_regs_s2m;

  signal state_reg   : std_logic_vector(31 downto 0) := (others => '0');
  signal lfsr_state  : std_logic_vector(31 downto 0);

  signal rd_ack : std_logic;
  signal wr_ack : std_logic;

begin

  pi_s_top.addr(2 downto 0) <= std_logic_vector(addr);
  pi_s_top.addr(31 downto 3) <= b"00000000000000000000000000000";
  pi_s_top.data <= wdata;
  pi_s_top.rena <= rd;
  pi_s_top.wena <= wr;
  rdata <= po_s_top.data;

  rack <= po_s_top.rack;
  wack <= po_s_top.wack;

  i_crc_regs : entity work.crc_regs
    port map(
      pi_reset  => arst,                    --
      pi_s_reset  => arst,                    --
      pi_clock   => clk,                     --
      -- CPU interface

      pi_s_top => pi_s_top,
      po_s_top => po_s_top,

      pi_addrmap   => hwif_in,                     --
      po_addrmap   => hwif_out                      --
    );

  i_crc_core : entity work.crc_core
    port map(
      -- PIF-core interface
      crcIn => state_reg,
      data  => hwif_out.input_reg.crc_in.data(7 downto 0),
      crcOut => lfsr_state
    );

  -- Assign the computed CRC to the read data output (equivalent to assign hwif_out.read.data.next)
  hwif_in.output_reg.crc_out.data <= state_reg;

  -- Register update logic (equivalent to always @(posedge clk) in Verilog)
  process (clk)
  begin
    if rising_edge(clk) then
      if arst = '1' then  -- Active-low reset
        state_reg  <= (others => '0');
      else
        if hwif_out.input_reg.crc_in.swmod = '1' then
          state_reg  <= lfsr_state;
        end if;
      end if;
    end if;
  end process;

end rtl;


