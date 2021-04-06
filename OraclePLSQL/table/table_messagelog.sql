create table messagelog(id         number(38)     not null,
                        msgtype    varchar2(3)    not null,
                        objname    varchar2(60)   default null,
                        insertdate date           default sysdate,
                        msgcode    varchar2(10)   default null,
                        msgtext    varchar2(4000)  default null,
                        paramvalue varchar2(4000)  default null,
                        constraint pk_messagelog_id primary key (id))
partition by range (insertdate)
  interval (numtoyminterval(3, 'MONTH'))
    (partition p1 values less than (to_date('01.01.2020', 'DD.MM.YYYY')));