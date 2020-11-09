/*1. Получить статистику по дням. Просто посчитать число всех событий по дням, число показов, число кликов,
  число уникальных объявлений и уникальных кампаний.*/

select ad.date,
       countIf(ad.event = 'view') as total_views,
       countIf(ad.event = 'click') as total_clicks,
       uniqExact(ad.ad_id) as unique_ads,
       uniqExact(ad.campaign_union_id) as total_campaings
    from ads_data as ad
        group by ad.date;

/*Существенный скачок в показах прошел 4 и 5 мая при этом количество рекламных объявлений и компаний выросло
  незначительно*/

