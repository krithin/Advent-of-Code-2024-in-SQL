create table input (
	line text
);

.import ./input input

.mode table

with levels as (
	select
		"row",
		key as col,
		value,
		lag(value) over (partition by "row" order by key) as prev_value
		
	from (
		select *, row_number() over () as "row" from input
	),
	json_each('[' || replace(line, ' ', ',') || ']')
),
each_col_safe as (
	select
		*,
		(
			case value - prev_value
			when 1 then 1
			when 2 then 1
			when 3 then 1
			when -1 then -1
			when -2 then -1
			when -3 then -1
			else null
			end
		) as safe
	from levels
	where col > 0
),
each_row_safe as (
	select "row", max(col) as ncol, sum(safe) as sum_safe from each_col_safe group by "row"
)
select count(*) from each_row_safe where ncol = abs(sum_safe)
;

