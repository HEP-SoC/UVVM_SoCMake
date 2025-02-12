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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package crc_pif_pkg is

  -- Notation for regs: (Included in constant name as info to SW)
  -- - RW: Readable and writable reg.
  -- - RO: Read only reg. (output from IP)
  -- - WO: Write only reg. (typically single cycle strobe to IP)

  -- Notation for signals (or fields in record) going between PIF and core:
  -- Same notations as for register-constants above, but
  -- a preceeding 'a' (e.g. awo) means the register is auxiliary to the PIF.
  -- This means no flop in the PIF, but in the core. (Or just a dummy-register with no flop)

  constant C_ADDR_WRITE         : integer := 0;
  constant C_ADDR_READ          : integer := 4;

  -- Signals from pif to core
  type t_p2c is record
    wo_write          : std_logic_vector(7 downto 0);
    awo_write_we      : std_logic;
  end record t_p2c;

  -- Signals from core to PIF
  type t_c2p is record
    aro_read         : std_logic_vector(31 downto 0);
  end record t_c2p;

end package crc_pif_pkg;


