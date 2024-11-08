
library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.NUMERIC_STD.all;

  -- entity "uses" the package   
  use work.types_pkg.all;
library UNIMACRO;
--  use UNIMACRO.vcomponents.all;

entity maxindexpipeline is
  generic (
    MULTI_LATANCY : INTEGER := 3;  -- Size of the input array
    N             : INTEGER := 16; -- Size of the input array
    NBITS         : INTEGER := 16  -- Size of the input array
  );
  port (
    clk            : in  STD_LOGIC;                                  -- Clock signal
    reset_n        : in  STD_LOGIC;                                  -- Reset signal
    --input_array  : in  array16_t;       -- Input array of integers
    theshold_in    : in  std_logic_vector(NBITS - 1 downto 0); -- Input array of integers
    input_array_t  : in  signed((NBITS * N) - 1 downto 0);           -- Input array of integers
    input_valid    : in  STD_LOGIC;

    en             : in  STD_LOGIC;
    out_valid      : out STD_LOGIC;
    output_array_t : out signed((NBITS * N) - 1 downto 0);           -- Input array of integers
    theshold_out   : out std_logic_vector(NBITS - 1 downto 0); -- Input array of integers
    max_value      : out signed(NBITS - 1 downto 0);                 -- Maximum value in the array
    max_index      : out signed(NBITS - 1 downto 0)                  -- Index of maximum value
  );
end entity;

architecture Behavioral of maxindexpipeline is
  component MULT_MACRO is
  generic ( 
    DEVICE : string := "VIRTEX5";
            LATENCY : integer := 3;
            STYLE : string := "DSP";
            WIDTH_A : integer := 18;
            WIDTH_B : integer := 18
       );

  port (
      P : out std_logic_vector((WIDTH_A+WIDTH_B)-1 downto 0);
      A : in std_logic_vector(WIDTH_A-1 downto 0);   
      B : in std_logic_vector(WIDTH_B-1 downto 0);   
      CE : in std_logic;
      CLK : in std_logic;   
      RST : in std_logic
     );   
end component MULT_MACRO;
  signal input_array : array_signed_t(0 to N - 1)(NBITS - 1 downto 0); -- Input array of integers
  type stage_type is record
    value : signed(NBITS - 1 downto 0);
    index : signed(NBITS - 1 downto 0);
  end record;
  type stage_type_t is array (0 to N - 1) of stage_type;
  type stage_type_array_t is array (0 to N - 1) of stage_type_t;
  type input_array_delayed_t is array (0 to (N + MULTI_LATANCY * 2) - 1) of array_signed_t(0 to N - 1)(NBITS - 1 downto 0);

  signal theshold_buffer : std_logic_vector(NBITS - 1 downto 0);     -- Input array of integers
  signal theshold_prod   : std_logic_vector(2 * NBITS - 1 downto 0); -- Input array of integers

  signal input_array_delayed : input_array_delayed_t;
  signal t_done              : STD_LOGIC_VECTOR((N + MULTI_LATANCY * 2) - 1 downto 0);
  signal stages              : stage_type_array_t;
  signal stages2             : stage_type_t;

  signal en_buffer : STD_LOGIC;

begin
  uu: for i in input_array'RANGE generate
    input_array(i) <= input_array_t((i + 1) * nbits - 1 downto i * nbits); -- Extract each 8-bit segment
  end generate;

  -- input_array <= to_array_signed_t(input_array_t, NBITS, N);
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      -- Initialize all pipeline stages on reset
      for i in 0 to N - 1 loop
        for j in 0 to N - 1 loop
          stages(j)(i).value <= to_signed(0, NBITS); --input_array(i);
          stages(j)(i).index <= to_signed(i, NBITS);
          t_done(i) <= '0';
        end loop;
        stages2(i).value <= to_signed(0, NBITS); --input_array(i);
        stages2(i).index <= to_signed(0, NBITS);
      end loop;
      input_array_delayed <= (others => (others => (others => '0')));
      out_valid <= '0';
      output_array_t <= (others => '0');
      max_value <= (others => '1');
      max_index <= (others => '1');
      theshold_buffer <= (others => '0');
    elsif rising_edge(clk) then
      input_array_delayed(0) <= input_array;
      input_array_delayed(1 to (N + MULTI_LATANCY * 2) - 1) <= input_array_delayed(0 to (N + MULTI_LATANCY * 2) - 2);
      stages(1 to N - 1) <= stages(0 to N - 2);
      stages2(1 to N - 1) <= stages2(0 to N - 2);

      t_done(0) <= input_valid;
      t_done((N + MULTI_LATANCY * 2) - 1 downto 1) <= t_done((N + MULTI_LATANCY * 2) - 2 downto 0);
      en_buffer <= en;
      theshold_buffer <= theshold_buffer;
      if en_buffer = '1' then
        for i in 0 to N - 1 loop
          stages(0)(i).value <= input_array(i);
          stages(0)(i).index <= to_signed(i, NBITS);
        end loop;

        t_done(0) <= input_valid;
        -- Pipeline comparison stages
        for i in 1 to N - 1 loop
          if stages(i - 1)(i - 1).value > stages(i - 1)(i).value then
            stages(i)(i).value <= stages(i - 1)(i - 1).value;
            stages(i)(i).index <= stages(i - 1)(i - 1).index;
          end if;
        end loop;
      else
        for j in 0 to N - 1 loop
          for i in 0 to N - 1 loop
            stages(0)(i).value <= to_signed(0, NBITS);
            stages(0)(i).index <= to_signed(i, NBITS);
            t_done(i) <= '0';
          end loop;
        end loop;
        theshold_buffer <= theshold_in;
      end if;
      -- Output intermiditory stage as max value and index
      if t_done(N - 1) = '1' then
        stages2(0).value <= stages(N - 1)(N - 1).value;
        stages2(0).index <= stages(N - 1)(N - 1).index;
      end if;
      -- Output final stage as max value and index
      if t_done(N + MULTI_LATANCY - 1) = '1' then
        max_value <= stages2(MULTI_LATANCY-1).value;
        max_index <= stages2(MULTI_LATANCY-1).index;
        out_valid <= t_done(N - 1 + MULTI_LATANCY);
        theshold_out <= theshold_prod(NBITS + 5 - 1 downto 0 + 5);
        output_array_t <= from_array_signed_t(input_array_delayed(N+MULTI_LATANCY-1), NBITS);
      end if;
    end if;
  end process;

  MULT_THRESH_inst: MULT_MACRO
    generic map (
      DEVICE  => "7SERIES", -- Target Device: "VIRTEX5", "7SERIES", "SPARTAN6" 
      LATENCY => MULTI_LATANCY,         -- Desired clock cycle latency, 0-4
      WIDTH_A => 16,        -- Multiplier A-input bus width, 1-25 
      WIDTH_B => 16) -- Multiplier B-input bus width, 1-18
    port map (
      P   => theshold_prod,                                -- Multiplier ouput bus, width determined by WIDTH_P generic 
      A   => std_logic_vector(stages(N - 1)(N - 1).value), -- Multiplier input A bus, width determined by WIDTH_A generic 
      B   => theshold_buffer,                              -- Multiplier input B bus, width determined by WIDTH_B generic 
      CE  => en_buffer,                                    -- 1-bit active high input clock enable
      CLK => clk,                                          -- 1-bit positive edge clock input
      RST => not en -- 1-bit input active high reset
    );

end architecture;
