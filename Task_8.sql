/*А есть ли такие объявления, по которым сначала произошел клик, а только потом показ?*/

select * from ads_data limit 10;

/*Насколько я могу судить, сделать подобный анализ можно только по первым показама/кликам.
  Другими словами если у нас первый клик в рекламе наступает раньше первого показа, то это не есть хорошо.
  Поскольку у нас нет идентификатора пользователя другого решения задачи я пока не вижу.
  Таким образом в рамках решения такой задачи нужно взять отсортированный массив по показам для каждого объявления
  и отсортированный массив по кликам для каждого объявления, причем сделать это лучше в разрезе платформ. 
  Из этих двух массивов взять самый первый клик и самый первый просмотр и если время первого клика будет меньше времени первого просмотра, то получается
  что мы выявили именно такую ситуацию*/

SELECT (select 'ios') as platform,
       fv_ios.ad_id,
       if(fv_ios.first_view_ios = '1970-01-01 00:00:00', null, fv_ios.first_view_ios) as first_view_ios,
       if(fc_ios.first_click_ios = '1970-01-01 00:00:00', null, fc_ios.first_click_ios) as first_click_ios

FROM
    (select ad.ad_id, arrayElement(arraySort(groupArray(ad.time)), 1) as first_view_ios
    from ads_data as ad
        where ad.event = 'view' and ad.platform ='ios'
            group by ad.ad_id) as fv_ios
FULL JOIN
    (select ad.ad_id, arrayElement(arraySort(groupArray(ad.time)), 1) as first_click_ios
    from ads_data as ad
        where ad.event = 'click' and ad.platform ='ios'
            group by ad.ad_id) as fc_ios
ON fv_ios.ad_id = fc_ios.ad_id
where (fv_ios.first_view_ios > fc_ios.first_click_ios) and (isNotNull(first_click_ios) = 1)

UNION ALL

SELECT (select 'android') as platform,
       fv_andr.ad_id,
       if(fv_andr.first_view_andr = '1970-01-01 00:00:00', null, fv_andr.first_view_andr) as first_view_andr,
       if(fc_ios.first_click_andr = '1970-01-01 00:00:00', null, fc_ios.first_click_andr) as first_click_andr

FROM
    (select ad.ad_id, arrayElement(arraySort(groupArray(ad.time)), 1) as first_view_andr
    from ads_data as ad
        where ad.event = 'view' and ad.platform ='android'
            group by ad.ad_id) as fv_andr
FULL JOIN
    (select ad.ad_id, arrayElement(arraySort(groupArray(ad.time)), 1) as first_click_andr
    from ads_data as ad
        where ad.event = 'click' and ad.platform ='android'
            group by ad.ad_id) as fc_ios
ON fv_andr.ad_id = fc_ios.ad_id
where (fv_andr.first_view_andr > fc_ios.first_click_andr)and (isNotNull(first_click_andr) = 1)

UNION ALL

SELECT (select 'web') as platform,
       fv_web.ad_id,
       if(fv_web.first_view_web = '1970-01-01 00:00:00', null, fv_web.first_view_web)   as first_view_web,
       if(fc_web.first_click_web = '1970-01-01 00:00:00', null, fc_web.first_click_web) as first_click_web

FROM
    (select ad.ad_id, arrayElement(arraySort(groupArray(ad.time)), 1) as first_view_web
    from ads_data as ad
        where ad.event = 'view' and ad.platform ='web'
            group by ad.ad_id) as fv_web
FULL JOIN
    (select ad.ad_id, arrayElement(arraySort(groupArray(ad.time)), 1) as first_click_web
    from ads_data as ad
        where ad.event = 'click' and ad.platform ='web'
            group by ad.ad_id) as fc_web
ON fv_web.ad_id = fc_web.ad_id
where (fv_web.first_view_web > fc_web.first_click_web)and (isNotNull(first_click_web) = 1);

/*В итоге получается 46 записей в разрезе платформ у которых время первого клика наступает быстрее
  чем время первого просмотра. Как ведут себя остальные просмотры/клики сложно судить, потому что
  нельзя взаимно-однозначно их сопоставить.*/
