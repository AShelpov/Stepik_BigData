/*Какая платформа самая популярная для размещения рекламных объявлений?
  Сколько процентов показов приходится на каждую из платформ (колонка platform)?*/

select * from ads_data limit 10;

with (select count(ad.event) from ads_data as ad where ad.event = 'view') as total_views,
     (select count(ad.event) from ads_data as ad where ad.event = 'click') as total_clicks

SELECT pv.platform, (pv.views_per_platform / total_views * 100) as views_percantage,
       (pc.clicks_per_platform / total_clicks * 100) as clicks_percentage
FROM
    (select ad.platform, count(ad.platform) as views_per_platform from ads_data as ad
        where ad.event = 'view'
            group by ad.platform) as pv

LEFT JOIN
    (select ad.platform, count(ad.platform) as clicks_per_platform from ads_data as ad
        where ad.event = 'click'
            group by ad.platform) as pc
ON pv.platform = pc.platform
    ORDER BY pv.views_per_platform DESC;

/*ну собственно как и следовало ожидать наиболее популярная платформа это андроид. Из-за того что устройств
  на андроиде тупо больше всего*/