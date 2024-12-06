create table input (
	line text
);

.import ./input input

.mode table

with all_prefixes as (
	select
		input.rowid as linenum,
		substr(line, startpos.value, 20) as offsetline,
		startpos.value as offsetpos
	from input, generate_series(1, length(input.line)) as startpos
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
	select *
	from matching_numbers
	where cast(firstnum as integer) == firstnum and cast(secondnum as integer) == secondnum
)
select sum(firstnum * secondnum) from filtered_matching_numbers
;
