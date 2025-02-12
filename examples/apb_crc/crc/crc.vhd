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

use work.crc_pif_pkg.all;

entity crc is
  -- generic(
  --   GC_START_BIT                 : std_logic := '0';
  --   GC_STOP_BIT                  : std_logic := '1';
  --   GC_CLOCKS_PER_BIT            : integer   := 16;
  --   GC_MIN_EQUAL_SAMPLES_PER_BIT : integer   := 15); -- Number of equal samples needed for valid bit, crc samples on every clock
  port(
    -- DSP interface and general control signals
    clk   : in  std_logic;
    arst  : in  std_logic;
    -- CPU interface
    cs    : in  std_logic;
    addr  : in  unsigned(2 downto 0);
    wr    : in  std_logic;
    rd    : in  std_logic;
    wdata : in  std_logic_vector(31 downto 0);
    rdata : out std_logic_vector(31 downto 0) := (others => '0')
  );
begin
end crc;

architecture rtl of crc is

  -- PIF-core interface
  signal p2c : t_p2c;                   --
  signal c2p : t_c2p;                   --

  signal state_reg   : std_logic_vector(31 downto 0) := (others => '0');
  signal output_reg  : std_logic_vector(31 downto 0) := (others => '0');
  signal lfsr_state  : std_logic_vector(31 downto 0);
  signal read_reg    : std_logic_vector(31 downto 0);

begin

  i_crc_pif : entity work.crc_pif
    port map(
      arst  => arst,                    --
      clk   => clk,                     --
      -- CPU interface
      cs    => cs,                      --
      addr  => addr,                    --
      wr    => wr,                      --
      rd    => rd,                      --
      wdata => wdata,                   --
      rdata => rdata,                   --
      --
      p2c   => p2c,                     --
      c2p   => c2p                      --
    );

  i_crc_core : entity work.crc_core
    port map(
      -- PIF-core interface
      crcIn => state_reg,
      data  => p2c.wo_write,
      crcOut => lfsr_state
      -- p2c  => p2c,                      --
      -- c2p  => c2p                      --
    );

  -- Assign the computed CRC to the read data output (equivalent to assign hwif_out.read.data.next)
  c2p.aro_read <= read_reg;

  -- Register update logic (equivalent to always @(posedge clk) in Verilog)
  process (clk)
  begin
    if rising_edge(clk) then
      if arst = '1' then  -- Active-low reset
        state_reg  <= (others => '0');
        output_reg <= (others => '0');
        read_reg   <= (others => '0');
      else
        if p2c.awo_write_we = '1' then
          state_reg  <= lfsr_state;
          output_reg <= lfsr_state;
        end if;
        read_reg <= lfsr_state;
      end if;
    end if;
  end process;

end rtl;


