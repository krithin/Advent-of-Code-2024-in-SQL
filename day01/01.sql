create table input (
	left integer not null,
	unused1 null,
	unused2 null,
	right integer not null
);

.separator " "
.import ./input input

with ranks as (
	select
		left,
		right,
		row_number() over (order by left) as leftnum,
		row_number() over (order by right) as rightnum
	from input
)
select sum(abs(l.left - r.right))
from ranks l
inner join ranks r on l.leftnum = r.rightnum
;
