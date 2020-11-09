/*Похоже, в наших логах есть баг, объявления приходят с кликами, но без показов!
  Сколько таких объявлений, есть ли какие-то закономерности? Эта проблема наблюдается на всех платформах?*/


select ad.ad_id,
       ad.has_video,
       length(groupArrayIf((ad.ad_id), ad.event = 'view')) as total_views,
       length(groupArrayIf((ad.ad_id), ad.event = 'click')) as total_clicks
from ads_data as ad
    group by ad.ad_id, ad.has_video
        having total_views = 0 and total_clicks > 0
            limit 100;

/*Всего объявлений без показов но с кликами 9 штук. Закономерностей пока не вижу у всех объявлений видео нет, надо посмотреть в разрезе
  платрформ*/

SELECT (select 'ios') as platform,
       count(ios.ad_id) as num_of_ads,
       sum(ios.total_views) as sum_of_views,
       sum(ios.total_clicks) as sum_of_clicks
FROM
    (select ad.ad_id,
            length(groupArrayIf((ad.ad_id), ad.event = 'view' and ad.platform = 'ios')) as total_views,
            length(groupArrayIf((ad.ad_id), ad.event = 'click' and ad.platform = 'ios')) as total_clicks
    from ads_data as ad
        group by ad.ad_id, ad.has_video
            having total_views = 0 and total_clicks > 0) as ios

UNION ALL

SELECT (select 'android') as platform,
       count(android.ad_id) as num_of_ads,
       sum(android.total_views) as sum_of_views,
       sum(android.total_clicks) as sum_of_clicks
FROM
    (select ad.ad_id,
            length(groupArrayIf((ad.ad_id), ad.event = 'view' and ad.platform = 'android')) as total_views,
            length(groupArrayIf((ad.ad_id), ad.event = 'click' and ad.platform = 'android')) as total_clicks
    from ads_data as ad
        group by ad.ad_id, ad.has_video
            having total_views = 0 and total_clicks > 0) as android

UNION ALL

SELECT (select 'web')        as platform,
       count(web.ad_id)      as num_of_ads,
       sum(web.total_views)  as sum_of_views,
       sum(web.total_clicks) as sum_of_clicks
FROM
    (select ad.ad_id,
            length(groupArrayIf((ad.ad_id), ad.event = 'view' and ad.platform = 'web')) as total_views,
            length(groupArrayIf((ad.ad_id), ad.event = 'click' and ad.platform = 'web')) as total_clicks
    from ads_data as ad
        group by ad.ad_id, ad.has_video
            having total_views = 0 and total_clicks > 0) as web;


/*В разрезе платформ особой закономерности нет. надо попробовать посмотреть в разрезе дат*/

SELECT per_date.date,
       sum(per_date.total_views) as total_views,
       sum(per_date.total_clicks) as total_clicks
FROM
    (select ad.date,
           length(groupArrayIf((ad.ad_id), ad.event = 'view')) as total_views,
           length(groupArrayIf((ad.ad_id), ad.event = 'click')) as total_clicks
    from ads_data as ad
        group by ad.date, ad.ad_id
            having total_views = 0 and total_clicks > 0) as per_date
GROUP BY per_date.date;

/*Эм...пока не знаю как привязать из рецензии подсказку, что нужно смотреть объявления с видео, пока оставлю старый вывод*/

/*Из закономерностей можно выделить что активность таких объявлений была всего в течение двух дней.
  Исходя из выводов, сделанных в прошлых заданиях, о наличии выбросов....где было очевидно что с 3 апреля
  произошли какие-то изменения в рекламном бизнесе, смею предположить что данные
  клики по объявлениям не что иное как тестирование рекламнных ссылок перед запуском их на боевую*/

