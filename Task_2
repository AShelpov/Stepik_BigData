/*2. Разобраться, почему случился такой скачок 2019-04-05? Каких событий стало больше?
  У всех объявлений или только у некоторых?*/

/*Чтобы разобраться в этой ситуации нужно что-то типо сводной таблицы где будет видно движение
  количества показов/кликов для конкретной рекламы. По индексу будет номер релкламной компании по столбцам даты.
  Проанализируем 3,4 и 5 апреля и отсортируем по максимальному количеству за 5 апреля. Построим отдельно запросы
  для показов и кликов*/

SELECT april_03.ad_id as ad_id, april_03.views_per_ad_03 as total_views_per_03_April,
       april_04.views_per_ad_04 as total_views_per_04_April,
       april_05.views_per_ad_05 as total_views_per_05_April
FROM
    (select ad.ad_id, count(ad_id) as views_per_ad_03 from ads_data as ad
        where ad.date = '2019-04-03' and ad.event = 'view'
            group by ad_id) as april_03

FULL OUTER JOIN
    (select ad.ad_id, count(ad_id) as views_per_ad_04 from ads_data as ad
        where ad.date = '2019-04-04' and ad.event = 'view'
            group by ad_id) as april_04
ON april_03.ad_id = april_04.ad_id

FULL OUTER JOIN
    (select ad.ad_id, count(ad_id) as views_per_ad_05 from ads_data as ad
        where ad.date = '2019-04-05' and ad.event = 'view'
            group by ad_id) as april_05
ON april_03.ad_id = april_05.ad_id
    ORDER BY total_views_per_05_April DESC
        LIMIT 100;


/*Как видно по показам рост произошел за счет нескольких компаний под номерами 112583, 107729, 28142 и 107837
  Судя по всему 4 апреля стартовали либо новые рекламные компании, либо сменилась бизнес-модель, либо поменялся учет показов,
  потому что по 100 наиболее показываемым рекламам не было в принципе активности до 4 апреля. При этом если сгруппировать
  по полю total_views_per_03_April или total_views_per_04_April будет видно что по рекламным компаниям наиболее активным 3 апреля
  эта активность снижается и сходит на нет 4 и 5 апреля. Ну и в целом эту тенденцию можно проследить по всем компаниям активность коотрых
  начиналась до 4 апреля*/


SELECT april_03.ad_id as ad_id, april_03.views_per_ad_03 as total_views_per_03_April,
       april_04.views_per_ad_04 as total_views_per_04_April,
       april_05.views_per_ad_05 as total_views_per_05_April
FROM
    (select ad.ad_id, count(ad_id) as views_per_ad_03 from ads_data as ad
        where ad.date = '2019-04-03' and ad.event = 'click'
            group by ad_id) as april_03

FULL OUTER JOIN
    (select ad.ad_id, count(ad_id) as views_per_ad_04 from ads_data as ad
        where ad.date = '2019-04-04' and ad.event = 'click'
            group by ad_id) as april_04
ON april_03.ad_id = april_04.ad_id

FULL OUTER JOIN
    (select ad.ad_id, count(ad_id) as views_per_ad_05 from ads_data as ad
        where ad.date = '2019-04-05' and ad.event = 'click'
            group by ad_id) as april_05
ON april_03.ad_id = april_05.ad_id
    ORDER BY total_views_per_04_April DESC
        LIMIT 100;


/*Основной рост кликов пришелся также на рекламные компании 112583 и 38892 причем рекламной компании 38892 вроде
  не было в топ 10 по просмотрам. Над сравнить. Ну и в целом картинка такая же. Компании по которым было наибольшее число
  кликов 3 апреля постепенно снижают свою активность на нет к 5 апреля*/

SELECT views.ad_id, views.total_views, clicks.total_clicks FROM
    (select ad.ad_id, count(ad.event) as total_views from ads_data as ad
        where ad.ad_id = 38892 and ad.event='view' and ad.date = '2019-04-05'
            group by ad.ad_id) as views
FULL OUTER JOIN
    (select ad.ad_id, count(ad.event) as total_clicks from ads_data as ad
        where ad.ad_id = 38892 and ad.event='click' and ad.date = '2019-04-05'
            group by ad.ad_id) as clicks
ON views.ad_id = clicks.ad_id;


/*А не, все норм....))*/
