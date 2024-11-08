import logging
from cocotb.triggers import FallingEdge, RisingEdge, Timer
from cocotb.types.range import Range
from cocotb.types.array import Array
from cocotb.types.logic_array import LogicArray
import numpy as np
import inspect


class MaxIndexPipe:
    """UART base class"""

    def __init__(self, shotno, clock, start, input_array, 
                 done, max_value, max_idx, out_array, input_valid, threshold):
        import scipy.io
        import numpy as np
        self._shotno = shotno
        self.adc = scipy.io.loadmat(f"data_{self._shotno}.mat")["intensities"].T

        isfloat = 1
        if isinstance(self.adc[0,0], (np.floating, np.float64)):
            isfloat = 2**12/10
            self.adc = self.adc * isfloat
            self.adc = self.adc.astype(np.int16)


        self._version = "0.0.1"

        self.log = logging.getLogger(f"cocotb.{input_array._path}")
        self.log.info(f"adc= {self.adc[20]}")

        self._clock = clock
        self._start = start
        self._input_array = input_array
        self._max_idx = max_idx
        self._max_value = max_value
        self._done = done
        self._out_array = out_array
        self._input_valid = input_valid
        self._thresh = threshold

        self._clkedge = RisingEdge(self._clock)

    async def _wait_cycle(self, cyc = 1):
        for x in range(cyc):
            await self._clkedge

    async def _get_max_value(self, expecting = None):
        """Consume and check parity bit"""
        if expecting != self._max_value.value and expecting is not None:
            self.log.error("done mismatchg")
        if self._done.value == 0:
            self.log.error("tvalid not asserted")
            return

        self.log.info(self.log_prt(f"(readback): {self._max_value.value.integer} [{self._max_idx.value.integer}] {self._thresh.value.integer}"))
        self.log.info(self.log_prt(f"(array): {self.unpack_array_signed(self._out_array)}"))
        self.log.info(self.log_prt(f"(current): {self.max_adc} [{self.max_index}]"))
        #assert self._max_value.value.integer == self.max_adc
        #assert self._max_idx.value.integer == self.max_index
        return self._max_idx.value, self._max_value.value

    async def _wait_done(self, max_try = 100):
        self.log.info(self.log_prt(self.log_prt(f" {self._done.value}")))
        count = 0
        while self._done.value == 0:
            await self._wait_cycle(1)
            count = count + 1
            if count == max_try:
                self.log.error("Timed out")
                assert self._done.value == 1
                break
        self.log.info(f"Done waiting {self._done.value}")
        return self._done.value

    async def _get_done(self, expecting = None):
        if expecting != self._done.value and expecting is not None:
            self.log.error(self.log_prt(f"done mismatchg"))
        return self._done.value




    async def _send_data(self, idx):
        _adc = self.adc[idx] ## dimension = no of ADC Channel; unit = milimeters
        _adc[idx%10] = idx*10
        self.max_adc = np.max(_adc)
        self.max_index = np.where(_adc == self.max_adc)[0]
        i = 0;
        packed = self.pack_array_signed(_adc)
        self._input_array <= packed
        self._input_valid.value = 1
        await self._wait_cycle(1)
        self._input_valid.value = 0
        self.log.info(self.log_prt(f"array =  {packed}, y2 {_adc} start {self._start.value}"))

    async def _send_start(self, val=1):
        self._start.value = val
        await self._wait_cycle()
        assert self._start.value == val
        self.log.info(self.log_prt(f"send_start =  {val}"))


    def pack_array_signed(self, data, n = 10, no_bits = 16):
        packed = LogicArray(range=Range(n*no_bits-1, "downto", 0))
        i = 0
        for val in data:
            i = i + 1
            packed[int(i*no_bits-1): int(no_bits * (i-1))] = list('{0:016b}'.format(val))
        self.log.info(self.log_prt(f"packed {data} to {packed}", 2))
        return packed

    def unpack_array_signed(self, data, n = 10, nbits = 16):
        ret = []
        _data = LogicArray(data.value.binstr)
        for i in range(n):
            ret.append(_data[int(nbits*(i+1)-1):int(nbits*i)].integer) 
        self.log.info(self.log_prt(f"unpacked to {ret}", 2))
        return ret


    def log_prt(self, log, idx = 1):
        pstr = '{}()-> {}'.format(
            inspect.stack()[idx].function, log)
        return pstr


