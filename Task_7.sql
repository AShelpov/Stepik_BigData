/*Какая платформа самая популярная для размещения рекламных объявлений?
  Сколько процентов показов приходится на каждую из платформ (колонка platform)?*/

select * from ads_data limit 10;

with (select count(ad.event) from ads_data as ad where ad.event = 'view') as total_views,
     (select count(ad.event) from ads_data as ad where ad.event = 'click') as total_clicks
select (select 'ios') as platform,
       countIf(ad.event = 'view') / total_views as views_distrib,
       countIf(ad.event = 'click') / total_clicks as clicks_distrib
from ads_data as ad
    where ad.platform = 'ios'
        group by ad.platform

UNION ALL

with (select count(ad.event) from ads_data as ad where ad.event = 'view') as total_views,
     (select count(ad.event) from ads_data as ad where ad.event = 'click') as total_clicks
select (select 'web') as platform,
       countIf(ad.event = 'view') / total_views as views_distrib,
       countIf(ad.event = 'click') / total_clicks as clicks_distrib
from ads_data as ad
    where ad.platform = 'web'
        group by ad.platform

UNION ALL

with (select count(ad.event) from ads_data as ad where ad.event = 'view') as total_views,
     (select count(ad.event) from ads_data as ad where ad.event = 'click') as total_clicks
select (select 'android') as platform,
       countIf(ad.event = 'view') / total_views as views_distrib,
       countIf(ad.event = 'click') / total_clicks as clicks_distrib
from ads_data as ad
    where ad.platform = 'android'
        group by ad.platform
;

/*ну собственно как и следовало ожидать наиболее популярная платформа это андроид. Из-за того что устройств
  на андроиде тупо больше всего*/