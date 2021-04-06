create or replace trigger trg_messagelog_id_ins
before insert on messagelog
for each row
begin
  select seq_messagelog_id.nextval 
    into :new.id
    from dual;
end;