# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


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
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Testing FIFO write and read operations")

    # Write data into FIFO
    for i in range(8):
        dut.ui_in.value = (i << 4) | 0b00000100  # Data + write enable
        await ClockCycles(dut.clk, 1)
        dut.ui_in.value = 0  # Deassert write
        await ClockCycles(dut.clk, 1)

    # Check full condition
    assert dut.uo_out.value & 0b00000001, "FIFO should be full after writing 8 values"
    dut._log.info("FIFO is full")

    # Read data from FIFO
    for i in range(8):
        dut.ui_in.value = 0b00001000  # Read enable
        await ClockCycles(dut.clk, 1)
        dut.ui_in.value = 0  # Deassert read
        await ClockCycles(dut.clk, 1)
    
    # Check empty condition
    assert dut.uo_out.value & 0b00000010, "FIFO should be empty after reading all values"
    dut._log.info("FIFO is empty after all reads")

    # Additional Read-Write mixed operations
    dut._log.info("Testing alternating write and read operations")
    for i in range(4):
        # Write operation
        dut.ui_in.value = (i << 4) | 0b00000100  # Data + write enable
        await ClockCycles(dut.clk, 1)
        dut.ui_in.value = 0  # Deassert write
        await ClockCycles(dut.clk, 1)

        # Read operation
        dut.ui_in.value = 0b00001000  # Read enable
        await ClockCycles(dut.clk, 1)
        dut.ui_in.value = 0  # Deassert read
        await ClockCycles(dut.clk, 1)
    dut._log.info("Completed alternating write and read operations")
