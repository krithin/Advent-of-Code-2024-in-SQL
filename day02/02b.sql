create table input (
	line text
);

.import ./input input

.mode table

with levels as (
	select
		input.rowid as row_n,
		jsoneached.key as col,
		jsoneached.value as level
	from 
		input,
		json_each('[' || replace(line, ' ', ',') || ']') as jsoneached
),
max_col_per_level as (
	select row_n, max(col) as maxcol
	from levels
	group by row_n
),
levels_with_discarded_cols as (
	select
		levels.row_n,
		col,
		level,
		col_to_discard.value as discarded_col
	from
		levels inner join max_col_per_level on levels.row_n = max_col_per_level.row_n,
		generate_series(-1, max_col_per_level.maxcol) col_to_discard
	where levels.col != col_to_discard.value
	order by levels.row_n, col_to_discard.value, col
),
levels_with_prev as (
	select
		*,
		row_number() over (partition by row_n, discarded_col order by col) - 1 as new_col,
		lag(level) over (partition by row_n, discarded_col order by col) as prev_level
	from levels_with_discarded_cols
),
each_col_safe as (
	select
		*,
		(
			case level - prev_level
			when 1 then 1
			when 2 then 1
			when 3 then 1
			when -1 then -1
			when -2 then -1
			when -3 then -1
			else null
			end
		) as safe
	from levels_with_prev
	where new_col > 0
),
each_row_safe as (
	select row_n, discarded_col, max(new_col) as ncol, sum(safe) as sum_safe from each_col_safe group by row_n, discarded_col
)
select count(distinct row_n) from each_row_safe where ncol = abs(sum_safe)
;
