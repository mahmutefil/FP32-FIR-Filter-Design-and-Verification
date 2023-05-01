library ieee;
use ieee.std_logic_1164.all;

package FIR_pkg is
    function clogb2 (depth: in natural) return integer;
    
    TYPE array2D32 IS ARRAY (NATURAL RANGE <>) OF STD_LOGIC_VECTOR(31 downto 0);

    constant c_filter_order : integer := 50;

    type coeff_t is array (0 to c_filter_order) of std_logic_vector(31 downto 0);
    constant coeff_s : coeff_t;
    
end FIR_pkg;

package body FIR_pkg is

function clogb2( depth : natural) return integer is
variable temp    : integer := depth;
variable ret_val : integer := 0;
begin
    while temp > 1 loop
        ret_val := ret_val + 1;
        temp    := temp / 2;
    end loop;
  	return ret_val;
end function;



---------------------

constant coeff_s : coeff_t := (
x"BA4521DE",
x"BB6523DC",
x"BB28E135",
x"BB419B40",
x"BAF95699",
x"389EF6D1",
x"3B3F7850",
x"3BC60609",
x"3C0CF61D",
x"3C1DCD70",
x"3C07C343",
x"3B876915",
x"BB2B0ADB",
x"BC331F11",
x"BC9C502D",
x"BCCB1B52",
x"BCD29091",
x"BCA2933D",
x"BBC9BBA0",
x"3C784663",
x"3D2DE6A8",
x"3D952A19",
x"3DD1EB35",
x"3E0279D7",
x"3E1378B2",
x"3E196F15",
x"3E1378B2",
x"3E0279D7",
x"3DD1EB35",
x"3D952A19",
x"3D2DE6A8",
x"3C784663",
x"BBC9BBA0",
x"BCA2933D",
x"BCD29091",
x"BCCB1B52",
x"BC9C502D",
x"BC331F11",
x"BB2B0ADB",
x"3B876915",
x"3C07C343",
x"3C1DCD70",
x"3C0CF61D",
x"3BC60609",
x"3B3F7850",
x"389EF6D1",
x"BAF95699",
x"BB419B40",
x"BB28E135",
x"BB6523DC",
x"BA4521DE"	
);

end package body FIR_pkg;