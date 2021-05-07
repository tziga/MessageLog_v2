drop table clients;
drop sequence seq_clients_id;
create table clients(id         number(38)  not null,
                     login     varchar2(10) not null,
                     firstname varchar2(20) not null,
                     lastname  varchar2(20) not null,
                     constraint pk_clients_id primary key (id),
                     constraint unique_loginname unique (login));
create sequence seq_clients_id;
create or replace trigger trg_clients_id_ins
before insert on clients
for each row
begin
  select seq_clients_id.nextval 
    into :new.id
    from dual;
end;
/
drop table client_telnumbers;
create table client_telnumbers(id         number(38)  not null,
                               telnumber  number(38)  not null,
                               startdate  date default sysdate,
                               enddate    date default null);
insert into client_telnumbers(id,telnumber,startdate,enddate) values(43,89511234567,sysdate,to_date('31.12.5999 23:59:59', 'dd.mm.yyyy hh24:mi:ss'));
insert into client_telnumbers(id,telnumber,startdate,enddate) values(43,89923456789,sysdate,to_date('31.12.5999 23:59:59', 'dd.mm.yyyy hh24:mi:ss'));
/
create or replace package pkg_clients 
as
  procedure p_insert_user(p_login_     in varchar2,
                          p_firstname_ in varchar2,
                          p_lastname_  in varchar2,
                          p_id_        out number);
                          
  procedure p_create_user(p_login     in varchar2,
                          p_firstname in varchar2,
                          p_lastname  in varchar2,
                          p_id        out number);
                          
  -- Демонстрационная процедура: по id пользователя вернет активынй (поле enddate = 5999 Год) номер телефона
  procedure p_get_telnumber(p_userid    in number,
                            p_telnumber out number,
                            p_errcode   out number,
                            p_errtext   out varchar2);
end pkg_clients;
/
create or replace package body pkg_clients 
as
  procedure p_insert_user(p_login_     in varchar2,
                          p_firstname_ in varchar2,
                          p_lastname_  in varchar2,
                          p_id_        out number)
  is
    v_objname varchar2(60) := utl_call_stack.concatenate_subprogram(utl_call_stack.subprogram(1));
    v_id      clients.id%type;
  begin
    insert into clients(login,
                        firstname,
                        lastname)
        values(upper(p_login_),
               p_firstname_,
               p_lastname_)
    return id
      into v_id;
    if v_id > 0 then
      pkg_msglog.p_log_wrn(p_objname    => 'pkg_clients.p_insert_user',
                           p_msgcode    => '101',
                           p_msgtext    => 'Создан новый пользователь с id = '||v_id,
                           p_paramvalue => 'p_login = '||p_login_
                                             ||', p_firstname = '||p_firstname_
                                             ||', p_lastname = '||p_lastname_);
    end if;
    commit;
  exception
    when others then
      pkg_msglog.p_log_archerr(p_objname    => v_objname,
                               p_msgcode    => SQLCODE,
                               p_msgtext    => SQLERRM,
                               p_paramvalue => 'p_login_ = '||p_login_
                                                 ||', p_firstname_ = '||p_firstname_
                                                 ||', p_lastname_ = '||p_lastname_,
                               p_backtrace  => dbms_utility.format_error_backtrace);
	  raise;
  end p_insert_user;
  
  procedure p_create_user(p_login     in varchar2,
                          p_firstname in varchar2,
                          p_lastname  in varchar2,
                          p_id        out number)
  is
    v_objname varchar2(60) := utl_call_stack.concatenate_subprogram(utl_call_stack.subprogram(1));
    v_id      clients.id%type;
  begin
    begin
      select id
        into v_id
        from clients
       where login = upper(p_login);
    exception
      when no_data_found then
        p_insert_user(p_login_     => p_login,
                      p_firstname_ => p_firstname,
                      p_lastname_  => p_lastname,
                      p_id_        => v_id);
    end;   
    p_id := v_id;
  exception
    when others then
      pkg_msglog.p_log_archerr(p_objname    => v_objname,
                               p_msgcode    => SQLCODE,
                               p_msgtext    => SQLERRM,
                               p_paramvalue => 'p_login = '||p_login
                                                ||', p_firstname = '||p_firstname
                                                ||', p_lastname = '||p_lastname,
                               p_backtrace  => dbms_utility.format_error_backtrace);
	raise;
  end p_create_user;
  
  -- Демонстрационная процедура: по id пользователя вернет активынй (поле enddate = 5999 Год) номер телефона
  procedure p_get_telnumber(p_userid    in number,
                            p_telnumber out number,
                            p_errcode   out number,
                            p_errtext   out varchar2)
  is
    v_objname   varchar2(60) := utl_call_stack.concatenate_subprogram(utl_call_stack.subprogram(1));
    v_telnumber client_telnumbers.telnumber%type;
    v_msgcode   messagelog.msgcode%type;
    v_msgtext   messagelog.msgtext%type;
  begin
    select telnumber
      into v_telnumber
      from client_telnumbers
     where id = p_userid
       and enddate = to_date('31.12.5999 23:59:59', 'dd.mm.yyyy hh24:mi:ss');

    p_telnumber := v_telnumber;
  exception
    -- Пользовательское логирование
    when too_many_rows then
      v_msgcode := 'USR0001';
      v_msgtext := pkg_msglog.f_get_errcode(v_msgcode,to_char(p_userid));
      pkg_msglog.p_log_wrn(p_objname    => v_objname,
                           p_msgcode    => v_msgcode,
                           p_msgtext    => v_msgtext,
                           p_paramvalue => 'p_userid = '||to_char(p_userid));
      p_errcode := -1;
      p_errtext := v_msgtext;
      
    -- Архитектурное логирование
    when others then
      pkg_msglog.p_log_archerr(p_objname    => v_objname,
                               p_msgcode    => SQLCODE,
                               p_msgtext    => SQLERRM,
                               p_paramvalue => 'p_userid = '||to_char(p_userid),
                               p_backtrace  => dbms_utility.format_error_backtrace);
	 raise;
  end p_get_telnumber;
end pkg_clients;