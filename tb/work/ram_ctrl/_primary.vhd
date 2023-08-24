library verilog;
use verilog.vl_types.all;
entity ram_ctrl is
    port(
        clk             : in     vl_logic;
        sys_rst_n       : in     vl_logic;
        MemOE           : out    vl_logic;
        MemWR           : out    vl_logic;
        RamAdv          : out    vl_logic;
        RamCS           : out    vl_logic;
        RamClk          : out    vl_logic;
        RamCRE          : out    vl_logic;
        RamLB           : out    vl_logic;
        RamUB           : out    vl_logic;
        RamWait         : in     vl_logic;
        MemAdr          : out    vl_logic_vector(22 downto 0);
        MemDB           : inout  vl_logic_vector(15 downto 0);
        mem_we          : in     vl_logic;
        mem_addr        : in     vl_logic_vector(31 downto 0);
        mem_rdata       : out    vl_logic_vector(15 downto 0);
        mem_wdata       : in     vl_logic_vector(15 downto 0);
        rdy             : out    vl_logic;
        op_code         : in     vl_logic_vector(22 downto 0);
        reload          : in     vl_logic
    );
end ram_ctrl;
