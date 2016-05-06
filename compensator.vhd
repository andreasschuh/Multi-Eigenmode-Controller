----------------------------------------------------------------------------------
-- Company: Grad School
-- Engineer: Andreas Schuh
-- 
-- Create Date:    20:14:04 02/07/2013 
-- Design Name: 	 
-- Module Name:    Statemachine - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--ENTITY
entity SystemID is
    Port ( ADC1in : in  STD_LOGIC_VECTOR (31 downto 0);
           ADC2in : in  STD_LOGIC_VECTOR (31 downto 0);
           DAC1out : out  STD_LOGIC_VECTOR (31 downto 0);
			  DAC2out : out  STD_LOGIC_VECTOR (31 downto 0);
           clock : in  STD_LOGIC);
end SystemID;


-- ARCHITECTURE
architecture Behavioral of SystemID is
 
------------------------------------------------------------------------------
-- DECLARE Compensator Parameters HERE - From MATLAB generated file
------------------------------------------------------------------------------

constant a11 : std_logic_vector := "00111111011111101000001010110010";
constant a12 : std_logic_vector := "00111101110110001001011101011111";
constant a21 : std_logic_vector := "10111101110110001001011101011111";
constant a22 : std_logic_vector := "00111111011111101000001010110010";
constant a33 : std_logic_vector := "00111111010011110100100101011111";
constant a34 : std_logic_vector := "00111111000101011100110100100011";
constant a43 : std_logic_vector := "10111111000101011100110100100011";
constant a44 : std_logic_vector := "00111111010011110100100101011111";
constant b1 : std_logic_vector := "10111011100101011111001010000110";
constant b2 : std_logic_vector := "00111100010101100110011000100000";
constant b3 : std_logic_vector := "10111011011001000111010100110001";
constant b4 : std_logic_vector := "10111100110010111000011111101011";
constant c1 : std_logic_vector := "00111100010101100010100101100000";
constant c2 : std_logic_vector := "10111011100101010110010010000101";
constant c3 : std_logic_vector := "10111100110010110101101110110001";
constant c4 : std_logic_vector := "10111011011001111000101100010100";
constant k1 : std_logic_vector := "10111101010100011110001110111000";
constant k2 : std_logic_vector := "00111101111000111001100001101000";
constant k3 : std_logic_vector := "00111101101000010100111110001011";
constant k4 : std_logic_vector := "10111110000110110101100011110011";
constant l1 : std_logic_vector := "00111111101000100100001001100101";
constant l2 : std_logic_vector := "10111110100100111111011000000000";
constant l3 : std_logic_vector := "11000000000100100001111011010000";
constant l4 : std_logic_vector := "10111110111111101110100111111000";



-- COMPONENTS
COMPONENT AddFloat
  PORT (
    a : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    b : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    operation_nd : IN STD_LOGIC;
    operation_rfd : OUT STD_LOGIC;
    result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    underflow : OUT STD_LOGIC;
    overflow : OUT STD_LOGIC;
    invalid_op : OUT STD_LOGIC;
    rdy : OUT STD_LOGIC
  );
END COMPONENT;

COMPONENT MultFloat
  PORT (
    a : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    b : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    operation_nd : IN STD_LOGIC;
    operation_rfd : OUT STD_LOGIC;
    result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    underflow : OUT STD_LOGIC;
    overflow : OUT STD_LOGIC;
    invalid_op : OUT STD_LOGIC;
    rdy : OUT STD_LOGIC
  );
END COMPONENT;

COMPONENT SubFloat
  PORT (
    a : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    b : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    operation_nd : IN STD_LOGIC;
    operation_rfd : OUT STD_LOGIC;
    result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    underflow : OUT STD_LOGIC;
    overflow : OUT STD_LOGIC;
    invalid_op : OUT STD_LOGIC;
    rdy : OUT STD_LOGIC
  );
END COMPONENT;

-- for non Trimming
attribute KEEP : string;
attribute S        : string;

-- SIGNALS
signal mult1a : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal mult1b : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal result_mult1 : STD_LOGIC_VECTOR(31 DOWNTO 0);

signal mult2a : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal mult2b : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal result_mult2 : STD_LOGIC_VECTOR(31 DOWNTO 0);

signal mult3a : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal mult3b : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal result_mult3 : STD_LOGIC_VECTOR(31 DOWNTO 0);

signal mult4a : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal mult4b : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal result_mult4 : STD_LOGIC_VECTOR(31 DOWNTO 0);

signal add1a : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal add1b : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal result_add1 : STD_LOGIC_VECTOR(31 DOWNTO 0);

signal add2a : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal add2b : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal result_add2 : STD_LOGIC_VECTOR(31 DOWNTO 0);

signal add3a : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal add3b : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal result_add3 : STD_LOGIC_VECTOR(31 DOWNTO 0);

signal add4a : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal add4b : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal result_add4 : STD_LOGIC_VECTOR(31 DOWNTO 0);

signal sub1a : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal sub1b : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal result_sub1 : STD_LOGIC_VECTOR(31 DOWNTO 0);

signal vresult: std_logic_vector(31 downto 0);
signal vX1 : STD_LOGIC_VECTOR(31 DOWNTO 0) 				:= (others => '0');
signal vX2 : STD_LOGIC_VECTOR(31 DOWNTO 0)					:= (others => '0');
signal vX3 : STD_LOGIC_VECTOR(31 DOWNTO 0)					:= (others => '0');
signal vX4 : STD_LOGIC_VECTOR(31 DOWNTO 0)					:= (others => '0');
signal vKX : STD_LOGIC_VECTOR(31 DOWNTO 0)					:= (others => '0');
signal vCX : STD_LOGIC_VECTOR(31 DOWNTO 0)					:= (others => '0');
signal vRminusKX : STD_LOGIC_VECTOR(31 DOWNTO 0)			:= (others => '0');
signal vSensorMinusCX : STD_LOGIC_VECTOR(31 DOWNTO 0)	:= (others => '0');
signal vInter_add1 : STD_LOGIC_VECTOR(31 DOWNTO 0)		:= (others => '0');
signal vInter_add2 : STD_LOGIC_VECTOR(31 DOWNTO 0)		:= (others => '0');
signal vInter_add3 : STD_LOGIC_VECTOR(31 DOWNTO 0)		:= (others => '0');
signal vInter_add4 : STD_LOGIC_VECTOR(31 DOWNTO 0)		:= (others => '0');
signal vInter_misc1 : STD_LOGIC_VECTOR(31 DOWNTO 0)		:= (others => '0');
signal vInter_misc2 : STD_LOGIC_VECTOR(31 DOWNTO 0)		:= (others => '0');

signal operation_nd1 : STD_LOGIC;
signal operation_nd2 : STD_LOGIC;
signal operation_nd3 : STD_LOGIC;
signal operation_nd4 :  STD_LOGIC;
signal operation_nd5 : STD_LOGIC;
signal operation_nd6 : STD_LOGIC;
signal operation_nd7 :  STD_LOGIC;
signal operation_nd8 : STD_LOGIC;
signal operation_nd9 : STD_LOGIC;

signal ADCbuff : STD_LOGIC_VECTOR(31 DOWNTO 0);


-- STATE DEFINITIONS
type state_type is (Zero,One,Two,Three,Four,Five,Six,Seven,Eight,Nine);
signal state : state_type;

-- BEGIN 
begin

-- INSTANTIATION OF COMPONENTS
AddFloat1 : AddFloat
  PORT MAP (
    a => add1a,
    b => add1b,
    operation_nd => operation_nd1,
    operation_rfd => open,
    result => result_add1,
    underflow => open,
    overflow => open,
    invalid_op => open,
    rdy => open
  );
  
AddFloat2 : AddFloat
  PORT MAP (
    a => add2a,
    b => add2b,
    operation_nd => operation_nd2,
    operation_rfd => open,
    result => result_add2,
    underflow => open,
    overflow => open,
    invalid_op => open,
    rdy => open
  );
  
AddFloat3 : AddFloat
  PORT MAP (
    a => add3a,
    b => add3b,
    operation_nd => operation_nd3,
    operation_rfd => open,
    result => result_add3,
    underflow => open,
    overflow => open,
    invalid_op => open,
    rdy => open
  );
AddFloat4 : AddFloat
  PORT MAP (
    a => add4a,
    b => add4b,
    operation_nd => operation_nd4,
    operation_rfd => open,
    result => result_add4,
    underflow => open,
    overflow => open,
    invalid_op => open,
    rdy => open
  );
  
MultFloat1 : MultFloat
  PORT MAP (
    a => mult1a,
    b => mult1b,
    operation_nd => operation_nd5,
    operation_rfd => open,
    result => result_mult1,
    underflow => open,
    overflow => open,
    invalid_op => open,
    rdy => open
  );
  
MultFloat2 : MultFloat
  PORT MAP (
    a => mult2a,
    b => mult2b,
    operation_nd => operation_nd6,
    operation_rfd => open,
    result => result_mult2,
    underflow => open,
    overflow => open,
    invalid_op => open,
    rdy => open
  );
  
MultFloat3 : MultFloat
  PORT MAP (
    a => mult3a,
    b => mult3b,
    operation_nd => operation_nd7,
    operation_rfd => open,
    result => result_mult3,
    underflow => open,
    overflow => open,
    invalid_op => open,
    rdy => open
  );

MultFloat4 : MultFloat
  PORT MAP (
    a => mult4a,
    b => mult4b,
    operation_nd => operation_nd8,
    operation_rfd => open,
    result => result_mult4,
    underflow => open,
    overflow => open,
    invalid_op => open,
    rdy =>open
  );
  
SubFloat1: SubFloat
  PORT MAP (
    a => sub1a,
    b => sub1b,
    operation_nd => operation_nd9,
    operation_rfd => open,
    result => result_sub1,
    underflow => open,
    overflow => open,
    invalid_op => open,
    rdy => open
  );


-- SERIAL, SYNCHRONOUS PROCESS
-- All of the state machine is synchronous, no asyn. (combinatorial) code
process (clock)

begin
  if(clock'event and clock='1') then
     	-- Default values for signal, to enforce full assigment.
		mult1a 			<=		(others => '0'); 
		mult1b 			<=		(others => '0'); 
		mult2a 			<=		(others => '0'); 
		mult2b 			<= 	(others => '0'); 
		mult3a 			<=		(others => '0'); 
		mult3b 			<=		(others => '0'); 
		mult4a 			<=		(others => '0'); 
		mult4b 			<=		(others => '0'); 
		add1a 			<=		(others => '0'); 
		add1b 			<=		(others => '0'); 
		add2a 			<=		(others => '0'); 
		add2b 			<=		(others => '0'); 
		add3a 			<=		(others => '0');
		add3b 			<=		(others => '0');
		add4a 			<=		(others => '0');
		add4b 			<=		(others => '0');
		sub1a 			<=		(others => '0');
		sub1b 			<=		(others => '0');

		vresult			<=		vresult;
		vX1 				<=		vX1;
		vX2				<=		vX2;
		vX3				<=		vX3;
		vX4				<=		vX4;
		vKX				<=		vKX;
		vCX				<=		vCX;
		vRminusKX		<=		vRminusKX;
		vSensorMinusCX	<=		vSensorMinusCX;
		vInter_add1		<=		vInter_add1;
		vInter_add2		<=		vInter_add2;
		vInter_add3		<=		vInter_add3;
		vInter_add4		<=		vInter_add4;
		vInter_misc1	<=		vInter_misc1;
		vInter_misc2	<=		vInter_misc2;
		
		operation_nd1 <=	'0';
		operation_nd2 <=	'0';
		operation_nd3 <=	'0';
		operation_nd4 <=	'0';
		operation_nd5 <=	'0';
		operation_nd6 <=	'0';
		operation_nd7 <=	'0';
		operation_nd8 <=	'0';
		operation_nd9 <=	'0';

		DAC1out        <= 	vRminusKX;
		DAC2out        <= 	vCX; 
		
		state <= state;
		
		-- START STATE MACHINE 
		case state is
		
			when Zero =>
			
				mult1a 			<=		(others => '0');
				mult1b 			<=		(others => '0');
				mult2a 			<=		(others => '0');
				mult2b 			<= 	(others => '0');
				mult3a 			<=		(others => '0');
				mult3b 			<=		(others => '0');
				mult4a 			<=		(others => '0');
				mult4b 			<=		(others => '0');
				add1a 			<=		(others => '0');
				add1b 			<=		(others => '0');
				add2a 			<=		(others => '0');
				add2b 			<=		(others => '0');
				add3a 			<=		(others => '0');
				add3b 			<=		(others => '0');
				add4a 			<=		(others => '0');
				add4b 			<=		(others => '0');
				sub1a 			<=		(others => '0');
				sub1b 			<=		(others => '0');

				vresult			<=		(others => '0');
				vX1 				<=		(others => '0');
				vX2				<=		(others => '0');
				vX3				<=		(others => '0');
				vX4				<=		(others => '0');
				vKX				<=		(others => '0');
				vCX				<=		(others => '0');
				vRminusKX		<=		(others => '0');
				vSensorMinusCX	<=		(others => '0');
				vInter_add1		<=		(others => '0');
				vInter_add2		<=		(others => '0');
				vInter_add3		<=		(others => '0');
				vInter_add4		<=		(others => '0');
				vInter_misc1	<=		(others => '0');
				vInter_misc2	<=		(others => '0');
				DAC1out        <= 	(others => '0');
				DAC2out        <= 	(others => '0');
				
				operation_nd1 <=		'0';
				operation_nd2 <=		'0';
				operation_nd3 <=		'0';
				operation_nd4 <=		'0';
				operation_nd5 <=		'0';
				operation_nd6 <=		'0';
				operation_nd7 <=		'0';
				operation_nd8 <=		'0';
				operation_nd9 <=		'0';
		
				state <= One;
				
			when One =>
			
				add1a <= (others=>'0');
				add1b <= (others=>'0');
				operation_nd1 <= '0';
				--vInter_misc1 := result_add1;	
				
				add2a <= (others=>'0');
				add2b <= (others=>'0');
				operation_nd2 <= '0';
				--vInter_misc2 := result_add2;
				
				add3a <= (others=>'0');
				add3b <= (others=>'0');
				operation_nd3 <= '0';
				
				add4a <= (others=>'0');
				add4b <= (others=>'0');
				operation_nd4 <= '0';
				
				mult1a <= vX1;
				mult1b <= c1;
				operation_nd5 <= '1';
				
				mult2a <= vX2;
				mult2b <= c2;
				operation_nd6 <= '1';
				
				mult3a <= vX3;
				mult3b <= c3;
				operation_nd7 <= '1';
				
				mult4a <= vX4;
				mult4b <= c4;
				operation_nd8 <= '1';
				
				sub1a <= ADC1in;
				sub1b <= result_add1;
				vKX <= result_add1;
				operation_nd9 <= '1';
				
				state <= Two;

				
			when Two =>
				
				add1a <= result_mult1;
				add1b <= result_mult2;
				operation_nd1 <= '1';
				
				add2a <= result_mult3;
				add2b <= result_mult4;
				operation_nd2 <= '1';
				
				add3a <= (others=>'0');
				add3b <= (others=>'0');
				operation_nd3 <= '0';
				
				add4a <= (others=>'0');
				add4b <= (others=>'0');
				operation_nd4 <= '0';
						
				mult1a <= vX1;
				mult1b <= a11;
				operation_nd5 <= '1';
				
				mult2a <= vX2;
				mult2b <= a12;
				operation_nd6 <= '1';
				
				mult3a <= vX1;
				mult3b <= a21;
				operation_nd7 <= '1';
				
				mult4a <= vX2;
				mult4b <= a22;
				operation_nd8 <= '1';
				
				vRminusKX <= result_sub1;

				sub1a <= (others => '0');
				sub1b <= (others => '0');
				operation_nd9 <= '0';
				
				state <= Three;
		
		
			when Three =>

				add1a <= result_mult1;
				add1b <= result_mult2;
				operation_nd1 <= '1';
				
				add2a <= result_mult3;
				add2b <= result_mult4;
				operation_nd2 <= '1';
				
				add3a <= result_add1;
				add3b <= result_add2;
				operation_nd3 <= '1';
				
				add4a <= (others=>'0');
				add4b <= (others=>'0');
				operation_nd4 <= '0';

				mult1a <= vX3;
				mult1b <= a33;
				operation_nd5 <= '1';
				
				mult2a <= vX4;
				mult2b <= a34;
				operation_nd6 <= '1';
				
				mult3a <= vX3;
				mult3b <= a43;
				operation_nd7 <= '1';
				
				mult4a <= vX4;
				mult4b <= a44;
				operation_nd8 <= '1';
				
				sub1a <= (others => '0');
				sub1b <= (others => '0');
				operation_nd9 <= '0';
				
				state <= Four;		
		
		
			when Four =>

				add1a <= result_mult1;
				add1b <= result_mult2;
				operation_nd1 <= '1';
				vX1 <= result_add1;	
				
				add2a <= result_mult3;
				add2b <= result_mult4;
				operation_nd2 <= '1';
				vX2 <= result_add2;

				add3a <= (others=>'0');
				add3b <= (others=>'0');
				operation_nd3 <= '0';
				
				add4a <= (others=>'0');
				add4b <= (others=>'0');
				operation_nd4 <= '0';

				mult1a <= vRminusKX;
				mult1b <= b1;
				operation_nd5 <= '1';
				
				mult2a <= vRminusKX;
				mult2b <= b2;
				operation_nd6 <= '1';
				
				mult3a <= vRminusKX;
				mult3b <= b3;
				operation_nd7 <= '1';
				
				mult4a <= vRminusKX;
				mult4b <= b4;
				operation_nd8 <= '1';
				
				sub1a <= ADC2in; 
				sub1b <= result_add3; 
				operation_nd9 <= '1';
				vCX	<= result_add3;

				state <= Five;			
		
		
			when Five =>

				add1a <= vX1;
				add1b <= result_mult1;
				operation_nd1 <= '1';	
				
				add2a <= vX2;
				add2b <= result_mult2;
				operation_nd2 <= '1';
				
				add3a <= result_add1;
				add3b <= result_mult3;
				vX3 <= result_add1;
				operation_nd3 <= '1';
				
				add4a <= result_add2;
				add4b <= result_mult4;
				vX4 <= result_add2;
				operation_nd4 <= '1';

				vSensorMinusCX <= result_sub1;
				mult1a <= result_sub1;
				mult1b <= l1;
				operation_nd5 <= '1';
				
				mult2a <= result_sub1;
				mult2b <= l2;
				operation_nd6 <= '1';
				
				mult3a <= result_sub1;
				mult3b <= l3;
				operation_nd7 <= '1';
				
				mult4a <= result_sub1;
				mult4b <= l4;
				operation_nd8 <= '1';
				
				sub1a <= (others => '0');
				sub1b <= (others => '0');
				operation_nd9 <= '0';
					
				state <= Six;
				

			when Six =>

				add1a <= result_add1;
				add1b <= result_mult1;
				operation_nd1 <= '1';
				vX1 <= result_add1;	
				
				add2a <= result_add2;
				add2b <= result_mult2;
				operation_nd2 <= '1';
				vX2 <= result_add2;
				
				add3a <= result_add3;
				add3b <= result_mult3;
				operation_nd3 <= '1';
				vX3 <= result_add3;
				
				add4a <= result_add4;
				add4b <= result_mult4;
				operation_nd4 <= '1';
				vX4 <= result_add4;	
				
				
				mult1a <= (others => '0');
				mult1b <= (others => '0');
				operation_nd5 <= '0';
				
				mult2a <= (others => '0');
				mult2b <= (others => '0');
				operation_nd6 <= '0';
				
				mult3a <= (others => '0');
				mult3b <= (others => '0');
				operation_nd7 <= '0';
				
				mult4a <= (others => '0');
				mult4b <= (others => '0');
				operation_nd8 <= '0';
				
				sub1a <= (others => '0');
				sub1b <= (others => '0');
				operation_nd9 <= '0';			

				state <= Seven;
				
				
			when Seven =>
			
				vX1 <= result_add1;
				vX2 <= result_add2;
				vX3 <= result_add3;
				vX4 <= result_add4;
				
				add1a <= (others=>'0');
				add1b <= (others=>'0');
				operation_nd1 <= '0';
				
				add2a <= (others=>'0');
				add2b <= (others=>'0');
				operation_nd2 <= '0';
				
				add3a <= (others=>'0');
				add3b <= (others=>'0');
				operation_nd3 <= '0';
				
				add4a <= (others=>'0');
				add4b <= (others=>'0');
				operation_nd4 <= '0';

				mult1a <= result_add1;
				mult1b <= k1;
				operation_nd5 <= '1';
				
				mult2a <= result_add2;
				mult2b <= k2;
				operation_nd6 <= '1';
				
				mult3a <= result_add3;
				mult3b <= k3;
				operation_nd7 <= '1';
				
				mult4a <= result_add4;
				mult4b <= k4;
				operation_nd8 <= '1';

				sub1a <= (others => '0');
				sub1b <= (others => '0');
				operation_nd9 <= '0';	

				state <= Eight;
				
				
			when Eight =>

				add1a <= result_mult1;
				add1b <= result_mult2;
				operation_nd1 <= '1';
				
				add2a <= result_mult3;
				add2b <= result_mult4;
				operation_nd2 <= '1';

				add3a <= (others=>'0');
				add3b <= (others=>'0');
				operation_nd3 <= '0';
				
				add4a <= (others=>'0');
				add4b <= (others=>'0');
				operation_nd4 <= '0';

				mult1a <= (others => '0');
				mult1b <= (others => '0');
				operation_nd5 <= '0';
				
				mult2a <= (others => '0');
				mult2b <= (others => '0');
				operation_nd6 <= '0';
				
				mult3a <= (others => '0');
				mult3b <= (others => '0');
				operation_nd7 <= '0';
				
				mult4a <= (others => '0');
				mult4b <= (others => '0');
				operation_nd8 <= '0';
				
				sub1a <= (others => '0');
				sub1b <= (others => '0');
				operation_nd9 <= '0';	

				
				state <= Nine;
				
				
			when Nine =>

				add1a <= result_add1;
				add1b <= result_add2;
				operation_nd1 <= '1';
				
				add2a <= (others=>'0');
				add2b <= (others=>'0');
				operation_nd2 <= '0';
				
				add3a <= (others=>'0');
				add3b <= (others=>'0');
				operation_nd3 <= '0';
				
				add4a <= (others=>'0');
				add4b <= (others=>'0');
				operation_nd4 <= '0';

				mult1a <= (others => '0');
				mult1b <= (others => '0');
				operation_nd5 <= '0';
				
				mult2a <= (others => '0');
				mult2b <= (others => '0');
				operation_nd6 <= '0';
				
				mult3a <= (others => '0');
				mult3b <= (others => '0');
				operation_nd7 <= '0';
				
				mult4a <= (others => '0');
				mult4b <= (others => '0');
				operation_nd8 <= '0';
				
				sub1a <= (others => '0');
				sub1b <= (others => '0');	
				operation_nd9 <= '0';
				
				state <= One;
			
			when others =>
				
				mult1a 			<=		(others => '0');
				mult1b 			<=		(others => '0');
				mult2a 			<=		(others => '0');
				mult2b 			<= 	(others => '0');
				mult3a 			<=		(others => '0');
				mult3b 			<=		(others => '0');
				mult4a 			<=		(others => '0');
				mult4b 			<=		(others => '0');
				add1a 			<=		(others => '0');
				add1b 			<=		(others => '0');
				add2a 			<=		(others => '0');
				add2b 			<=		(others => '0');
				add3a 			<=		(others => '0');
				add3b 			<=		(others => '0');
				add4a 			<=		(others => '0');
				add4b 			<=		(others => '0');
				sub1a 			<=		(others => '0');
				sub1b 			<=		(others => '0');

				vresult			<=		(others => '0');
				vX1 				<=		(others => '0');
				vX2				<=		(others => '0');
				vX3				<=		(others => '0');
				vX4				<=		(others => '0');
				vKX				<=		(others => '0');
				vCX				<=		(others => '0');
				vRminusKX		<=		(others => '0');
				vSensorMinusCX	<=		(others => '0');
				vInter_add1		<=		(others => '0');
				vInter_add2		<=		(others => '0');
				vInter_add3		<=		(others => '0');
				vInter_add4		<=		(others => '0');
				vInter_misc1	<=		(others => '0');
				vInter_misc2	<=		(others => '0');
				DAC1out        <= 	(others => '0');
				DAC2out        <= 	(others => '0');
				
				operation_nd1 <=		'0';
				operation_nd2 <=		'0';
				operation_nd3 <=		'0';
				operation_nd4 <=		'0';
				operation_nd5 <=		'0';
				operation_nd6 <=		'0';
				operation_nd7 <=		'0';
				operation_nd8 <=		'0';
				operation_nd9 <=		'0';
				
				
				state <= One;
					
		end case;

end if; 
end process;

end Behavioral;

