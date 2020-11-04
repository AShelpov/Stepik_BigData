/*Для финансового отчета нужно рассчитать наш заработок по дням.
  В какой день мы заработали больше всего? В какой меньше?
  Мы списываем с клиентов деньги, если произошел клик по CPC объявлению,
  и мы списываем деньги за каждый показ CPM объявления, если у CPM объявления цена - 200 рублей,
  то за один показ мы зарабатываем 200 / 1000.*/

select * from ads_data limit 10;

SELECT * FROM
    (select ad.ad_id, ad.date,ad.ad_cost_type, countIf(ad.ad_cost_type = 'CPM') as views,
            countIf(ad.ad_cost_type = 'CPC') as clicks,
            uniqExact(ad.ad_cost) as cost_of_ads
        from ads_data as ad
            group by ad.ad_id, ad.date, ad.ad_cost_type) as agg
WHERE  agg.cost_of_ads > 1
    ORDER BY agg.ad_id;

/*Сделал на всякий случай проверку, чтобы исключить ситуации когда у одного объявления может быть несколько
  CPC или CPM. Суд по всему таких объявлений нет. Поскольку мы используем order by нет возможности взять
  через distinct единичные значения цен по объявлениям. Тут либо нужно отдельно выбирать и делать join
  либо есть другой вариант. Поскольку чтоимость у всех объявлений по CPM и CPC одинаковая, сделаем следующее
  возьмем среднее значение по столбцу ad_cost и в таком случае нам вернется точная стоимость объявления*/

SELECT agg.date,
       sum(if(agg.ad_cost_type = 'CPM', agg.views * agg.cost_of_ads / 1000,
              agg.clicks * agg.cost_of_ads)) as total_revenue
    FROM
        (select ad.ad_id, ad.date,ad.ad_cost_type, countIf(ad.ad_cost_type = 'CPM') as views,
                countIf(ad.ad_cost_type = 'CPC') as clicks,
                avg(ad.ad_cost) as cost_of_ads
        from ads_data as ad
            group by ad.ad_id, ad.date, ad.ad_cost_type) as agg
GROUP BY agg.date
    ORDER BY total_revenue DESC;

/*Больше всего заработали за 4 апреля - 575 т.р., меньше всего за 6 апреля - 72 т.р. если стоимость в деревянных))*/
