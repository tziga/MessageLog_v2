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
    /* others variable */
  begin
  
    /* others code */

    begin
    
      /* others code */
      null;
    exception
      when no_data_found then
        pkg_msglog.p_log_wrn(p_objname    => 'pkg_clients.p_insert_user',
                             p_msgcode    => '101',
                             p_msgtext    => 'Создан новый пользователь с id = '||v_id,
                             p_paramvalue => 'p_param1 = '||to_char(p_param1)
                                                ||', p_param2 = '||p_param2
                                                ||', p_param3 = '||to_char(p_param3,'dd.mm.yyyy hh24:mi:ss'));
      when others then
        pkg_msglog.p_log_archerr(p_objname    => v_objname,
                                 p_msgcode    => SQLCODE,
                                 p_msgtext    => SQLERRM,
                                 p_paramvalue => 'p_param1 = '||to_char(p_param1)
                                                    ||', p_param2 = '||p_param2
                                                    ||', p_param3 = '||to_char(p_param3,'dd.mm.yyyy hh24:mi:ss'),
                                 p_backtrace  => dbms_utility.format_error_backtrace);
    end;   
    
    /* others code */
    
  exception
    when no_data_found or too_many_rows then
      pkg_msglog.p_log_wrn(p_objname    => v_objname,
                           p_msgcode    => '101',
                           p_msgtext    => 'Создан новый пользователь с id = '||v_id,
                           p_paramvalue => 'p_param1 = '||to_char(p_param1)
                                                ||', p_param2 = '||p_param2
                                                ||', p_param3 = '||to_char(p_param3,'dd.mm.yyyy hh24:mi:ss'));
    when others then
      pkg_msglog.p_log_archerr(p_objname    => v_objname,
                               p_msgcode    => SQLCODE,
                               p_msgtext    => SQLERRM,
                               p_paramvalue => 'p_param1 = '||to_char(p_param1)
                                                ||', p_param2 = '||p_param2
                                                ||', p_param3 = '||to_char(p_param3,'dd.mm.yyyy hh24:mi:ss'),
                               p_backtrace  => dbms_utility.format_error_backtrace);
  end p_create_user;
  