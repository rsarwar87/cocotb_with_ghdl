import logging
import random
import cocotb
from MaxIndexPipeline import MaxIndexPipe
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

import logging
# Reset coroutine
async def reset_dut(reset_n, duration_ns):
    reset_n.value = 0
    await Timer(duration_ns, units="ns")
    reset_n.value = 1


@cocotb.test()
async def test_MaxIndexPipeline(dut):
    """ First simple test """

    clkedge = RisingEdge(dut.clk)

    dut._log.setLevel(logging.DEBUG)
    # Connect reset
    reset_n = dut.reset_n

    # Instantiate interpolation driver
    interpolation = MaxIndexPipe(50331, dut.clk, dut.en, 
            dut.input_array_t, dut.out_valid, dut.max_value, dut.max_index,
            dut.output_array_t, dut.input_valid, dut.theshold_out)

    # Drive input defaults (setimmediatevalue to avoid x asserts)
    dut.theshold_in.setimmediatevalue(22)
    dut.en.setimmediatevalue(0)

    clock = Clock(dut.clk, 10, units="ns")  # Create a 10 ns period clock
    cocotb.start_soon(clock.start())  # Start the clock

    # Execution will block until reset_dut has completed
    await reset_dut(reset_n, 100)
    dut._log.info("Released reset")


    await interpolation._wait_cycle(10)
    await interpolation._get_done()
    await interpolation._send_start(1)

    for i in range(20, 50):
        await interpolation._send_data(i) 
        await interpolation._get_max_value()


