create table input (
	line text
);

.import ./input input

.mode table

create table letters as
	select
		input.rowid as r,
		series.value as c,
		substr(line, series.value, 1) as l
	from 
		input,
		generate_series(1, length(input.line), 1) series
;

create index x on letters (r, c) where l = 'X';
create index m on letters (r, c) where l = 'M';
create index a on letters (r, c) where l = 'A';
create index s on letters (r, c) where l = 'S';

--  812
--  7X3
--  654
select count(*) from (
-- 1: up
select * from
letters lx
inner join letters lm 
inner join letters la 
inner join letters ls
where lx.l = 'X' and lm.l = 'M' and la.l = 'A' and ls.l = 'S'
and lm.r = lx.r - 1 and lm.c = lx.c
and la.r = lm.r - 1 and la.c = lm.c
and ls.r = la.r - 1 and ls.c = la.c

union all
-- 2: up and right
select * from
letters lx
inner join letters lm 
inner join letters la 
inner join letters ls
where lx.l = 'X' and lm.l = 'M' and la.l = 'A' and ls.l = 'S'
and lm.r = lx.r - 1 and lm.c = lx.c + 1
and la.r = lm.r - 1 and la.c = lm.c + 1
and ls.r = la.r - 1 and ls.c = la.c + 1

union all
-- 3: right
select * from
letters lx
inner join letters lm 
inner join letters la 
inner join letters ls
where lx.l = 'X' and lm.l = 'M' and la.l = 'A' and ls.l = 'S'
and lm.r = lx.r and lm.c = lx.c + 1
and la.r = lm.r and la.c = lm.c + 1
and ls.r = la.r and ls.c = la.c + 1

union all
-- 4: down right
select * from
letters lx
inner join letters lm 
inner join letters la 
inner join letters ls
where lx.l = 'X' and lm.l = 'M' and la.l = 'A' and ls.l = 'S'
and lm.r = lx.r + 1 and lm.c = lx.c + 1
and la.r = lm.r + 1 and la.c = lm.c + 1
and ls.r = la.r + 1 and ls.c = la.c + 1

union all
-- 5: down
select * from
letters lx
inner join letters lm 
inner join letters la 
inner join letters ls
where lx.l = 'X' and lm.l = 'M' and la.l = 'A' and ls.l = 'S'
and lm.r = lx.r + 1 and lm.c = lx.c
and la.r = lm.r + 1 and la.c = lm.c
and ls.r = la.r + 1 and ls.c = la.c

union all
-- 6: down left
select * from
letters lx
inner join letters lm 
inner join letters la 
inner join letters ls
where lx.l = 'X' and lm.l = 'M' and la.l = 'A' and ls.l = 'S'
and lm.r = lx.r + 1 and lm.c = lx.c - 1
and la.r = lm.r + 1 and la.c = lm.c - 1
and ls.r = la.r + 1 and ls.c = la.c - 1

union all
-- 7: left
select * from
letters lx
inner join letters lm 
inner join letters la 
inner join letters ls
where lx.l = 'X' and lm.l = 'M' and la.l = 'A' and ls.l = 'S'
and lm.r = lx.r  and lm.c = lx.c - 1
and la.r = lm.r  and la.c = lm.c - 1
and ls.r = la.r  and ls.c = la.c - 1

union all
-- 8: up left
select * from
letters lx
inner join letters lm 
inner join letters la 
inner join letters ls
where lx.l = 'X' and lm.l = 'M' and la.l = 'A' and ls.l = 'S'
and lm.r = lx.r - 1 and lm.c = lx.c - 1
and la.r = lm.r - 1 and la.c = lm.c - 1
and ls.r = la.r - 1 and ls.c = la.c - 1
)
;
