/*3. Найти топ 10 объявлений по CTR за все время. CTR — это отношение всех кликов объявлений к просмотрам.
  Например, если у объявления было 100 показов и 2 клика, CTR = 0.02.
  Различается ли средний и медианный CTR объявлений в наших данных?*/

select ad_id,
       countIf(event = 'click') as clicks,
       countIf(event = 'view')  as views,
       if(isFinite(clicks / views), clicks / views, 0) as CTR
from ads_data
    group by ad_id
        order by CTR desc
            limit 10;


/*Сравнение медианы и среднего*/

SELECT avg(ctr_table.CTR) as average_ctr,
       quantile(0.5)(ctr_table.CTR) as ctr_meadian
    from
    (select countIf(event = 'click') as clicks,
            countIf(event = 'view')  as views,
            if(isFinite(clicks / views), clicks / views, 0) as CTR
    from ads_data
        group by ad_id) as ctr_table;

/*Медиана и среднее различается, причем достаточно существенно. Среднее больше на порядок,
  это говорит о перекосе в распределении CTR в левую сторону, т.е. пик приходится на компании с наименьшим CTR
  короче распределение CTR не нормально если говорить яхыком статистики))*/