-- -----------------------------------------------------------------
-- 
-- Copyright 2019 IEEE P1076 WG Authors
-- 
-- See the LICENSE file distributed with this work for copyright and
-- licensing information and the AUTHORS file.
-- 
-- This file to you under the Apache License, Version 2.0 (the "License").
-- You may obtain a copy of the License at
-- 
--     http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
-- implied.  See the License for the specific language governing
-- permissions and limitations under the License.
--
--   Title     :  Environment package
--             :
--   Library   :  This package shall be compiled into a library
--             :  symbolically named std.
--             :
--   Developers:  IEEE P1076 Working Group
--             :
--   Purpose   :  This packages defines basic tool interface subprograms
--             :
--   Note      :  This package may be modified to include additional data
--             :  required by tools, but it must in no way change the
--             :  external interfaces or simulation behavior of the
--             :  description. It is permissible to add comments and/or
--             :  attributes to the package declarations, but not to change
--             :  or delete any original lines of the package declaration.
--             :  The package body may be changed only in accordance with
--             :  the terms of Clause 16 of this standard.
--             :
-- --------------------------------------------------------------------

use work.textio.all;


package ENV is
  procedure STOP (STATUS: INTEGER);
  procedure STOP;
  procedure FINISH (STATUS: INTEGER);
  procedure FINISH;

  function RESOLUTION_LIMIT return DELAY_LENGTH;


  type DAYOFWEEK is (
    SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY,
    FRIDAY, SATURDAY
  );

  -- Calendar date/time, broken into parts.  Second accomodates both
  -- single and double leap-seconds.  Dayofyear accomodates leap days.
  -- Month 0 is January, 1 is February, 11 is December. Year is absolute
  -- in AD, 1900 represents the year 1900.
  --
  type TIME_RECORD is record
    microsecond : INTEGER range 0 to 999_999;
    second : INTEGER range 0 to 61;
    minute : INTEGER range 0 to 59;
    hour : INTEGER range 0 to 23;
    day : INTEGER range 1 to 31;
    month : INTEGER range 0 to 11;
    year : INTEGER range 1 to 4095;
    weekday : DAYOFWEEK;
    dayofyear : INTEGER range 0 to 365;
  end record TIME_RECORD;

  -- Current local time broken into parts.
  -- Minimum legal resolution is 1 second.
  impure function LOCALTIME return TIME_RECORD;

  -- Current UTC time broken into parts.
  -- Minimum legal resolution is 1 second.
  impure function GMTIME return TIME_RECORD;

  -- Number of seconds since midnight, Jan 1 1970, UTC.
  -- Minimum legal resolution is 1 second.
  impure function EPOCH return REAL;

  -- Time conversion functions from epoch time.
  function LOCALTIME(TIMER: REAL) return TIME_RECORD;
  function GMTIME(TIMER: REAL) return TIME_RECORD;

  -- Time conversion function from time in parts.
  -- EPOCH and GMTIME accept TREC in local time.
  -- LOCALTIME accepts TREC in UTC.
  function EPOCH(TREC: TIME_RECORD) return REAL;
  function LOCALTIME(TREC: TIME_RECORD) return TIME_RECORD;
  function GMTIME(TREC: TIME_RECORD) return TIME_RECORD;

  -- Time increment/decrement.  DELTA argument is in seconds.
  -- Returned TIME_RECORD is in local time or UTC per the TREC.
  function "+"(TREC: TIME_RECORD; DELTA: REAL) return TIME_RECORD;
  function "+"(DELTA: REAL; TREC: TIME_RECORD) return TIME_RECORD;
  function "-"(TREC: TIME_RECORD; DELTA: REAL) return TIME_RECORD;
  function "-"(DELTA: REAL; TREC: TIME_RECORD) return TIME_RECORD;

  -- Time difference in seconds.  TR1, TR2 must both be in local
  -- time, or both in UTC.
  function "-"(TR1, TR2: TIME_RECORD) return REAL;

  -- Conversion between real seconds and VHDL TIME.  SECONDS_TO_TIME
  -- will cause an error if the resulting REAL_VAL would be less than
  -- TIME'LOW or greater than TIME'HIGH.
  function TIME_TO_SECONDS(TIME_VAL: IN TIME) return REAL;
  function SECONDS_TO_TIME(REAL_VAL: IN REAL) return TIME;

  -- Convert TIME_RECORD to a string in ISO 8601 format.
  -- TO_STRING(x)    => "1973-09-16T01:03:52"
  -- TO_STRING(x, 6) => "1973-09-16T01:03:52.000001"
  function TO_STRING(TREC: TIME_RECORD;
                     FRAC_DIGITS: INTEGER range 0 to 6 := 0)
                     return STRING;

  impure function GETENV(Name : STRING) return STRING;
  impure function GETENV(Name : STRING) return LINE;


  impure function VHDL_VERSION return STRING;
  function TOOL_TYPE    return STRING;
  function TOOL_VENDOR  return STRING;
  function TOOL_NAME    return STRING;
  function TOOL_EDITION return STRING;
  function TOOL_VERSION return STRING;


  type DIRECTORY_ITEMS is access LINE_VECTOR;
  -- The predefined operations for this type are as follows:
  -- function"=" (anonymous, anonymous: DIRECTORY_ITEMS) return BOOLEAN;
  -- function"/=" (anonymous, anonymous: DIRECTORY_ITEMS) return BOOLEAN;
  -- procedure DEALLOCATE (P: inout DIRECTORY_ITEMS);

  type DIRECTORY is record
    Name      : LINE;             -- current directory name; resolved to its canonical form
    Items     : DIRECTORY_ITEMS;  -- list of pointers to directory item names
  end record;
  -- The predefined operations for this type are as follows:
  -- function "="(anonymous, anonymous: DIRECTORY) return BOOLEAN;
  -- function "/="(anonymous, anonymous: DIRECTORY) return BOOLEAN;

  type DIR_OPEN_STATUS is (
    STATUS_OK,
    STATUS_NOT_FOUND,
    STATUS_NO_DIRECTORY,
    STATUS_ACCESS_DENIED,
    STATUS_ERROR
  );
  -- The predefined operations for this type are as follows:
  -- function "="(anonymous, anonymous: DIR_OPEN_STATUS) return BOOLEAN;
  -- function "/="(anonymous, anonymous: DIR_OPEN_STATUS) return BOOLEAN;
  -- function "<"(anonymous, anonymous: DIR_OPEN_STATUS) return BOOLEAN;
  -- function "<="(anonymous, anonymous: DIR_OPEN_STATUS) return BOOLEAN;
  -- function ">"(anonymous, anonymous: DIR_OPEN_STATUS) return BOOLEAN;
  -- function ">="(anonymous, anonymous: DIR_OPEN_STATUS) return BOOLEAN;
  -- function MINIMUM (L, R: DIR_OPEN_STATUS) return DIR_OPEN_STATUS;
  -- function MAXIMUM (L, R: DIR_OPEN_STATUS) return DIR_OPEN_STATUS;

  type DIR_CREATE_STATUS is (
    STATUS_OK,
    STATUS_ITEM_EXISTS,
    STATUS_ACCESS_DENIED,
    STATUS_ERROR
  );
  -- The predefined operations for this type are as follows:
  -- function "="(anonymous, anonymous: DIR_CREATE_STATUS) return BOOLEAN;
  -- function "/="(anonymous, anonymous: DIR_CREATE_STATUS) return BOOLEAN;
  -- function "<"(anonymous, anonymous: DIR_CREATE_STATUS) return BOOLEAN;
  -- function "<="(anonymous, anonymous: DIR_CREATE_STATUS) return BOOLEAN;
  -- function ">"(anonymous, anonymous: DIR_CREATE_STATUS) return BOOLEAN;
  -- function ">="(anonymous, anonymous: DIR_CREATE_STATUS) return BOOLEAN;
  -- function MINIMUM (L, R: DIR_CREATE_STATUS) return DIR_CREATE_STATUS;
  -- function MAXIMUM (L, R: DIR_CREATE_STATUS) return DIR_CREATE_STATUS;

  type DIR_DELETE_STATUS is (
    STATUS_OK,
    STATUS_NO_DIRECTORY,
    STATUS_NOT_EMPTY,
    STATUS_ACCESS_DENIED,
    STATUS_ERROR
  );
  -- The predefined operations for this type are as follows:
  -- function "="(anonymous, anonymous: DIR_DELETE_STATUS) return BOOLEAN;
  -- function "/="(anonymous, anonymous: DIR_DELETE_STATUS) return BOOLEAN;
  -- function "<"(anonymous, anonymous: DIR_DELETE_STATUS) return BOOLEAN;
  -- function "<="(anonymous, anonymous: DIR_DELETE_STATUS) return BOOLEAN;
  -- function ">"(anonymous, anonymous: DIR_DELETE_STATUS) return BOOLEAN;
  -- function ">="(anonymous, anonymous: DIR_DELETE_STATUS) return BOOLEAN;
  -- function MINIMUM (L, R: DIR_DELETE_STATUS) return DIR_DELETE_STATUS;
  -- function MAXIMUM (L, R: DIR_DELETE_STATUS) return DIR_DELETE_STATUS;

  type FILE_DELETE_STATUS is (
    STATUS_OK,
    STATUS_NO_FILE,
    STATUS_ACCESS_DENIED,
    STATUS_ERROR
  );
  -- The predefined operations for this type are as follows:
  -- function "="(anonymous, anonymous: FILE_DELETE_STATUS) return BOOLEAN;
  -- function "/="(anonymous, anonymous: FILE_DELETE_STATUS) return BOOLEAN;
  -- function "<"(anonymous, anonymous: FILE_DELETE_STATUS) return BOOLEAN;
  -- function "<="(anonymous, anonymous: FILE_DELETE_STATUS) return BOOLEAN;
  -- function ">"(anonymous, anonymous: FILE_DELETE_STATUS) return BOOLEAN;
  -- function ">="(anonymous, anonymous: FILE_DELETE_STATUS) return BOOLEAN;
  -- function MINIMUM (L, R: FILE_DELETE_STATUS) return FILE_DELETE_STATUS;
  -- function MAXIMUM (L, R: FILE_DELETE_STATUS) return FILE_DELETE_STATUS;

  procedure       DIR_OPEN(Dir : out DIRECTORY; Path : in STRING; Status : out DIR_OPEN_STATUS);
  impure function DIR_OPEN(Dir : out DIRECTORY; Path : in STRING) return DIR_OPEN_STATUS;
  procedure       DIR_CLOSE(Dir : in DIRECTORY);

  impure function DIR_ITEMEXISTS(Path : in STRING) return BOOLEAN;
  impure function DIR_ITEMISDIR(Path : in STRING) return BOOLEAN;
  impure function DIR_ITEMISFILE(Path : in STRING) return BOOLEAN;

  procedure       DIR_WORKINGDIR(Path : in STRING; Status : out DIR_OPEN_STATUS);
  impure function DIR_WORKINGDIR(Path : in STRING) return DIR_OPEN_STATUS;
  impure function DIR_WORKINGDIR return STRING;

  procedure       DIR_CREATEDIR(Path : in STRING; Status : out DIR_CREATE_STATUS);
  procedure       DIR_CREATEDIR(Path : in STRING; Parents : in BOOLEAN; Status : out DIR_CREATE_STATUS);
  impure function DIR_CREATEDIR(Path : in STRING; Parents : in BOOLEAN := FALSE) return DIR_CREATE_STATUS;
  procedure       DIR_DELETEDIR(Path : in STRING; Status : out DIR_DELETE_STATUS);
  procedure       DIR_DELETEDIR(Path : in STRING; Recursive : in BOOLEAN; Status : out DIR_DELETE_STATUS);
  impure function DIR_DELETEDIR(Path : in STRING; Recursive : in BOOLEAN := FALSE) return DIR_DELETE_STATUS;
  procedure       DIR_DELETEFILE(Path : in STRING; Status : out FILE_DELETE_STATUS);
  impure function DIR_DELETEFILE(Path : in STRING) return FILE_DELETE_STATUS;

  constant        DIR_SEPARATOR : STRING;


  type CALL_PATH_ELEMENT is record
    name             : LINE;
    file_name        : LINE;
    file_path        : LINE;
    file_line        : POSITIVE;
  end record;
  -- function "="  (anonymous, anonymous: CALL_PATH_ELEMENT) return BOOLEAN;
  -- function "/=" (anonymous, anonymous: CALL_PATH_ELEMENT) return BOOLEAN;
  impure function TO_STRING (call_path : CALL_PATH_ELEMENT ) return STRING;

  type CALL_PATH_VECTOR is array (natural range <>) of CALL_PATH_ELEMENT;
  -- function "="  (anonymous, anonymous: CALL_PATH_VECTOR) return BOOLEAN;
  -- function "/=" (anonymous, anonymous: CALL_PATH_VECTOR) return BOOLEAN;
  impure function TO_STRING (call_path : CALL_PATH_VECTOR; Separator : STRING := "" & LF ) return STRING;

  type CALL_PATH_VECTOR_PTR is access CALL_PATH_VECTOR;
  -- function "="  (anonymous, anonymous: CALL_PATH_VECTOR_PTR) return BOOLEAN;
  -- function "/=" (anonymous, anonymous: CALL_PATH_VECTOR_PTR) return BOOLEAN;
  -- procedure DEALLOCATE (P: inout CALL_PATH_VECTOR_PTR);
  impure function TO_STRING (variable call_path : inout CALL_PATH_VECTOR_PTR; Separator : STRING := "" & LF ) return STRING;

  impure function GET_CALL_PATH return CALL_PATH_VECTOR_PTR;

  impure function FILE_NAME return LINE;
  impure function FILE_NAME return STRING;
  impure function FILE_PATH return LINE;
  impure function FILE_PATH return STRING;
  impure function FILE_LINE return POSITIVE;
  impure function FILE_LINE return STRING;


  -- VHDL Assert Failed
  impure function IsVhdlAssertFailed return boolean;
  impure function IsVhdlAssertFailed (Level : SEVERITY_LEVEL ) return boolean;

  -- VHDL Assert Count
  impure function GetVhdlAssertCount return natural;
  impure function GetVhdlAssertCount (Level : SEVERITY_LEVEL ) return natural;

  --  Clear VHDL Assert Errors
  procedure ClearVhdlAssert;

  -- Assert Enable, Disable/Ignore Asserts
  procedure SetVhdlAssertEnable(Enable : boolean := TRUE);
  procedure SetVhdlAssertEnable(Level : SEVERITY_LEVEL := NOTE; Enable : boolean := TRUE);
  impure function GetVhdlAssertEnable(Level : SEVERITY_LEVEL := NOTE) return boolean;

  --  Assert statement formatting
  procedure SetVhdlAssertFormat(Level : SEVERITY_LEVEL; Format: string);
  procedure SetVhdlAssertFormat(Level : SEVERITY_LEVEL; Format: string; Valid : out boolean);
  impure function GetVhdlAssertFormat(Level : SEVERITY_LEVEL) return string;

  --  VHDL Read Severity
  procedure SetVhdlReadSeverity(Level: SEVERITY_LEVEL := FAILURE);
  impure function GetVhdlReadSeverity return SEVERITY_LEVEL;

  -- PSL Assert Failed
  impure function PslAssertFailed return boolean;

  -- PSL Is Covered
  impure function PslIsCovered return boolean;

  -- Psl Cover Asserts
  procedure SetPslCoverAssert( Enable : boolean := TRUE);
  impure function GetPslCoverAssert return boolean;

  -- Psl Is AssertCovered
  impure function PslIsAssertCovered return boolean;

  -- Clear PSL State (Assert and Cover)
  procedure ClearPslState;

  attribute foreign of ENV: package is "NO C code generation";
  attribute foreign of STOP : procedure is "vhdl_stop";
  attribute foreign of FINISH : procedure is "vhdl_finish";
  attribute foreign of RESOLUTION_LIMIT : function is "vhdl_resolution_limit";
  
end package ENV;


-- stub package body
package body ENV is

  constant        DIR_SEPARATOR : STRING := "/" ;

  procedure STOP (STATUS: INTEGER) is
    -- verific synthesis ignore_subprogram
  begin
  end procedure STOP ;

  procedure STOP is
    -- verific synthesis ignore_subprogram
  begin
  end procedure STOP ;

  procedure FINISH (STATUS: INTEGER) is
    -- verific synthesis ignore_subprogram
  begin
  end procedure FINISH ;

  procedure FINISH  is
    -- verific synthesis ignore_subprogram
  begin
  end procedure FINISH ;

  function RESOLUTION_LIMIT return DELAY_LENGTH is
  begin
    return 0 fs ;
  end function RESOLUTION_LIMIT;

  impure function LOCALTIME return TIME_RECORD is
  begin
    return (weekday => SUNDAY, others => 1) ;
  end function LOCALTIME ;

  impure function GMTIME return TIME_RECORD is
  begin
    return (weekday => SUNDAY, others => 1) ;
  end function GMTIME ;

  impure function EPOCH return REAL is
  begin
    return 0.0 ;
  end function EPOCH ;

  -- Time conversion functions from epoch time.
  function LOCALTIME(TIMER: REAL) return TIME_RECORD is
  begin
    return (weekday => SUNDAY, others => 1) ;
  end function LOCALTIME ;
  
  function GMTIME(TIMER: REAL) return TIME_RECORD is
  begin
    return (weekday => SUNDAY, others => 1) ;
  end function GMTIME ;

  function EPOCH(TREC: TIME_RECORD) return REAL is
  begin
    return 0.0 ;
  end function EPOCH ;
  
  function LOCALTIME(TREC: TIME_RECORD) return TIME_RECORD is
  begin
    return (weekday => SUNDAY, others => 1) ;
  end function LOCALTIME ;
  
  function GMTIME(TREC: TIME_RECORD) return TIME_RECORD is
  begin
    return (weekday => SUNDAY, others => 1) ;
  end function GMTIME ;

  -- Time increment/decrement.  DELTA argument is in seconds.
  -- Returned TIME_RECORD is in local time or UTC per the TREC.
  function "+"(TREC: TIME_RECORD; DELTA: REAL) return TIME_RECORD is
  begin
    return (weekday => SUNDAY, others => 1) ;
  end function "+" ;
  function "+"(DELTA: REAL; TREC: TIME_RECORD) return TIME_RECORD is
  begin
    return (weekday => SUNDAY, others => 1) ;
  end function "+" ;
  function "-"(TREC: TIME_RECORD; DELTA: REAL) return TIME_RECORD is
  begin
    return (weekday => SUNDAY, others => 1) ;
  end function "-" ;
  function "-"(DELTA: REAL; TREC: TIME_RECORD) return TIME_RECORD is
  begin
    return (weekday => SUNDAY, others => 1) ;
  end function "-" ;

  -- Time difference in seconds.  TR1, TR2 must both be in local
  -- time, or both in UTC.
  function "-"(TR1, TR2: TIME_RECORD) return REAL is
  begin
    return 0.0 ;
  end function "-" ;

  -- Conversion between real seconds and VHDL TIME.  SECONDS_TO_TIME
  -- will cause an error if the resulting REAL_VAL would be less than
  -- TIME'LOW or greater than TIME'HIGH.
  function TIME_TO_SECONDS(TIME_VAL: IN TIME) return REAL is
  begin
    return 0.0 ;
  end function TIME_TO_SECONDS ;
  function SECONDS_TO_TIME(REAL_VAL: IN REAL) return TIME is
  begin
    return 0 fs ;
  end function SECONDS_TO_TIME ;

  -- Convert TIME_RECORD to a string in ISO 8601 format.
  -- TO_STRING(x)    => "1973-09-16T01:03:52"
  -- TO_STRING(x, 6) => "1973-09-16T01:03:52.000001"
  function TO_STRING(TREC: TIME_RECORD;
                     FRAC_DIGITS: INTEGER range 0 to 6 := 0)
    return STRING is
  begin
    return "0000-00-00000:00:00" ;
  end function TO_STRING ;
  
  impure function GETENV(Name : STRING) return STRING is
    -- pr-ag-ma VHDL_env_getenv
  begin
    return name ;
  end function GETENV ;
  
  impure function GETENV(Name : STRING) return LINE is 
    -- pr-ag-ma VHDL_env_getenv
  begin
    return new string'(name) ;
  end function GETENV ;

  impure function VHDL_VERSION return STRING is
    -- pr-ag-ma VHDL_env_vhdl_version
  begin
    return "VHDL-2019" ;
  end function VHDL_VERSION ;
  
  function TOOL_TYPE    return STRING is
    -- pragma VHDL_env_tool_type
  begin
    return "Simulator" ;
  end function TOOL_TYPE ;
  
  function TOOL_VENDOR  return STRING is
    -- pragma VHDL_env_tool_vendor
  begin
    return "Advanced Micro Devices" ;
  end function TOOL_VENDOR ;
  
  function TOOL_NAME    return STRING is
    -- pragma VHDL_env_tool_name
  begin
    return "Vivado Simulator" ;
  end function TOOL_NAME ;
  
  function TOOL_EDITION return STRING is
    -- pragma VHDL_env_tool_edition
  begin
    return "Vivado Design Suite" ;
  end function TOOL_EDITION ;
  
  function TOOL_VERSION return STRING is
    -- pragma VHDL_end_tool_version
  begin
    return "2024.2" ;
  end function TOOL_VERSION ;

  procedure       DIR_OPEN(Dir : out DIRECTORY; Path : in STRING; Status : out DIR_OPEN_STATUS) is
  -- verific synthesis ignore_subprogram
  begin
  end procedure DIR_OPEN ;

  impure function DIR_OPEN(Dir : out DIRECTORY; Path : in STRING) return DIR_OPEN_STATUS is
  begin
    return STATUS_ERROR ;
  end function DIR_OPEN ;
  
  procedure       DIR_CLOSE(Dir : in DIRECTORY) is
  -- verific synthesis ignore_subprogram
  begin
  end procedure DIR_CLOSE ;

  impure function DIR_ITEMEXISTS(Path : in STRING) return BOOLEAN is
  begin
    return false ;
  end function DIR_ITEMEXISTS ;
  
  impure function DIR_ITEMISDIR(Path : in STRING) return BOOLEAN is
  begin
    return false ;
  end function DIR_ITEMISDIR ;
  
  impure function DIR_ITEMISFILE(Path : in STRING) return BOOLEAN is
  begin
    return false ;
  end function DIR_ITEMISFILE ;

  procedure       DIR_WORKINGDIR(Path : in STRING; Status : out DIR_OPEN_STATUS) is
  -- verific synthesis ignore_subprogram
  begin
  end procedure DIR_WORKINGDIR ;
  
  impure function DIR_WORKINGDIR(Path : in STRING) return DIR_OPEN_STATUS is
  begin
    return STATUS_ERROR ;
  end function DIR_WORKINGDIR ;
  impure function DIR_WORKINGDIR return STRING is
  begin
    return "" ;
  end function DIR_WORKINGDIR ;

  procedure       DIR_CREATEDIR(Path : in STRING; Status : out DIR_CREATE_STATUS) is
  -- verific synthesis ignore_subprogram
  begin
  end procedure DIR_CREATEDIR ;

  procedure       DIR_CREATEDIR(Path : in STRING; Parents : in BOOLEAN; Status : out DIR_CREATE_STATUS) is
  -- verific synthesis ignore_subprogram
  begin
  end procedure DIR_CREATEDIR ;

  impure function DIR_CREATEDIR(Path : in STRING; Parents : in BOOLEAN := FALSE) return DIR_CREATE_STATUS is
  begin
    return STATUS_ERROR ;
  end function DIR_CREATEDIR ;

  procedure       DIR_DELETEDIR(Path : in STRING; Status : out DIR_DELETE_STATUS) is
  -- verific synthesis ignore_subprogram
  begin
  end procedure DIR_DELETEDIR ;

  procedure       DIR_DELETEDIR(Path : in STRING; Recursive : in BOOLEAN; Status : out DIR_DELETE_STATUS) is
  -- verific synthesis ignore_subprogram
  begin
  end procedure DIR_DELETEDIR ;

  impure function DIR_DELETEDIR(Path : in STRING; Recursive : in BOOLEAN := FALSE) return DIR_DELETE_STATUS is
  begin
    return STATUS_ERROR ;
  end function DIR_DELETEDIR ;

  procedure       DIR_DELETEFILE(Path : in STRING; Status : out FILE_DELETE_STATUS) is
  -- verific synthesis ignore_subprogram
  begin
  end procedure DIR_DELETEFILE ;

  impure function DIR_DELETEFILE(Path : in STRING) return FILE_DELETE_STATUS is
  begin
    return STATUS_ERROR ;
  end function DIR_DELETEFILE ;

  impure function TO_STRING (call_path : CALL_PATH_ELEMENT ) return STRING is
  begin
    return "" ;
  end function TO_STRING ;

  impure function TO_STRING (call_path : CALL_PATH_VECTOR; Separator : STRING := "" & LF ) return STRING is
  begin
    return "" ;
  end function TO_STRING ;

  impure function TO_STRING (variable call_path : inout CALL_PATH_VECTOR_PTR; Separator : STRING := "" & LF ) return STRING is
  begin
    return "" ;
  end function TO_STRING ;

  impure function GET_CALL_PATH return CALL_PATH_VECTOR_PTR is
  begin
    return CALL_PATH_VECTOR_PTR'(null) ;
  end function GET_CALL_PATH ;

  impure function FILE_NAME return LINE is
  begin
    return LINE'(null) ;
  end function FILE_NAME ;

  impure function FILE_NAME return STRING is
  begin
    return "" ;
  end function FILE_NAME ;

  impure function FILE_PATH return LINE is
  begin
    return LINE'(null) ;
  end function FILE_PATH ;

  impure function FILE_PATH return STRING is
  begin
    return "" ;
  end function FILE_PATH ;

  impure function FILE_LINE return POSITIVE is
  begin
    return 1 ;
  end function FILE_LINE ;

  impure function FILE_LINE return STRING is
  begin
    return "" ;
  end function FILE_LINE ;

  -- VHDL Assert Failed
  impure function IsVhdlAssertFailed return boolean is
  begin
    return FALSE ;
  end function IsVhdlAssertFailed ;

  impure function IsVhdlAssertFailed (Level : SEVERITY_LEVEL ) return boolean is
  begin
    return FALSE ;
  end function IsVhdlAssertFailed ;

  -- VHDL Assert Count
  impure function GetVhdlAssertCount return natural is
  begin
    return 0 ;
  end function GetVhdlAssertCount ;

  impure function GetVhdlAssertCount (Level : SEVERITY_LEVEL ) return natural is
  begin
    return 0 ;
  end function GetVhdlAssertCount ;

  --  Clear VHDL Assert Errors
  procedure ClearVhdlAssert is
  begin
  end procedure ClearVhdlAssert ;

  -- Assert Enable, Disable/Ignore Asserts
  procedure SetVhdlAssertEnable(Enable : boolean := TRUE) is
  begin
  end procedure SetVhdlAssertEnable ;

  procedure SetVhdlAssertEnable(Level : SEVERITY_LEVEL := NOTE; Enable : boolean := TRUE) is
  begin
  end procedure SetVhdlAssertEnable ;

  impure function GetVhdlAssertEnable(Level : SEVERITY_LEVEL := NOTE) return boolean is
  begin
    return FALSE ;
  end function GetVhdlAssertEnable ;

  --  Assert statement formatting
  procedure SetVhdlAssertFormat(Level : SEVERITY_LEVEL; Format: string) is
  begin
  end procedure SetVhdlAssertFormat ;

  procedure SetVhdlAssertFormat(Level : SEVERITY_LEVEL; Format: string; Valid : out boolean) is
  begin
  end procedure SetVhdlAssertFormat ;

  impure function GetVhdlAssertFormat(Level : SEVERITY_LEVEL) return string is
  begin
    return "" ;
  end function GetVhdlAssertFormat ;

  --  VHDL Read Severity
  procedure SetVhdlReadSeverity(Level: SEVERITY_LEVEL := FAILURE) is
  begin
  end procedure SetVhdlReadSeverity ;

  impure function GetVhdlReadSeverity return SEVERITY_LEVEL is
  begin
    return NOTE ;
  end function GetVhdlReadSeverity ;

  -- PSL Assert Failed
  impure function PslAssertFailed return boolean is
  begin
    return FALSE ;
  end function PslAssertFailed ;

  -- PSL Is Covered
  impure function PslIsCovered return boolean is
  begin
    return FALSE ;
  end function PslIsCovered ;

  -- Psl Cover Asserts
  procedure SetPslCoverAssert( Enable : boolean := TRUE) is
  begin
  end procedure SetPslCoverAssert ;

  impure function GetPslCoverAssert return boolean is
  begin
    return FALSE ;
  end function GetPslCoverAssert ;

  -- Psl Is AssertCovered
  impure function PslIsAssertCovered return boolean is
  begin
    return FALSE ;
  end function PslIsAssertCovered ;

  -- Clear PSL State (Assert and Cover)
  procedure ClearPslState is
  begin
  end procedure ClearPslState ;

end package body ENV;
