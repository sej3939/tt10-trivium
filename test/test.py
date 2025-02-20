# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

import trivium_uisyudha

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 5, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0

    dut._log.info("Test project behavior")
    
    # Set the input values you want to test
    key = 0x9719CFC92A9FF688F9AA
    iv = 0xECBB76B09AFF71D0D151
    # Wait for clock cycles to see the output values
    keystream = ""
    for i in range(0,1000):
        dut.rst_n.value = 0
        dut.key.value = key
        dut.iv.value = iv
        trivium_inst = trivium(key,iv)
        key = (key << 1) | random.randint(0, 1)
        IV = (IV << 1) | random.randint(0, 1)
        await ClockCycles(dut.clk, 1)
        dut.rst_n.value = 1
        await ClockCycles(dut.clk, 3)
        
        for j in range(0,80):
            await ClockCycles(dut.clk, 1)
            keystream += str(dut.keystream_bit.value)
        assert int(keystream, 2) == int("".join(map(trivium_inst.keystream(80), bits)), 2)
        

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
    # hex(int(keystream, 2))[2:].upper()
    dut._log.info(f"keystream: {hex(int(keystream, 2))[2:].upper()}")
