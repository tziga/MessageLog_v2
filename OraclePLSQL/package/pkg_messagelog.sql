create or replace package pkg_msglog 
as
  procedure p_log_err(p_objname    in varchar2,
                      p_msgcode    in varchar2,
                      p_msgtext    in varchar2 default null,
                      p_paramvalue in varchar2 default null,
                      p_backtrace  in varchar2 default null);
                      
  procedure p_log_wrn(p_objname    in varchar2,
                      p_msgcode    in varchar2,
                      p_msgtext    in varchar2 default null,
                      p_paramvalue in varchar2 default null);

  procedure p_insert_log(p_msgtype_    in varchar2,
                         p_objname_    in varchar2,
                         p_insertdate_ in date,
                         p_msgcode_    in varchar2,
                         p_msgtext_    in varchar2 default null,
                         p_paramvalue_ in varchar2 default null,
                         p_backtrace_  in varchar2 default null);
end pkg_msglog;
/
create or replace package body pkg_msglog 
as
  procedure p_log_err(p_objname    in varchar2,
                      p_msgcode    in varchar2,
                      p_msgtext    in varchar2,
                      p_paramvalue in varchar2,
                      p_backtrace  in varchar2)
  is
  begin
    p_insert_log(p_msgtype_    => 'ERR',
                 p_objname_    => p_objname,
                 p_insertdate_ => sysdate,
                 p_msgcode_    => p_msgcode,
                 p_msgtext_    => p_msgtext,
                 p_paramvalue_ => p_paramvalue,
                 p_backtrace_  => p_backtrace);
  end p_log_err;
  
  procedure p_log_wrn(p_objname    in varchar2,
                      p_msgcode    in varchar2,
                      p_msgtext    in varchar2,
                      p_paramvalue in varchar2)
  is
  begin
    p_insert_log(p_msgtype_    => 'WRN',
                 p_objname_    => p_objname,
                 p_insertdate_ => sysdate,
                 p_msgcode_    => p_msgcode,
                 p_msgtext_    => p_msgtext,
                 p_paramvalue_ => p_paramvalue,
                 p_backtrace_  => null);
  end p_log_wrn;
  
  procedure p_insert_log(p_msgtype_    in varchar2,
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
                           objname,
                           insertdate,
                           msgcode,
                           msgtext,
                           paramvalue,
                           backtrace)
        values(p_msgtype_,
               p_objname_,
               p_insertdate_,
               p_msgcode_,
               p_msgtext_,
               p_paramvalue_,
               p_backtrace_)
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
end pkg_msglog;