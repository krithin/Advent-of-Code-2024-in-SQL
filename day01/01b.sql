create table input (
	left integer not null,
	unused1 null,
	unused2 null,
	right integer not null
);

.separator " "
.import ./input input

with counts as (
	select l.left, count(*) as c
	from input l
	inner join input r on l.left = r.right
	group by l.left
)
select sum(left * c) from counts;
