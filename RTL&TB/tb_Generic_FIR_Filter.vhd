library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE std.textio.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;

entity tb_FP32_FIR_Filter is
    GENERIC (
        FIR_tab : INTEGER := 50
    );
end tb_FP32_FIR_Filter;

architecture Behavioral of tb_FP32_FIR_Filter is
    COMPONENT FP32_FIR_Filter IS
    generic (
        FIR_tab    : INTEGER := 50
    );
    port (
        clk			    : in std_logic;
        rst			    : in std_logic;
        datain_i		: in std_logic_vector (31 downto 0);
        datavalid_i	    : in std_logic;
        dataout_o		: out std_logic_vector (31 downto 0);
        dataready_o	    : out std_logic
    );
    END COMPONENT;
    SIGNAL clk              : STD_LOGIC                     := '1';
    SIGNAL rst              : STD_LOGIC                     := '0';
    SIGNAL datavalid_i       : STD_LOGIC                     := '0';
    SIGNAL datain_i          : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dataout_o         : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dataready_o        : STD_LOGIC                    := '0';
    CONSTANT C_FILE_NAME_RD : STRING                         := "C:/intelFPGA_lite/18.0/PROJE/FIR_DENEME_IP/sig_noisy.txt";
	 constant C_FILE_NAME_WR :string  						 := "C:/intelFPGA_lite/18.0/PROJE/FIR_DENEME_IP/filtered_out_noisy.txt";

	 
	 begin

    clk <= NOT clk AFTER 5 ns;

dut : PROCESS
		  variable VEC_LINE_WR : line;
		  variable VEC_VAR_WR : std_logic_vector (31 downto 0);
		  file VEC_FILE_WR : text open write_mode is C_FILE_NAME_WR;


        VARIABLE VEC_LINE_RD : line;
        VARIABLE VEC_VAR_RD  : STD_LOGIC_VECTOR (31 DOWNTO 0);
        FILE VEC_FILE_RD     : text OPEN read_mode IS C_FILE_NAME_RD;
      BEGIN
--        WAIT FOR 50 ns;
		  
			rst 	<= '1';
			wait for 100 ns;
			rst 	<= '0';
			wait for 100 ns;
	 
	 
        WHILE NOT endfile(VEC_FILE_RD) LOOP
            readline (VEC_FILE_RD, VEC_LINE_RD);
            hread (VEC_LINE_RD, VEC_VAR_RD);
            WAIT UNTIL falling_edge(clk);
            datain_i    <= VEC_VAR_RD;--(OTHERS => '1');
            datavalid_i <= '1';
            WAIT UNTIL falling_edge(CLK);
            datavalid_i <= '0';
            WAIT UNTIL rising_edge(dataready_o);
				
				hwrite(VEC_LINE_WR, dataout_o);
				writeline(VEC_FILE_WR,VEC_LINE_WR);
				wait for 10 ns;
--            WAIT UNTIL falling_edge(clk);
        END LOOP;

assert false
report "SIM DONE"
severity failure;
      END PROCESS;
    
    FP32_FIR_Filter_Inst : FP32_FIR_Filter
    GENERIC MAP(
        FIR_tab => FIR_tab
    )
    PORT MAP(
        clk        => clk,
        rst        => rst,
        datavalid_i => datavalid_i,
        datain_i    => datain_i,
        dataout_o   => dataout_o,
        dataready_o  => dataready_o
    );
end Behavioral;
