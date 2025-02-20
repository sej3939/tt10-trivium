# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

keystream = 0

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.rst_n.value = 0
    dut.key.value = 0x9719CFC92A9FF688F9AA
    dut.IV.value = 0xECBB76B09AFF71D0D151
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Set the input values you want to test
    

    # Wait for one clock cycle to see the output values
    for i in range(0,80):
        await ClockCycles(dut.clk, 1)
        if (i == 0):
            keystream = 0
        else:
            keystream = keystream << 1
            keystream += dut.keystream_bit.value

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
    dut._log.info(f"keystream: {hex(keystream)}")
