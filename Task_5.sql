/*Есть ли различия в CTR у объявлений с видео и без?
  А чему равняется 95 процентиль CTR по всем объявлениям за 2019-04-04?*/

SELECT (select 'no video') as has_video,
       avg(no_video.CTR_no_video) as average,
       min(no_video.CTR_no_video) as minimum,
       quantileExact(0.25)(no_video.CTR_no_video) as first_quartile,
       quantileExact(0.5)(no_video.CTR_no_video) as second_quartile,
       quantileExact(0.75)(no_video.CTR_no_video) as third_quartile,
       max(no_video.CTR_no_video) as maximum
FROM
        (select countIf(event = 'click') as clicks_no_video,
                countIf(event = 'view')  as views_no_video,
                if(isFinite(clicks_no_video / views_no_video), clicks_no_video / views_no_video, 0) as CTR_no_video
        from ads_data
            where has_video = 0
                group by ad_id) as no_video

UNION ALL

SELECT (select 'with video') as has_video,
       avg(with_video.CTR_with_video) as average,
       min(with_video.CTR_with_video) as minimum,
       quantileExact(0.25)(with_video.CTR_with_video) as first_quartile,
       quantileExact(0.5)(with_video.CTR_with_video) as second_quartile,
       quantileExact(0.75)(with_video.CTR_with_video) as third_quartile,
       max(with_video.CTR_with_video) as maximum
FROM
        (select countIf(event = 'click') as clicks_with_video,
                countIf(event = 'view')  as views_with_video,
                if(isFinite(clicks_with_video / views_with_video), clicks_with_video / views_with_video, 0) as CTR_with_video
        from ads_data
            where has_video = 1
                group by ad_id) as with_video;


/*Как видно из распределения CTR у объявлений с видеобудет получше чем без видео. Все описательные статистики
  имеют большую величину у объявлений с видео чем без него. т.е. пик распределения смешен правее чем у объявлений без видео.
  Так же среднее чуть ближе к медиане в распределении объявлений с видео чем без них. Это говорит о том, что
  гистограмма распределения будет выглядеть более похожей на нормальное распределения, чем гистограмма распредеелия
  объявлений без видео.
  На таких статистиках сложно давать какие-либо выводы, но в целом картина плюс минус понятна...с видео объявления работают лучше
  Для дальнейшего анализа можно использовать полученню выборку и применить дисперсионный анализ.
  Как вариант можно посчитать еще все объявления с видео и без видео и посчитать где CTR нулевой и не нулевой.
  Получим таблицу сопряженности, которую можно будет проанализировать с помощью критерия хи-квадрат */


SELECT quantileExact(0.95)(ctr_table.CTR) as quantile_95
FROM
    (select countIf(event = 'click') as clicks,
            countIf(event = 'view')  as views,
            if(isFinite(clicks / views), clicks / views, 0) as CTR
    from ads_data
        where ads_data.date = '2019-04-04'
            group by ad_id) as ctr_table;


/*95% квантиль CTR по всем объявлениям за 4 апреля 2019 года равняется 0.08333*/