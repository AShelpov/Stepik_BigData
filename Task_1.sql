/*1. Получить статистику по дням. Просто посчитать число всех событий по дням, число показов, число кликов,
  число уникальных объявлений и уникальных кампаний.*/

SELECT views.date as date, views.total_views as total_views, clicks.total_clicks as total_clicks,
       unique_ads.total_unique_ads as total_unique_ads, total_comp.total_campaigns as total_campaigns FROM
    (select ad.date, count(ad.event) as total_views
                from ads_data ad
                where ad.event = 'view'
                group by ad.date) as views

LEFT JOIN
    (select ad.date, count(ad.event) as total_clicks from ads_data ad
                where ad.event = 'click'
                group by ad.date) as clicks
ON views.date = clicks.date

LEFT JOIN
    (select ad.date, uniqExact(ad.ad_id) as total_unique_ads from ads_data ad
        group by ad.date) as unique_ads
ON views.date = unique_ads.date

LEFT JOIN
        (select ad.date, uniqExact(ad.campaign_union_id) as total_campaigns from ads_data ad
            group by ad.date) as total_comp
ON views.date = total_comp.date;

/*Существенный скачок в показах прошел 4 и 5 мая при этом количество рекламных объявлений и компаний выросло
  незначительно*/

