create or replace package pkg_msglog 
as
  procedure p_log_err(p_objname    in varchar2,
                      p_msgcode    in varchar2,
                      p_msgtext    in varchar2 default null,
                      p_paramvalue in varchar2 default null,
                      p_backtrace  in varchar2 default null);
                      
  procedure p_log_archerr(p_objname    in varchar2,
                          p_msgcode    in varchar2,
                          p_msgtext    in varchar2,
                          p_paramvalue in varchar2,
                          p_backtrace  in varchar2);
                      
  procedure p_log_wrn(p_objname    in varchar2,
                      p_msgcode    in varchar2,
                      p_msgtext    in varchar2 default null,
                      p_paramvalue in varchar2 default null);

  procedure p_insert_log(p_msgtype_    in varchar2,
                         p_sessionid_  in number,
                         p_objname_    in varchar2,
                         p_insertdate_ in date,
                         p_msgcode_    in varchar2,
                         p_msgtext_    in varchar2 default null,
                         p_paramvalue_ in varchar2 default null,
                         p_backtrace_  in varchar2 default null);
                         
  procedure p_insert_msgcode(p_msgcode    in varchar2,
                             p_rusmsgtext in varchar2 default null,
                             p_priority   in number default null);
                             
  -- function found architect error codes OR crete new code and return his
  function f_get_archerrcode(p_obj_name in varchar2,
                             p_err_code in number)
    return varchar2;
    
end pkg_msglog;
/
create or replace package body pkg_msglog 
as
  v_sid number;  -- unique SID current session
  
  -- create architectural error
  procedure p_insert_arch_err(p_objname_    in varchar2,
                              p_errcode_    in varchar2,
                              p_msgcode_    in varchar2)
  is
    pragma autonomous_transaction;
  begin
    insert into messagecodes_arch(objectname,
                                  sqlerrcode,
                                  msgcode,
                                  insertdate)
      values(upper(p_objname_),
             p_errcode_,
             p_msgcode_,
             sysdate);
    commit;
  end p_insert_arch_err;
  
  procedure p_log_err(p_objname    in varchar2,
                      p_msgcode    in varchar2,
                      p_msgtext    in varchar2,
                      p_paramvalue in varchar2,
                      p_backtrace  in varchar2)
  is
  begin
    p_insert_log(p_msgtype_    => 'ERR',
                 p_sessionid_  => v_sid,
                 p_objname_    => p_objname,
                 p_insertdate_ => sysdate,
                 p_msgcode_    => p_msgcode,
                 p_msgtext_    => p_msgtext,
                 p_paramvalue_ => p_paramvalue,
                 p_backtrace_  => p_backtrace);
  end p_log_err;
  
  -- loggining architectural error
  procedure p_log_archerr(p_objname    in varchar2,
                          p_msgcode    in varchar2,
                          p_msgtext    in varchar2,
                          p_paramvalue in varchar2,
                          p_backtrace  in varchar2)
  is
    v_sqlerrcode messagecodes_arch.sqlerrcode%type;
    v_msgcode    messagecodes.msgcode%type;
  begin
    if pkg_util.is_number(p_msgcode) = 1 then 
      v_msgcode := f_get_archerrcode(p_obj_name => upper(p_objname),
                                     p_err_code => abs(p_msgcode));
    else
      v_msgcode := p_msgcode;
    end if;
    p_insert_log(p_msgtype_    => 'ERR',
                 p_sessionid_  => v_sid,
                 p_objname_    => p_objname,
                 p_insertdate_ => sysdate,
                 p_msgcode_    => v_msgcode,
                 p_msgtext_    => p_msgtext,
                 p_paramvalue_ => p_paramvalue,
                 p_backtrace_  => p_backtrace);
  end p_log_archerr;
  
  procedure p_log_wrn(p_objname    in varchar2,
                      p_msgcode    in varchar2,
                      p_msgtext    in varchar2,
                      p_paramvalue in varchar2)
  is
  begin
    p_insert_log(p_msgtype_    => 'WRN',
                 p_sessionid_  => v_sid,
                 p_objname_    => p_objname,
                 p_insertdate_ => sysdate,
                 p_msgcode_    => p_msgcode,
                 p_msgtext_    => p_msgtext,
                 p_paramvalue_ => p_paramvalue,
                 p_backtrace_  => null);
  end p_log_wrn;
  
  procedure p_insert_log(p_msgtype_    in varchar2,
                         p_sessionid_  in number,
                         p_objname_    in varchar2,
                         p_insertdate_ in date,
                         p_msgcode_    in varchar2,
                         p_msgtext_    in varchar2,
                         p_paramvalue_ in varchar2,
                         p_backtrace_  in varchar2)
  is
    v_id messagelog.id%type;
    pragma autonomous_transaction;
  begin
    insert into messagelog(msgtype,
                           sessionid,
                           objname,
                           insertdate,
                           msgcode,
                           msgtext,
                           paramvalue)
        values(p_msgtype_,
               p_sessionid_,
               p_objname_,
               p_insertdate_,
               p_msgcode_,
               p_msgtext_,
               p_paramvalue_)
    return id
      into v_id;
    if trim(p_backtrace_) is not null then
      insert into messagelog_backtrace(id,
                                       backtrace)
      values(v_id,
             trim(p_backtrace_));
    end if;

    commit;
  end p_insert_log;
  
  procedure p_insert_msgcode(p_msgcode    in varchar2,
                             p_rusmsgtext in varchar2 default null,
                             p_priority   in number default null)
  is 
    v_msgcode messagecodes.msgcode%type;
    v_rustext messagecodes.rustext%type;
  begin
    select rustext
      into v_rustext
      from messagecodes
     where msgcode = trim(p_msgcode);
    
    if trim(upper(v_rustext)) != trim(upper(p_rusmsgtext)) then
      update messagecodes
         set rustext = trim(p_rusmsgtext),
             lastupdate = sysdate
       where msgcode = trim(p_msgcode);
    end if;
    
    insert into messagecodes(msgcode,
                             rustext,
                             msgpriority,
                             insertdate)
    values(trim(upper(p_msgcode)),
           trim(p_rusmsgtext),
           p_priority,
           sysdate);
  exception
    when no_data_found then
      insert into messagecodes(msgcode,
                               rustext,
                               msgpriority,
                               insertdate)
      values(p_msgcode,
             p_rusmsgtext,
             p_priority,
             sysdate);
  end p_insert_msgcode;
  
  function f_get_archerrcode(p_obj_name in varchar2,
                             p_err_code in number)
    return varchar2
  is
    v_err_prefix  varchar2(10) := 'SYS';       -- prefix architectural error
    v_err_code    number := abs(p_err_code);
    v_msgcode     messagecodes.msgcode%type; 
    v_new_msgcode messagecodes.msgcode%type; 
  begin
    select msgcode
      into v_msgcode
      from messagecodes_arch
     where objectname = upper(p_obj_name)
       and sqlerrcode = v_err_code;
    return v_msgcode;
  exception
    when no_data_found then
      v_new_msgcode := v_err_prefix||lpad(seq_messagecodes_arch_id.nextval, 4, '0');
      p_insert_arch_err(p_objname_ => upper(p_obj_name),
                        p_errcode_ => v_err_code,
                        p_msgcode_ => v_new_msgcode);
     return v_new_msgcode;
  end f_get_archerrcode;

begin
  v_sid := SYS_CONTEXT('USERENV', 'SESSIONID');
end pkg_msglog;