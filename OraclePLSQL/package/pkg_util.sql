create or replace package pkg_util 
as
  function is_number(p_string in varchar2)
    return number;
end pkg_util;
/
create or replace package body pkg_util 
as
  function is_number(p_string in varchar2)
    return number
  is
   v_new_num number;
  begin
    v_new_num := TO_NUMBER(p_string);
    return 1;
  exception
    when VALUE_ERROR then
    return 0;
  end is_number;
end pkg_util;