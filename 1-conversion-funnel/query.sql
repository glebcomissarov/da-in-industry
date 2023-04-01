with clients_path as (
    select
        c.client_rk, c.visit_dttm as last_visit_dttm,
        a.account_rk, a.registration_dttm,
        ap.application_rk, ap.application_dttm,
        ap.game_rk, g.game_dttm, g.game_flg, g.finish_flg,
        g.price, g.time, q.quest_rk, q.location_rk, l.legend_rk, l.complexity
    from msu_analytics.client c
        left join msu_analytics.account a on c.client_rk = a.client_rk
        left join msu_analytics.application ap on a.account_rk = ap.account_rk
        left join msu_analytics.game g on ap.game_rk = g.game_rk
        left join msu_analytics.quest q on g.quest_rk = q.quest_rk
        left join msu_analytics.legend l on q.legend_rk = l.legend_rk 
)

select * from clients_path
order by client_rk, application_dttm
