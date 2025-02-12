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

entity crc_pif is
  port(
    arst  : in  std_logic;
    clk   : in  std_logic;
    -- CPU interface
    cs    : in  std_logic;
    addr  : in  unsigned;
    wr    : in  std_logic;
    rd    : in  std_logic;
    wdata : in  std_logic_vector(31 downto 0);
    rdata : out std_logic_vector(31 downto 0) := (others => '0');
    --
    p2c   : out t_p2c;
    c2p   : in  t_c2p
  );
end crc_pif;

architecture rtl of crc_pif is
  signal p2c_i   : t_p2c := (
    wo_write          => (others => '0'),
    awo_write_we      => '0');  -- internal version of output
  signal rdata_i : std_logic_vector(31 downto 0) := (others => '0');

begin

  -- Assigning internally used signals to outputs
  p2c <= p2c_i;

  --
  -- Auxiliary Register Control.
  --
  --   Provides read/write/trigger strobes and write data to auxiliary
  --   registers and fields, i.e., registers and fields implemented in core.
  --
  p_aux : process(wdata, addr, cs, wr, rd, arst)
  begin
    -- Reset for pif registers
    if arst = '1' then
      p2c_i.wo_write <= (others => '0');
    end if;
    -- Defaults
    p2c_i.awo_write_we <= '0';

    -- Write decoding
    if wr = '1' and cs = '1' then
      case to_integer(addr) is
        when C_ADDR_WRITE =>
          p2c_i.awo_write_we <= '1';
          p2c_i.wo_write    <= wdata(7 downto 0);
        when others =>
          null;
      end case;
    end if;

  end process p_aux;

  p_read_reg : process(cs, addr, rd, c2p, p2c_i)
  begin
    -- default values
    rdata_i <= (others => '0');

    if cs = '1' and rd = '1' then
      case to_integer(addr) is
        when C_ADDR_READ =>
          rdata_i(31 downto 0) <= c2p.aro_read;
        when others =>
          null;
      end case;
    end if;
  end process p_read_reg;

  rdata <= rdata_i;

end rtl;


