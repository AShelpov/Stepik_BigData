/*3. Найти топ 10 объявлений по CTR за все время. CTR — это отношение всех кликов объявлений к просмотрам.
  Например, если у объявления было 100 показов и 2 клика, CTR = 0.02.
  Различается ли средний и медианный CTR объявлений в наших данных?*/

select * from ads_data limit 10;

SELECT tv.ad_id as ad_id,
       if(isFinite(tc.total_clicks / tv.total_views), (tc.total_clicks / tv.total_views), 0) as CTR
FROM
    (select ad.ad_id as ad_id, count(ad.event) as total_views  from ads_data ad
        where ad.event = 'view'
            group by ad.ad_id) as tv

FULL OUTER JOIN
    (select ad.ad_id as ad_id, count(ad.event) as total_clicks  from ads_data ad
        where ad.event = 'click'
            group by ad.ad_id) as tc
ON tv.ad_id = tc.ad_id
    ORDER BY CTR DESC

        LIMIT 10;


/*Сравнение медианы и среднего*/
SELECT avg(if(isFinite(tc.total_clicks / tv.total_views), (tc.total_clicks / tv.total_views), 0)) as average,
       median(if(isFinite(tc.total_clicks / tv.total_views), (tc.total_clicks / tv.total_views), 0)) as median
FROM
    (select ad.ad_id as ad_id, count(ad.event) as total_views  from ads_data ad
        where ad.event = 'view'
            group by ad.ad_id) as tv

FULL OUTER JOIN
    (select ad.ad_id as ad_id, count(ad.event) as total_clicks  from ads_data ad
        where ad.event = 'click'
            group by ad.ad_id) as tc
ON tv.ad_id = tc.ad_id;

/*Медиана и среднее различается, причем достаточно существенно. Среднее больше на порядок,
  это говорит о перекосе в распределении CTR в левую сторону, т.е. пик приходится на компании с наименьшим CTR
  короче распределение CTR не нормально если говорить яхыком статистики))*/