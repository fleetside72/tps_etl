SELECT
	jsonb_pretty(row_to_json(x)::jsonb)
from
(
select
	srce, target, regex, seq
from
	tps.map_rm
where
	srce = 'HUNT'
) x