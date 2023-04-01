with clients_path as (
    select
    	-- extract year and iso week number
    	extract('year' from max(c.visit_dttm)) as yyyy,
		extract('week' from max(c.visit_dttm)) as iw,
        c.client_rk,
        -- зарегестрировался клиент или нет
        max((a.account_rk is not null)::integer) as is_reg,
        -- '1' если пользователь подал хотябы 1 заявку на игру
		max((ap.application_rk is not null)::integer) as at_least_one_app,
		-- есть ли у пользователя хотябы одна игра
		(sum(g.game_flg) > 0)::integer as started_at_least_one_game,
		-- завершил ли пользователь хотябы одну игру
		(sum(g.finish_flg) > 0)::integer as passed_at_least_one_game,
		-- завершил ли пользователь ВСЕ игры
		(sum(g.finish_flg) = count(g.finish_flg))::integer as passed_all_games
    from msu_analytics.client c
        left join msu_analytics.account a on c.client_rk = a.client_rk
        left join msu_analytics.application ap on a.account_rk = ap.account_rk
        left join msu_analytics.game g on ap.game_rk = g.game_rk
    group by c.client_rk
)

-- group by single user ---> group by by week+year
select
	t.iw::text || ' - ' || t.yyyy::text as by_iso_week,
	count(t.client_rk) as n_views,
	sum(t.is_reg) as n_regs,
	sum(t.at_least_one_app) as n_users_with_app,
	sum(t.started_at_least_one_game) as n_users_with_game,
	sum(t.passed_at_least_one_game) as n_users_with_passed_game,
	sum(t.passed_all_games) as passed_all_games
from clients_path t
group by t.yyyy, t.iw
order by yyyy, iw