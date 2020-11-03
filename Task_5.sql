/*Есть ли различия в CTR у объявлений с видео и без?
  А чему равняется 95 процентиль CTR по всем объявлениям за 2019-04-04?*/

SELECT (select 'no video') as has_video,
       avg(if(isFinite(tc_nv.total_clicks_no_vid / tv_nv.total_views_no_vid),
          (tc_nv.total_clicks_no_vid / tv_nv.total_views_no_vid), 0)) as average,
       min(if(isFinite(tc_nv.total_clicks_no_vid / tv_nv.total_views_no_vid),
          (tc_nv.total_clicks_no_vid / tv_nv.total_views_no_vid), 0)) as min,
       quantile(0.25)(if(isFinite(tc_nv.total_clicks_no_vid / tv_nv.total_views_no_vid),
               (tc_nv.total_clicks_no_vid / tv_nv.total_views_no_vid), 0)) as first_quantile,
       quantile(0.5)(if(isFinite(tc_nv.total_clicks_no_vid / tv_nv.total_views_no_vid),
               (tc_nv.total_clicks_no_vid / tv_nv.total_views_no_vid), 0)) as second_quantile,
       quantile(0.75)(if(isFinite(tc_nv.total_clicks_no_vid / tv_nv.total_views_no_vid),
               (tc_nv.total_clicks_no_vid / tv_nv.total_views_no_vid), 0)) as third_quantile,
       max(if(isFinite(tc_nv.total_clicks_no_vid / tv_nv.total_views_no_vid),
          (tc_nv.total_clicks_no_vid / tv_nv.total_views_no_vid), 0)) as max
FROM
    (select ad.ad_id, count(ad.event) as total_views_no_vid from ads_data as ad
        where ad.event = 'view' and ad.has_video = 0
            group by ad.ad_id) as tv_nv

FULL OUTER JOIN
    (select ad.ad_id, count(ad.event) as total_clicks_no_vid from ads_data as ad
        where ad.event = 'click' and ad.has_video = 0
            group by ad.ad_id) tc_nv
ON tv_nv.ad_id = tc_nv.ad_id

UNION ALL

SELECT (select 'with video') as has_video,
       avg(if(isFinite(tc_nv.total_clicks_no_vid / tv_nv.total_views_no_vid),
          (tc_nv.total_clicks_no_vid / tv_nv.total_views_no_vid), 0)) as average,
       min(if(isFinite(tc_nv.total_clicks_no_vid / tv_nv.total_views_no_vid),
          (tc_nv.total_clicks_no_vid / tv_nv.total_views_no_vid), 0)) as min,
       quantile(0.25)(if(isFinite(tc_nv.total_clicks_no_vid / tv_nv.total_views_no_vid),
               (tc_nv.total_clicks_no_vid / tv_nv.total_views_no_vid), 0)) as first_quantile,
       quantile(0.5)(if(isFinite(tc_nv.total_clicks_no_vid / tv_nv.total_views_no_vid),
               (tc_nv.total_clicks_no_vid / tv_nv.total_views_no_vid), 0)) as second_quantile,
       quantile(0.75)(if(isFinite(tc_nv.total_clicks_no_vid / tv_nv.total_views_no_vid),
               (tc_nv.total_clicks_no_vid / tv_nv.total_views_no_vid), 0)) as third_quantile,
       max(if(isFinite(tc_nv.total_clicks_no_vid / tv_nv.total_views_no_vid),
          (tc_nv.total_clicks_no_vid / tv_nv.total_views_no_vid), 0)) as max
FROM
    (select ad.ad_id, count(ad.event) as total_views_no_vid from ads_data as ad
        where ad.event = 'view' and ad.has_video = 1
            group by ad.ad_id) as tv_nv

FULL OUTER JOIN
    (select ad.ad_id, count(ad.event) as total_clicks_no_vid from ads_data as ad
        where ad.event = 'click' and ad.has_video = 1
            group by ad.ad_id) tc_nv
ON tv_nv.ad_id = tc_nv.ad_id;

/*Как видно из распределения CTR у объявлений с видеобудет получше чем без видео. Все описательные статистики
  имеют большую величину у объявлений с видео чем без него. т.е. пик распределения смешен правее чем у объявлений без видео.
  Так же среднее чуть ближе к медиане в распределении объявлений с видео чем без них. Это говорит о том, что
  гистограмма распределения будет выглядеть более похожей на нормальное распределения, чем гистограмма распредеелия
  объявлений без видео.
  На таких статистиках сложно давать какие-либо выводы, но в целом картина плюс минус понятна...с видео объявления работают лучше
  Для дальнейшего анализа можно использовать полученню выборку и применить дисперсионный анализ.
  Как вариант можно посчитать еще все объявления с видео и без видео и посчитать где CTR нулевой и не нулевой.
  Получим таблицу сопряженности, которую можно будет проанализировать с помощью критерия хи-квадрат */



SELECT quantile(0.95)(if(isFinite(tc_nv.total_clicks_no_vid / tv_nv.total_views_no_vid),
               (tc_nv.total_clicks_no_vid / tv_nv.total_views_no_vid), 0)) as quantile_95
FROM
    (select ad.ad_id, count(ad.event) as total_views_no_vid from ads_data as ad
        where ad.event = 'view' and ad.date = '2019-04-04'
            group by ad.ad_id) as tv_nv

FULL OUTER JOIN
    (select ad.ad_id, count(ad.event) as total_clicks_no_vid from ads_data as ad
        where ad.event = 'click' and ad.date = '2019-04-04'

            group by ad.ad_id) tc_nv
ON tv_nv.ad_id = tc_nv.ad_id;

/*95% квантиль CTR по всем объявлениям за 4 апреля 2019 года равняется 0.08209*/