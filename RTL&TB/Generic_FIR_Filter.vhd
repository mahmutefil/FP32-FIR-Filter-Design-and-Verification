library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.FIR_pkg.ALL;

entity FP32_FIR_Filter is
generic (
    FIR_tab    : INTEGER := c_filter_order
);
port (
    clk			    	: in std_logic;
    rst			    	: in std_logic;
    datain_i			: in std_logic_vector (31 downto 0);
    datavalid_i	   		: in std_logic;
    dataout_o			: out std_logic_vector (31 downto 0);
    dataready_o	   		: out std_logic
);
end FP32_FIR_Filter;

architecture Behavioral of FP32_FIR_Filter is


COMPONENT alpfp_mult_ins
	port (
			clk_en	:	IN  STD_LOGIC;
			clock	: IN STD_LOGIC ;
			dataa	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			datab	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			result	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);  
 END COMPONENT; 
 
COMPONENT altfp_add_inss
	port (
			clk_en	:	IN  STD_LOGIC;
			clock	: IN STD_LOGIC ;
			dataa	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			datab	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			result	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);  
 END COMPONENT; 
 
 
 -------------------------------------------------------------------------
     constant c_num_of_fpu : integer := 1;

    --FMA (Fused-Multiply-Add) IP Internals
    type mult_a_data_t 		is array (0 to c_num_of_fpu-1) of std_logic_vector(31 downto 0);
    type mult_b_data_t 		is array (0 to c_num_of_fpu-1) of std_logic_vector(31 downto 0);
    type mult_res_data_t 	is array (0 to c_num_of_fpu-1) of std_logic_vector(31 downto 0);	 
    type add_a_data_t 		is array (0 to c_num_of_fpu-1) of std_logic_vector(31 downto 0);
    type add_b_data_t 		is array (0 to c_num_of_fpu-1) of std_logic_vector(31 downto 0);	 
    type add_res_data_t 	is array (0 to c_num_of_fpu-1) of std_logic_vector(31 downto 0);	 
    type acc_dummy_data_t 	is array (0 to c_num_of_fpu-1) of std_logic_vector(31 downto 0);
     
    signal s_mult_start               : STD_LOGIC_VECTOR(c_num_of_fpu-1 downto 0) := (others => '0');
    signal s_mult_a_tdata             : mult_a_data_t 	:=((others=> (others=>'0')));
    signal s_mult_b_tdata             : mult_b_data_t 	:=((others=> (others=>'0')));
    signal m_mult_result_tdata        : mult_res_data_t 	:=((others=> (others=>'0')));
    
    signal dummy_reg_acc 				  : acc_dummy_data_t :=((others=> (others=>'0')));
    
	 
    --Addition IP Internals
    signal s_add_start                : STD_LOGIC_VECTOR(c_num_of_fpu-1 downto 0) := (others => '0'); 
    signal s_add_a_tdata              : add_a_data_t 		:=((others=> (others=>'0')));
    signal s_add_b_tdata              : add_b_data_t 		:=((others=> (others=>'0')));
    signal m_add_result_tdata         : add_res_data_t 	:=((others=> (others=>'0')));

    signal dummy_reg_add 				  : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	 
	 
	 --final sum
	 signal s_final_add_start          : STD_LOGIC := '0';
	 signal m_final_add_a_tdata        : STD_LOGIC_VECTOR(31 downto 0) := (others => '0'); 
	 signal m_final_add_b_tdata        : STD_LOGIC_VECTOR(31 downto 0) := (others => '0'); 
	 signal m_final_result_tdata       : STD_LOGIC_VECTOR(31 downto 0) := (others => '0'); 
	 
	 
 -------------------------------------------------------------------------

    signal s_wave_in : coeff_t :=  ((others=> (others=>'0')));

    type states is (IDLE, START_PROD, WAIT_PROD, START_SUM, WAIT_SUM, START_FINAL_SUM, WAIT_FINAL_SUM);
    signal state : states := IDLE;
    
    signal cntr  		: integer := 0;
	 signal cntr1 		: integer range 0 to c_num_of_fpu-1 := 0;
    signal mult_cntr : integer := 0;
	 signal add_cntr 	: integer := 0;

begin

Main_Proc: process(clk,rst)
begin
if rst = '1' then
    dataout_o   <= (others => '0');
    dataready_o <= '0';
else
    if (rising_edge(clk)) then
        case state is
            when IDLE =>
					if datavalid_i = '1' then
						s_wave_in(0)		 <= datain_i;
						s_wave_in(1 to c_filter_order)	<= s_wave_in(0 to c_filter_order-1);
						state 				 <= START_PROD;
						dummy_reg_add	    <= (others=>'0');				  
					else
						s_mult_start 		 <= (others => '0');
						dataready_o	       <= '0';
						cntr	             <= 0;
						mult_cntr 			 <= 0;
						add_cntr   			 <= 0;
					end if; 

				when START_PROD =>
					if (cntr < c_filter_order) then
						dataready_o		    <= '0';
						s_mult_start 		 <= (others => '1');	
						state 			    <= WAIT_PROD;
						
						for i in 0 to c_num_of_fpu-1 loop
							if(cntr < c_filter_order-c_num_of_fpu+1) then
								s_mult_a_tdata(i)   <= s_wave_in(cntr+i);
								s_mult_b_tdata(i)   <= coeff_s(cntr+i);					   
							end if;
						end loop;
					elsif (cntr = c_filter_order) then --cntr = c_filter_order+1
						cntr 	             <= 0;
						state              <= START_FINAL_SUM;--IDLE;
					else
						state	<= IDLE;
					end if;          
		
            when WAIT_PROD =>               
				    				 
                if (mult_cntr = 11) then  --time to finish single multiplication op
                    state <= START_SUM;
						  mult_cntr <= 0;
						  s_mult_start  <= (others => '0');
                else
                    state <= WAIT_PROD;
						  mult_cntr <= mult_cntr + 1;	
                end if;                         
            
            when START_SUM =>
					s_add_start    <= (others => '1');
					state          <= WAIT_SUM;
					for i in 0 to c_num_of_fpu-1 loop
						if(cntr < 50) then
							s_add_a_tdata(i)  <= dummy_reg_acc(i);
							s_add_b_tdata(i)  <= m_mult_result_tdata(i);				 
						end if;
					end loop;
                

            when WAIT_SUM =>
					if (add_cntr = 14) then  --time to finish single summation op
						cntr	      <= cntr + c_num_of_fpu;
						state       <= START_PROD;
						add_cntr    <= 0;
						s_add_start <= (others => '0');
						
						for i in 0 to c_num_of_fpu-1 loop
							dummy_reg_acc(i) <= m_add_result_tdata(i);
						end loop;
					else
						add_cntr    <= add_cntr + 1;
					end if;	
		 
			 
			   when START_FINAL_SUM =>
					s_final_add_start    <= '1';
					m_final_add_a_tdata  <= dummy_reg_acc(cntr1);
					m_final_add_b_tdata  <= dummy_reg_add;
					state          		<= WAIT_FINAL_SUM;
				
				
				when WAIT_FINAL_SUM =>
					if (add_cntr = 14) then
						if cntr1 = c_num_of_fpu-1 then
							state        			<= IDLE;
							dataready_o  			<= '1';
							dataout_o    			<= m_final_result_tdata; 
							cntr1        			<= 0;
							dummy_reg_acc		 	<= (others=> (others=>'0'));
							s_final_add_start   	<= '0';
						else
							state           		<= START_FINAL_SUM;
							cntr1           		<= cntr1+1;
							dummy_reg_add  		<= m_final_result_tdata;
							add_cntr     			<= 0;
						end if; 

					else
						add_cntr    <= add_cntr + 1;							
					end if;				
				
            
            when others =>
                state   <= IDLE;		
            
        end case;
    end if;
end if;
end process;



	 
fp32_fma : for i in 0 to c_num_of_fpu-1 generate

fp32_mult : alpfp_mult_ins
	port map (
		clk_en	 => s_mult_start(i), 
		clock     => clk,
		dataa	    => s_mult_a_tdata(i),	 
		datab		 => s_mult_b_tdata(i),
		result	 => m_mult_result_tdata(i) );  

fp32_add : altfp_add_inss
	port map (
		clk_en	 => s_add_start(i),
		clock     => clk,
		dataa	    => s_add_a_tdata(i),	 
		datab		 => s_add_b_tdata(i),
		result	 => m_add_result_tdata(i) );  
		
end generate;		


fp32_final_acc : altfp_add_inss
	port map (
		clk_en	 => s_final_add_start,
		clock	 	 => clk,
		dataa	 	 => m_final_add_a_tdata,
		datab	 	 => m_final_add_b_tdata,
		result	 => m_final_result_tdata ); 	
		


end Behavioral;
