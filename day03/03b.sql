create table input (
	line text
);

.import ./input input

.mode table

with one_line as (
	select string_agg(input.line, ',' order by input.rowid) as line
	from input
),
all_prefixes as materialized (
	select
		substr(line, startpos.value, 15) as offsetline,
		startpos.value as offsetpos
	from one_line, generate_series(1, length(one_line.line)) as startpos
),
matching_numbers as (
	select 
		*,
		substr(offsetline, 5, instr(offsetline, ',') - 5) as firstnum,
		substr(offsetline, instr(offsetline, ',') + 1, instr(offsetline, ')') - instr(offsetline, ',') - 1) as secondnum
	from all_prefixes
	where all_prefixes.offsetline like 'mul(%,%)%'
),
filtered_matching_numbers as (
	select offsetpos, firstnum, secondnum
	from matching_numbers
	where cast(firstnum as integer) == firstnum and cast(secondnum as integer) == secondnum
),
dos as materialized (
	select offsetpos
	from all_prefixes
	where offsetline like 'do()%'
),
donts as materialized (
	select offsetpos
	from all_prefixes
	where offsetline like 'don''t()%'
),
match_nums_dos_donts as (
	select
		fmn.*,
		max(dos.offsetpos) as maxdo,
		max(donts.offsetpos) as maxdont
	from filtered_matching_numbers fmn
	left join dos on fmn.offsetpos > dos.offsetpos
	left join donts on fmn.offsetpos > donts.offsetpos
	group by fmn.offsetpos
	order by fmn.offsetpos
),
activated_nums as (
	select *
	from match_nums_dos_donts
	where maxdont is null or maxdo > maxdont
)
select sum(firstnum * secondnum) from activated_nums;
