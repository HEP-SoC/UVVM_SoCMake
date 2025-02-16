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

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_sbi;
use bitvis_vip_sbi.vvc_methods_pkg.all;
use bitvis_vip_sbi.td_vvc_framework_common_methods_pkg.all;

library bitvis_vip_clock_generator;
context bitvis_vip_clock_generator.vvc_context;

-- hdlregression:tb
-- Test bench entity
entity crc_vvc_demo_tb is
end entity crc_vvc_demo_tb;

-- Test bench architecture
architecture func of crc_vvc_demo_tb is

  constant C_SCOPE : string := C_TB_SCOPE_DEFAULT;

  -- Clock and bit period settings
  constant C_CLK_PERIOD : time := 10 ns;
  constant C_BIT_PERIOD : time := 16 * C_CLK_PERIOD;

  -- Predefined SBI addresses
  constant C_ADDR_WRITE       : unsigned(2 downto 0) := "000";
  constant C_ADDR_READ        : unsigned(2 downto 0) := "100";

  function crc_vhpidirect ( data: integer; initial_value: integer ) return integer is
  begin report "VHPIDIRECT custom_function_withargs" severity failure; end;
  attribute foreign of crc_vhpidirect : function is "VHPIDIRECT crc_dpi";


begin

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_test_harness : entity work.crc_vvc_demo_th;

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
  variable crc_ref_value : integer;
  variable write_val : integer;
  begin
    -- Wait for UVVM to finish initialization
    await_uvvm_initialization(VOID);

    start_clock(CLOCK_GENERATOR_VVCT, 1, "Start clock generator");

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    --enable_log_msg(ALL_MESSAGES);
    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_SEQUENCER);
    enable_log_msg(ID_UVVM_SEND_CMD);

    disable_log_msg(SBI_VVCT, 1, ALL_MESSAGES);
    enable_log_msg(SBI_VVCT, 1, ID_BFM);
    enable_log_msg(SBI_VVCT, 1, ID_FINISH_OR_STOP);

    log(ID_LOG_HDR, "Starting simulation of TB for CRC using VVCs", C_SCOPE);
    ------------------------------------------------------------

    crc_ref_value := 0;

    log("Wait 10 clock period for reset to be turned off");
    wait for (10 * C_CLK_PERIOD);       -- for reset to be turned off

    sbi_check(SBI_VVCT, 1, C_ADDR_READ, x"00000000", "READ data default");

    for i in 0 to 1000 loop
        write_val := i*5;

        sbi_write(SBI_VVCT, 1, C_ADDR_WRITE, std_logic_vector(to_signed(write_val, 32)), "WRITE DATA");
        wait for (5 * C_CLK_PERIOD);       -- for reset to be turned off
        crc_ref_value := crc_vhpidirect(write_val, crc_ref_value);
        sbi_check(SBI_VVCT, 1, C_ADDR_READ,  std_logic_vector(to_signed(crc_ref_value, 32)), "READ data default");

        wait for (5 * C_CLK_PERIOD);       -- for reset to be turned off
        await_completion(SBI_VVCT, 1, 10 * C_CLK_PERIOD);
    end loop;


    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;                   -- to allow some time for completion
    report_alert_counters(FINAL);       -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely

  end process p_main;

end func;

