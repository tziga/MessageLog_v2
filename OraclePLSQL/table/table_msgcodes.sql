create table messagecodes(msgcode     varchar2(10)  default null,
                          rustext     varchar2(500) not null,
                          msgpriority number(1)     default 1,
                          insertdate  date          default sysdate,
                          lastupdate  date          default null,
                          constraint pk_messagecodes_id primary key (msgcode));
/
-- Add comments to the columns 
comment on column messagecodes.msgcode is 'Unique message code';
comment on column messagecodes.rustext is 'Russian message text';
comment on column messagecodes.msgpriority is 'Priority message: 0 - non priority; 5 - critical';
comment on column messagecodes.insertdate is 'Insert datetime row';