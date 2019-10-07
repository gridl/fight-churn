

INSERT into metric_name values (NEW_ID,concat('ratio_','NUM_METRIC_','DEN_METRIC'))
ON CONFLICT DO NOTHING;

with num_metric as (
	select account_id, metric_time, metric_value as num_value
	from metric m inner join metric_name n on n.metric_name_id=m.metric_name_id
	and n.metric_name = 'NUM_METRIC'
	and metric_time between '%from_yyyy-mm-dd' and '%to_yyyy-mm-dd'
), den_metric as (
	select account_id, metric_time, metric_value as den_value
	from metric m inner join metric_name n on n.metric_name_id=m.metric_name_id
	and n.metric_name = 'DEN_METRIC'
	and metric_time between '%from_yyyy-mm-dd' and '%to_yyyy-mm-dd'
)
insert into metric (account_id,metric_time,metric_name_id,metric_value)
select d.account_id, d.metric_time, NEW_ID,
	case when den_value > 0
	    then coalesce(num_value,0.0)/den_value
	    else 0
    end as metric_value
from den_metric d  left outer join num_metric n
	on n.account_id=d.account_id
	and n.metric_time=d.metric_time
ON CONFLICT DO NOTHING;