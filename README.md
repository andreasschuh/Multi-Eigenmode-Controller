# Multi-Eigenmode-Controller
Hardware controller for eigenmode modification of mechanical cantilever shaped resonators

A digital FPGA implementation of a state space controller - or compensator, as it also consists of an estimator - for the modification of mechanical cantilever shaped resonators. Implemented and tested in two FPGA platforms with 100MHz ADCs and DACs:

1) Trenz Electronic with a Spartan-3A DSP, placed on a custom Hardware board equipped with 100MHz converters and configured with VHDL.     -> maximum feedback loop rate = 2.8 MHz.

2) National Instruments (NI) FlexRIO PXI-7954R board equipped with a Virtex 5 LX-110 FPGA and programmed with NI LabVIEW FPGA. A Baseband Transceiver 5781 with 100MHz ADCs/DACs is externally connected.
  -> maximum feedback loop rate = 5.8 MHz.

The code uses a state machine structure and floating point representation for efficient and high dynamic data processing. 

For more Detail:

http://dx.doi.org/10.1088/0957-4484/26/23/235706

http://dx.doi.org/10.1109/ACC.2015.7171011

http://www.db-thueringen.de/servlets/DocumentServlet?id=27053

