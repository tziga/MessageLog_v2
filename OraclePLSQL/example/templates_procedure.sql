  -- шаблон процедуры/функции для построения Событийной модели логирования
  -- Обратите внимание, что каждый блок "begin ... end" содержит исключение вида "others",
  -- который осуществляет логирование Архитектурных ошибок.
  -- Все остальные исключения вида "no_data_found", "too_many_rows" и др. 
  -- будут осуществлять логирование Пользовательских ошибок
  procedure p_procedure_name(p_param1  in number,
                             p_param2  in varchar2,
                             p_param3  in date,
                             /* others param */
                             p_errcode out number,
                             p_errtext out varchar2)
  is
    v_objname varchar2(60) := utl_call_stack.concatenate_subprogram(utl_call_stack.subprogram(1));
    /* variable */
    v_msgcode   messagelog.msgcode%type;
    v_msgtext   messagelog.msgtext%type;
  begin
  
    /* others code */

    begin
    
      /* others code */
      null;
    exception
      when no_data_found then
        v_msgcode := 'USR0000'; -- внутренний код
        v_msgtext := pkg_msglog.f_get_errcode(v_msgcode);
        pkg_msglog.p_log_wrn(p_objname    => v_objname,
                             p_msgcode    => v_msgcode,
                             p_msgtext    => v_msgtext,
                             p_paramvalue => 'p_param1 = '||to_char(p_param1)
                                                ||', p_param2 = '||p_param2
                                                ||', p_param3 = '||to_char(p_param3,'dd.mm.yyyy hh24:mi:ss'));
	  p_errcode := -1;
      p_errtext := v_msgtext;
    end;   
      when others then
        pkg_msglog.p_log_archerr(p_objname    => v_objname,
                                 p_msgcode    => SQLCODE,
                                 p_msgtext    => SQLERRM,
                                 p_paramvalue => 'p_param1 = '||to_char(p_param1)
                                                    ||', p_param2 = '||p_param2
                                                    ||', p_param3 = '||to_char(p_param3,'dd.mm.yyyy hh24:mi:ss'),
                                 p_backtrace  => dbms_utility.format_error_backtrace);
		raise;
    end;   
    
    /* others code */
    p_errcode := 1;
  exception
      -- Пользовательское логирование
    when no_data_found or too_many_rows then
      v_msgcode := 'USR0000';  -- внутренний код
      v_msgtext := pkg_msglog.f_get_errcode(v_msgcode);
      pkg_msglog.p_log_wrn(p_objname    => v_objname,
                           p_msgcode    => v_msgcode,
                           p_msgtext    => v_msgtext,
                           p_paramvalue => 'p_param1 = '||to_char(p_param1)
                                                ||', p_param2 = '||p_param2
                                                ||', p_param3 = '||to_char(p_param3,'dd.mm.yyyy hh24:mi:ss'));
	  p_errcode := -1;
      p_errtext := v_msgtext;
    -- Архитектурное логирование
    when others then
      pkg_msglog.p_log_archerr(p_objname    => v_objname,
                               p_msgcode    => SQLCODE,
                               p_msgtext    => SQLERRM,
                               p_paramvalue => 'p_param1 = '||to_char(p_param1)
                                                ||', p_param2 = '||p_param2
                                                ||', p_param3 = '||to_char(p_param3,'dd.mm.yyyy hh24:mi:ss'),
                               p_backtrace  => dbms_utility.format_error_backtrace);
      raise;
  end p_create_user;
  