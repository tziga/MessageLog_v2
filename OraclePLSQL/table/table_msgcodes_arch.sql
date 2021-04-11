create table messagecodes_arch(objectname  varchar2(120) not null,
                               sqlerrcode  number        not null,
                               msgcode     varchar2(10)  not null,
                               insertdate  date          default sysdate,
                               constraint pk_msgcode_arch_id primary key (objectname,sqlerrcode));
/
-- Add comments to the columns 
comment on column messagecodes_arch.objectname is 'Unique object name';
comment on column messagecodes_arch.sqlerrcode is 'Return function SQLCODE with use ABS';
comment on column messagecodes_arch.msgcode is 'Unique architect error code';
comment on column messagecodes_arch.insertdate is 'Insert datetime row';