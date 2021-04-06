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
end pkg_clients;
/
create or replace package body pkg_clients 
as
  procedure p_insert_user(p_login_     in varchar2,
                          p_firstname_ in varchar2,
                          p_lastname_  in varchar2,
                          p_id_        out number)
  is
    v_id clients.id%type;
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
      pkg_msglog.p_log_err(p_objname    => 'pkg_clients.p_insert_user',
                           p_msgcode    => SQLCODE,
                           p_msgtext    => SQLERRM,
                           p_paramvalue => 'p_login_ = '||p_login_
                                             ||', p_firstname_ = '||p_firstname_
                                             ||', p_lastname_ = '||p_lastname_,
                           p_backtrace  => dbms_utility.format_error_backtrace);
      rollback;
  end p_insert_user;
  
  procedure p_create_user(p_login     in varchar2,
                          p_firstname in varchar2,
                          p_lastname  in varchar2,
                          p_id        out number)
  is
    v_id clients.id%type;
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
      pkg_msglog.p_log_err(p_objname    => 'pkg_clients.p_create_user',
                           p_msgcode    => SQLCODE,
                           p_msgtext    => SQLERRM,
                           p_paramvalue => 'p_login = '||p_login
                                             ||', p_firstname = '||p_firstname
                                             ||', p_lastname = '||p_lastname,
                           p_backtrace  => dbms_utility.format_error_backtrace);
  end p_create_user;
end pkg_clients;