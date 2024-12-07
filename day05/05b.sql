create table input (
	line text
);

 -- disable | as a separator.
.separator X

.import ./input input

.mode table

create table rules as
	select cast(substr(input.line, 1, 2) as integer) as before, cast(substr(input.line, 4, 2) as integer) as after
	from input
	where input.rowid < (select rowid from input where input.line = '')
;

create index rules_idx on rules (before, after);

create table updates as
	select input.rowid as update_id, jsoneached.key, jsoneached.value
	from input, json_each('[' || input.line || ']') jsoneached
	where input.rowid > (select rowid from input where input.line = '')
;

create index updates_id_idx on updates (update_id);

with allowed_update_pairs as (
	select l.update_id as update_id, l.key as l_key, l.value as l_value, r.key as r_key, r.value as r_value from
	updates l
	inner join updates r
	where l.update_id = r.update_id
	and l.key < r.key
	and not exists (select 1 from rules where rules.before = r.value and rules.after = l.value)
),
allowed_update_ids as (
	select update_id, count(*) as l_key_count from (
		select update_id, l_key, count(*) as r_key_count
		from allowed_update_pairs
		group by update_id, l_key
		having r_key_count = (select max(key) from updates where updates.update_id = allowed_update_pairs.update_id) - l_key
	) t
	group by t.update_id
	having l_key_count = (select max(key) from updates where updates.update_id = t.update_id)
),
updates_to_reorder as (
	select * from updates
	where update_id not in (select update_id from allowed_update_ids)
),
left_right_counts as (
	select
		utr.update_id,
		utr.key,
		utr.value,
		count(*) filter (where not exists (select 1 from rules where rules.before = utr2.value and rules.after = utr.value)) as left_count,
		count(*) filter (where not exists (select 1 from rules where rules.before = utr.value and rules.after = utr2.value)) as right_count
	from updates_to_reorder utr
	inner join updates_to_reorder utr2 on utr2.update_id = utr.update_id and utr2.key != utr.key
	group by utr.update_id, utr.key, utr.value
)
select sum(lrc.value) from left_right_counts lrc where lrc.left_count = lrc.right_count
