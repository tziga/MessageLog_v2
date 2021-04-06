create table messagelog_backtrace(id         number(38)     not null,
                                  backtrace  varchar2(4000) default null,
                                  constraint pk_messagelogbcktrc_id primary key (id),
                                  constraint fk_messagelogbcktrc_id foreign key (id) references messagelog(id));