# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

from trivium_uisyudha import Trivium

def int_to_bin_list_bitwise(n, bit_length):
    return [(n >> i) & 1 for i in range(bit_length - 1, -1, -1)]

def bin_list_to_int_bitwise(bin_list):
    num = 0
    for bit in bin_list:
        num = (num << 1) | bit
    return num

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
    for i in range(0,1):
        keystream = ""
        dut.rst_n.value = 0
        #dut.key.value = key
        #dut.iv.value = iv
        trivium_inst = Trivium(int_to_bin_list_bitwise(key,80),int_to_bin_list_bitwise(iv,80))
        #key = ((key << 1) | random.randint(0, 1)) & ((1 << 80) - 1)
        #iv = ((iv << 1) | random.randint(0, 1)) & ((1 << 80) - 1)
        await ClockCycles(dut.clk, 1)
        dut.rst_n.value = 1
        await ClockCycles(dut.clk, 1153)
        
        for j in range(0,2000):
            await ClockCycles(dut.clk, 1)
            keystream += str(dut.uo_out[0].value)
        actual_keystream = trivium_inst.keystream(2000)
        dut._log.info(f"keystream: {hex(int(keystream, 2))[2:].upper().zfill(500)}, actual keystream: {hex(bin_list_to_int_bitwise(actual_keystream))[2:].upper().zfill(500)}")
        #assert int(keystream, 2) == bin_list_to_int_bitwise(actual_keystream)
        

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
    # hex(int(keystream, 2))[2:].upper()
    
