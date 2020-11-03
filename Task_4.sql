/*Похоже, в наших логах есть баг, объявления приходят с кликами, но без показов!
  Сколько таких объявлений, есть ли какие-то закономерности? Эта проблема наблюдается на всех платформах?*/


SELECT tv.ad_id, tv.total_views, tc.total_clicks
FROM
    (select ad.ad_id, count(ad.event) as total_views from ads_data as ad
        where ad.event = 'view'
            group by ad.ad_id) as tv

FULL OUTER JOIN
    (select ad.ad_id, count(ad.event) as total_clicks from ads_data as ad
        where ad.event = 'click'
            group by ad.ad_id) as tc
ON tv.ad_id = tc.ad_id
    WHERE tv.total_views = 0 and tc.total_clicks > 0
        ORDER BY tc.total_clicks DESC;

/*Всего объявлений без показов но с кликами 9 штук. Закономерностей пока не вижу, надо посмотреть в разрезе
  платрформ и дат*/



SELECT DISTINCT count(tc.ad_id) as total_ads, (select 'ios') as paltform
FROM
    (select ad.ad_id, count(ad.event) as total_views from ads_data as ad
        where ad.event = 'view' and ad.platform = 'ios'
                group by ad.ad_id) as tv

FULL OUTER JOIN
    (select ad.ad_id, count(ad.event) as total_clicks from ads_data as ad
        where ad.event = 'click' and ad.platform = 'ios'
                group by ad.ad_id) as tc
ON tv.ad_id = tc.ad_id
    WHERE tv.total_views = 0 and tc.total_clicks > 0

UNION ALL

SELECT DISTINCT count(tc.ad_id) as total_ads, (select 'android') as paltform
FROM
    (select ad.ad_id, count(ad.event) as total_views from ads_data as ad
        where ad.event = 'view' and ad.platform = 'android'
                group by ad.ad_id) as tv

FULL OUTER JOIN
    (select ad.ad_id, count(ad.event) as total_clicks from ads_data as ad
        where ad.event = 'click' and ad.platform = 'android'
                group by ad.ad_id) as tc
ON tv.ad_id = tc.ad_id
    WHERE tv.total_views = 0 and tc.total_clicks > 0

UNION ALL

SELECT DISTINCT count(tc.ad_id) as total_ads, (select 'web') as paltform
FROM
    (select ad.ad_id, count(ad.event) as total_views from ads_data as ad
        where ad.event = 'view' and ad.platform = 'web'
                group by ad.ad_id) as tv

FULL OUTER JOIN
    (select ad.ad_id, count(ad.event) as total_clicks from ads_data as ad
        where ad.event = 'click' and ad.platform = 'web'
                group by ad.ad_id) as tc
ON tv.ad_id = tc.ad_id
    WHERE tv.total_views = 0 and tc.total_clicks > 0;




/*В разрезе платформ особой закономерности нет. надо попробовать посмотреть в разрезе дат*/
SELECT tc.date, uniqExact(tv.ad_id), sum(tc.total_clicks)
FROM
    (select ad.date, ad.ad_id, count(ad.event) as total_views from ads_data as ad
        where ad.event = 'view'
            group by ad.date, ad.ad_id) as tv

FULL OUTER JOIN
    (select ad.date, ad.ad_id, count(ad.event) as total_clicks from ads_data as ad
        where ad.event = 'click'
            group by ad.date, ad.ad_id) as tc
ON tv.ad_id = tc.ad_id
    WHERE tv.total_views = 0 and tc.total_clicks > 0
        GROUP BY tc.date;

/*Из закономерностей можно выделить что активность таких объявлений была всего в течение двух дней.
  Исходя из выводов, сделанных в прошлых заданиях, о наличии выбросов....где было очевидно что с 3 апреля
  произошли какие-то изменения в рекламном бизнесе, смею предположить что данные
  клики по объявлениям не что иное как тестирование рекламнных ссылок перед запуском их на боевую*/