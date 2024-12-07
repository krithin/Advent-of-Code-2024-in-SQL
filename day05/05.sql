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
	order by cast(substr(input.line, 1, 2) as integer), cast(substr(input.line, 4, 2) as integer)
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
)
select sum(cast(substr(input.line, length(input.line) / 2, 2) as integer)) from input where rowid in (select update_id from allowed_update_ids);
