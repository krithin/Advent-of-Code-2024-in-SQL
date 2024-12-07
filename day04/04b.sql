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

create index m on letters (r, c) where l = 'M';
create index a on letters (r, c) where l = 'A';
create index s on letters (r, c) where l = 'S';

select count(*) from (
select * from
letters la
inner join letters lm1
inner join letters ls1
inner join letters lm2
inner join letters ls2
where la.l = 'A'
and lm1.l = 'M' and ls1.l = 'S'
and lm2.l = 'M' and ls2.l = 'S'
and lm1.r = la.r - 1 and lm1.c = la.c - 1 and ls1.r = la.r + 1 and ls1.c = la.c + 1
and lm2.r = la.r - 1 and lm2.c = la.c + 1 and ls2.r = la.r + 1 and ls2.c = la.c - 1

union all

select * from
letters la
inner join letters lm1
inner join letters ls1
inner join letters lm2
inner join letters ls2
where la.l = 'A'
and lm1.l = 'M' and ls1.l = 'S'
and lm2.l = 'M' and ls2.l = 'S'
and lm1.r = la.r - 1 and lm1.c = la.c - 1 and ls1.r = la.r + 1 and ls1.c = la.c + 1
and lm2.r = la.r + 1 and lm2.c = la.c - 1 and ls2.r = la.r - 1 and ls2.c = la.c + 1

union all

select * from
letters la
inner join letters lm1
inner join letters ls1
inner join letters lm2
inner join letters ls2
where la.l = 'A'
and lm1.l = 'M' and ls1.l = 'S'
and lm2.l = 'M' and ls2.l = 'S'
and lm1.r = la.r - 1 and lm1.c = la.c + 1 and ls1.r = la.r + 1 and ls1.c = la.c - 1
and lm2.r = la.r + 1 and lm2.c = la.c + 1 and ls2.r = la.r - 1 and ls2.c = la.c - 1

union all

select * from
letters la
inner join letters lm1
inner join letters ls1
inner join letters lm2
inner join letters ls2
where la.l = 'A'
and lm1.l = 'M' and ls1.l = 'S'
and lm2.l = 'M' and ls2.l = 'S'
and lm1.r = la.r + 1 and lm1.c = la.c - 1 and ls1.r = la.r - 1 and ls1.c = la.c + 1
and lm2.r = la.r + 1 and lm2.c = la.c + 1 and ls2.r = la.r - 1 and ls2.c = la.c - 1
)
;
