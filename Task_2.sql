/*2. Разобраться, почему случился такой скачок 2019-04-05? Каких событий стало больше?
  У всех объявлений или только у некоторых?*/

/*Чтобы разобраться в этой ситуации нужно что-то типо сводной таблицы где будет видно движение
  количества показов/кликов для конкретной рекламы. По индексу будет номер релкламной компании по столбцам даты.
  Проанализируем 3,4 и 5 апреля и отсортируем по максимальному количеству за 5 апреля. Построим отдельно запросы
  для показов и кликов*/

select ad.ad_id,
       length(groupArrayIf((ad.ad_id), ad.event = 'view' and ad.date = '2019-04-03')) as views_per_ads_03,
       length(groupArrayIf((ad.ad_id), ad.event = 'view' and ad.date = '2019-04-04')) as views_per_ads_04,
       length(groupArrayIf((ad.ad_id), ad.event = 'view' and ad.date = '2019-04-05')) as views_per_ads_05
from ads_data as ad
    group by ad.ad_id
        order by views_per_ads_05 desc
            limit 100;

/*Как видно по показам рост произошел за счет нескольких компаний под номерами 112583, 107729, 28142 и 107837
  Судя по всему 4 апреля стартовали либо новые рекламные компании, либо сменилась бизнес-модель, либо поменялся учет показов,
  потому что по 100 наиболее показываемым рекламам не было в принципе активности до 4 апреля. При этом если сгруппировать
  по полю total_views_per_03_April или total_views_per_04_April будет видно что по рекламным компаниям наиболее активным 3 апреля
  эта активность снижается и сходит на нет 4 и 5 апреля. Ну и в целом эту тенденцию можно проследить по всем компаниям активность коотрых
  начиналась до 4 апреля*/


select ad.ad_id,
       length(groupArrayIf((ad.ad_id), ad.event = 'click' and ad.date = '2019-04-03')) as clicks_per_ads_03,
       length(groupArrayIf((ad.ad_id), ad.event = 'click' and ad.date = '2019-04-04')) as clicks_per_ads_04,
       length(groupArrayIf((ad.ad_id), ad.event = 'click' and ad.date = '2019-04-05')) as clicks_per_ads_05
from ads_data as ad
    group by ad.ad_id
        order by clicks_per_ads_05 desc
            limit 100;


/*Основной рост кликов пришелся также на рекламные компании 112583 и 38892 причем рекламной компании 38892 вроде
  не было в топ 10 по просмотрам. Над сравнить. Ну и в целом картинка такая же. Компании по которым было наибольшее число
  кликов 3 апреля постепенно снижают свою активность на нет к 5 апреля*/

select ad.ad_id,
       length(groupArrayIf((ad.ad_id), ad.event = 'view' and ad.date = '2019-04-05')) as total_views,
       length(groupArrayIf((ad.ad_id), ad.event = 'click' and ad.date = '2019-04-05')) as total_clicks
from ads_data as ad
    group by ad.ad_id
    having ad.ad_id = 38892;


/*А не, все норм....))*/
