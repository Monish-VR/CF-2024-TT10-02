# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def fifo_simple_test(dut):
    """Simple FIFO Test: Write one value and read it back"""
    
    dut._log.info("Starting FIFO Test")

    # Start the clock (10ns period = 100 MHz)
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset the FIFO
    dut.ena.value = 1  # Enable
    dut.rst_n.value = 0  
    await ClockCycles(dut.clk, 5)  # Hold reset
    dut.rst_n.value = 1  
    await ClockCycles(dut.clk, 5)  # Wait for reset to clear

    dut._log.info("FIFO Reset Complete")

    # WRITE operation
    dut.ui_in.value = 0b00010100  # Write Enable + Data = 4'b0100 (decimal 4)
    await ClockCycles(dut.clk, 1)  # One clock cycle
    dut.ui_in.value = 0b00000000  # Disable write

    dut._log.info("Write operation done")

    # READ operation
    await ClockCycles(dut.clk, 2)  # Wait a bit before reading
    dut.ui_in.value = 0b00001000  # Read Enable
    await ClockCycles(dut.clk, 1)  # One clock cycle
    dut.ui_in.value = 0b00000000  # Disable read

    dut._log.info(f"Read operation done, Output: {dut.uo_out.value}")

    # Check the output value
    assert (dut.uo_out.value & 0b00111100) >> 2 == 4, "FIFO Read Error!"

    dut._log.info("FIFO Test Passed!")
