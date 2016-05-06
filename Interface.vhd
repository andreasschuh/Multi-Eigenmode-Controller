----------------------------------------------------------------------------------
-- Company: MIT
-- Engineer: Andreas Schuh
-- Top level design

----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED;

library UNISIM;
use UNISIM.VComponents.all;

entity interface is
	port(	--clocks: 100 MHz and 24 MHz for Spartan 3A DSP
		cmos_clk : in std_logic;
		cmos24_clk : in std_logic;
		
		--DAC Interface
	      -- *removed*
			
		--ADC interace:
			-- *removed*
		);
end interface;

architecture Behavioral of interface is

  component ADC
		port(	
			ADC1out	: out std_logic_vector(15 downto 0):=(others=>'0');	
			ADC2out	: out std_logic_vector(15 downto 0):=(others=>'0');		

			-- *rest removed* 
		
		);
	END COMPONENT;
		
	component DAC
		port(	
			DAC1in	: in std_logic_vector(15 downto 0):=(others=>'0');
			DAC2in	: in std_logic_vector(15 downto 0):=(others=>'0');
		
			-- *rest removed*
		);
	end component;

	COMPONENT FloatToFixed -- Floating point to fixed point conversion component, from XILINX IP Core library
		PORT (
			a : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			clk : IN STD_LOGIC;
			result : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT FixedToFloat -- Fixed point to floating point conversion component, from XILINX IP Core library
		PORT (
			a : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			clk : IN STD_LOGIC;
			result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
		END COMPONENT;

	COMPONENT compensator -- main component with compensator calculation, see separate file
		Port (
				ADC1in : in  STD_LOGIC_VECTOR (31 downto 0);
				ADC2in : in  STD_LOGIC_VECTOR (31 downto 0);
				DAC1out : out  STD_LOGIC_VECTOR (31 downto 0);
				DAC2out : out  STD_LOGIC_VECTOR (31 downto 0);
				clock : in  STD_LOGIC
				);
	END COMPONENT;

	COMPONENT clock   -- DCM for slower clock rate generation
		PORT (
				U1_CLKIN_IN : IN std_logic;
				U1_RST_IN : IN std_logic;          
				U1_CLKDV_OUT : OUT std_logic;
				U1_CLKIN_IBUFG_OUT : OUT std_logic;
				U1_CLK0_OUT : OUT std_logic;
				U2_CLK0_OUT : OUT std_logic;
				U2_LOCKED_OUT : OUT std_logic
				);
	END COMPONENT;

	-- Some signals for ADCs and DACs removed

	signal add1				:  std_logic_vector(31 downto 0):="00000000000000000000000000000000"; 
	signal add2				:  std_logic_vector(31 downto 0):="00000000000000000000000000000000"; 
	signal resultfloat	:  std_logic_vector(31 downto 0):="00000000000000000000000000000000"; 
	signal resultfloat2	:  std_logic_vector(31 downto 0):="00000000000000000000000000000000"; 

	signal da1_in			:  std_logic_vector(15 downto 0):="0000000000000000"; 
	signal da2_in			:  std_logic_vector(15 downto 0):="0000000000000000";
	
	signal adc1_out		: std_logic_vector(15 downto 0);
	signal adc2_out		: std_logic_vector(15 downto 0);

	--  DCM Signals
	signal clock_divided	: std_logic;
	signal cmosbuff_clk	: std_logic;

	signal idac1ff			:  std_logic_vector(31 downto 0):="00000000000000000000000000000000";
	signal idac1ff2		:  std_logic_vector(31 downto 0):="00000000000000000000000000000000";
	signal idac1			:  std_logic_vector(31 downto 0):="00000000000000000000000000000000";
	
	signal idac2ff			:  std_logic_vector(31 downto 0):="00000000000000000000000000000000";
	signal idac2ff2		:  std_logic_vector(31 downto 0):="00000000000000000000000000000000";
	signal idac2			:  std_logic_vector(31 downto 0):="00000000000000000000000000000000";
	
	signal iadc1ff			:  std_logic_vector(31 downto 0):="00000000000000000000000000000000";
	signal iadc1ff2		:  std_logic_vector(31 downto 0):="00000000000000000000000000000000";
	signal iadc1			:  std_logic_vector(31 downto 0):="00000000000000000000000000000000";
	
	signal iadc2ff			:  std_logic_vector(31 downto 0):="00000000000000000000000000000000";
	signal iadc2ff2		:  std_logic_vector(31 downto 0):="00000000000000000000000000000000";
	signal iadc2			:  std_logic_vector(31 downto 0):="00000000000000000000000000000000";
	
	
	begin
	
 		DAC1: DAC PORT MAP(
			DAC1in => da1_in,  
			DAC2in => da2_in,
		
			-- *rest removed*
		);

		ADC1: ADC
			ADC1out => adc1_out,
			ADC2out => adc2_out,

			-- *rest removed*
		);

		Fixed1 : FixedToFloat
			PORT MAP (
				a => adc1_out,
				clk => cmosbuff_clk,
				result => iadc1 
			);
  
		Fixed2 : FixedToFloat
			PORT MAP (
				a => adc2_out,
				clk => cmosbuff_clk, -
				result => iadc2 
			);
  
		Float1 : FloatToFixed
			PORT MAP (
			a => idac1,
			clk => cmosbuff_clk, 
			result => da1_in
			);
  
		Float2 : FloatToFixed
			PORT MAP (
				a => idac2,
				clk => cmosbuff_clk,
				result => da2_in
			);
  
		-- main Compensator component
		compensator1 : compensator
			PORT MAP ( 
				ADC1in => add1,
				ADC2in => add2,
				DAC1out => resultfloat,
				DAC2out => resultfloat2,
				clock => clock_divided
			);
	 
		Inst_clock: clock 
			PORT MAP(
				U1_CLKIN_IN => cmos_clk,
				U1_RST_IN => '0',
				U1_CLKDV_OUT => clock_divided, 
				U1_CLKIN_IBUFG_OUT => open, 
				U1_CLK0_OUT => cmosbuff_clk,  
				U2_CLK0_OUT => open,
				U2_LOCKED_OUT => open
			);
	
		-- FF Buffering result/output of compensator
		process (cmosbuff_clk)
			begin
				if(cmosbuff_clk'event and cmosbuff_clk='1') then
					idac1ff <= resultfloat;
					idac1ff2 <= idac1ff;
					idac1 <= idac1ff2;
	
					idac2ff <= resultfloat2;
					idac2ff2 <= idac2ff;
					idac2 <= idac2ff2;	
				end if;
		end process;
	
		-- FF Buffering
		process (clock_divided)
			begin
				if(clock_divided'event and clock_divided='1') then
					iadc1ff <= iadc1;
					iadc1ff2 <= iadc1ff;
					add1 <= iadc1ff2;
	
					iadc2ff <= iadc2;
					iadc2ff2 <= iadc2ff;
					add2 <= iadc2ff2;	
			end if;
		end process;

end Behavioral;