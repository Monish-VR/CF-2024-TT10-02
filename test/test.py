import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_fifo_operations(dut):
    """Test FIFO by writing and reading back values."""
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset the FIFO
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 5)
    
    # Verify FIFO is empty
    assert int(dut.uo_out.value) == 0, "FIFO should be empty after reset"
    
    # Define test data
    test_data = [0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8]
    
    # Write data into FIFO
    for data in test_data:
        dut.ui_in.value = (data << 4) | 0x04  # Writing data with write enable
        await ClockCycles(dut.clk, 1)
        dut.ui_in.value = 0x00  # Deassert write enable
        await ClockCycles(dut.clk, 1)
    
    # Read data from FIFO and check values
    for expected in test_data:
        dut.ui_in.value = 0x08  # Read enable
        await ClockCycles(dut.clk, 2)
        assert int(dut.uo_out.value) == expected, f"Expected {expected}, got {int(dut.uo_out.value)}"
        dut.ui_in.value = 0x00  # Deassert read enable
        await ClockCycles(dut.clk, 1)
    
    # Verify FIFO is empty after reads
    assert int(dut.uo_out.value) == 0, "FIFO should be empty after all reads"
