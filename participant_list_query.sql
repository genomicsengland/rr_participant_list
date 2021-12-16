-- query to generate the participant list and populate a table with it
drop table if exists rr_participant_list.participant_list;
create table rr_participant_list.participant_list as 
with all_tags as (
    /* get all the tag data so subqueries are quicker */
    select distinct tm.study_participant_uid as uid
        ,c.concept_code as tag
    from pmi.tag_membership tm
    join pmi.concept c on tm.tag_cid = c.uid
),
_100k_test_participants as (
    /* get all study participant uids that are test participants */
    select t.uid
--    from pmi.study_participant sp
--    join pmi.concept it_c on sp.identifier_type_cid = it_c.uid
--    where sp.identifier_value not ilike 'g%' and
--        floor(sp.identifier_value::int / 1000000) in (0, 100, 200, 900) and 
--        it_c.concept_code = '100k_participant_id'
    from all_tags t
    where tag = '100K_test_ids'
),
_100k_full_withdrawals as (
    /* get all study participant uids for those with full withdrawals */
    select uid
    from all_tags
    where tag = '100k_full_withdrawals'
),
_100k_research_ineligible_cohorts as (
    /* get all study participant uids for those in ineligible cohorts */
    select t.uid
    from all_tags t
    join pmi.study_participant sp on sp.uid = t.uid
    where tag = '100k_research_ineligible_cohorts' and sp.identifier_value not in (
        /* need to add back in Bridge participants as currently being excluded by PMI */
        '111005433',
        '111005435',
        '111005437',
        '111005440',
        '111005442',
        '111005444',
        '111005446',
        '111005448',
        '111005453',
        '111005455',
        '111005464',
        '111005471',
        '111005474',
        '111005475',
        '111005480',
        '111005486',
        '111005487',
        '111005497',
        '111005498',
        '111005502',
        '111005508',
        '111005510',
        '111005511',
        '111005513',
        '111005515',
        '111005516',
        '111005517',
        '111005518',
        '111005519',
        '111005524',
        '111005526',
        '111005527',
        '111005530',
        '111005533',
        '111005534',
        '111005537',
        '111005538',
        '111005541',
        '111005543',
        '111005809',
        '111005819',
        '111005821',
        '111005822',
        '111005823',
        '111005824',
        '111005825',
        '111005829',
        '111005831',
        '111005832',
        '111005833',
        '111005834',
        '111005838',
        '111005841',
        '111005843',
        '111005845',
        '111005847',
        '111005849',
        '111005852',
        '111005854',
        '111005855',
        '111005858',
        '111005859',
        '111005860',
        '111005862',
        '111005863',
        '111005866',
        '111005867',
        '111005868',
        '111005869',
        '111005874',
        '111005876',
        '111005894',
        '111005895',
        '111005898',
        '111005899',
        '111005902',
        '111005904',
        '111005905',
        '111005909',
        '111005911',
        '111005912',
        '111005913',
        '111005915',
        '111005916',
        '111005917',
        '111005919',
        '111005921',
        '111005926',
        '111005928',
        '111005943',
        '111005944',
        '111005945',
        '111005951',
        '111005954',
        '111005956',
        '111005959',
        '111005966',
        '111005967',
        '111005970',
        '111005971',
        '111005978',
        '111005980',
        '111005981',
        '111005983',
        '111005985',
        '111005991',
        '111005992',
        '111005993',
        '111006001',
        '111006003',
        '111006004',
        '111006006',
        '111006012',
        '111006018',
        '111006019',
        '111006023',
        '111006024',
        '111006027',
        '111006028',
        '111006029',
        '111006030',
        '111006349',
        '111006350',
        '111006353',
        '111006354',
        '111006355',
        '111006357',
        '111006359',
        '111006360',
        '111006361',
        '111006367',
        '111006368',
        '111006371',
        '111006374',
        '111006375',
        '111006380',
        '111006381',
        '111006382',
        '111006385',
        '111006387',
        '111006388',
        '111006389',
        '111006393',
        '111006404',
        '111006405',
        '111006406',
        '111006407',
        '111006408',
        '111006418',
        '111006419',
        '111005484',
        '111005952',
        '111005514',
        '111006376',
        '111005503',
        '111005492',
        '111006391',
        '111006377',
        '111006009',
        '111005509',
        '111005430',
        '111005431',
        '111005432',
        '111005434',
        '111005439',
        '111005445',
        '111005447',
        '111005454',
        '111005456',
        '111005457',
        '111005458',
        '111005460',
        '111005461',
        '111005463',
        '111005465',
        '111005466',
        '111005467',
        '111005473',
        '111005476',
        '111005477',
        '111005478',
        '111005481',
        '111005482',
        '111005485',
        '111005489',
        '111005495',
        '111005496',
        '111005499',
        '111005500',
        '111005520',
        '111005521',
        '111005522',
        '111005523',
        '111005525',
        '111005528',
        '111005529',
        '111005531',
        '111005532',
        '111005535',
        '111005536',
        '111005539',
        '111005540',
        '111005542',
        '111005820',
        '111005826',
        '111005827',
        '111005828',
        '111005830',
        '111005835',
        '111005836',
        '111005837',
        '111005839',
        '111005840',
        '111005846',
        '111005848',
        '111005851',
        '111005853',
        '111005856',
        '111005857',
        '111005864',
        '111005870',
        '111005872',
        '111005877',
        '111005891',
        '111005892',
        '111005893',
        '111005896',
        '111005897',
        '111005900',
        '111005901',
        '111005903',
        '111005906',
        '111005908',
        '111005910',
        '111005914',
        '111005918',
        '111005920',
        '111005922',
        '111005923',
        '111005924',
        '111005925',
        '111005927',
        '111005929',
        '111005930',
        '111005932',
        '111005947',
        '111005948',
        '111005950',
        '111005960',
        '111005961',
        '111005962',
        '111005963',
        '111005964',
        '111005965',
        '111005969',
        '111005973',
        '111005975',
        '111005977',
        '111005979',
        '111005982',
        '111005984',
        '111005986',
        '111005988',
        '111005989',
        '111005990',
        '111005994',
        '111005995',
        '111005996',
        '111005998',
        '111005999',
        '111006005',
        '111006007',
        '111006008',
        '111006010',
        '111006011',
        '111006013',
        '111006014',
        '111006015',
        '111006016',
        '111006017',
        '111006020',
        '111006022',
        '111006026',
        '111006031',
        '111006351',
        '111006358',
        '111006362',
        '111006365',
        '111006370',
        '111006373',
        '111006379',
        '111006383',
        '111006384',
        '111006386',
        '111006394',
        '111006395',
        '111006411',
        '111006412',
        '111006413',
        '111006417',
        '111005410',
        '111005479',
        '111006410',
        '111005493',
        '111005494',
        '111005512',
        '111005507',
        '111005483',
        '111005987',
        '111006378',
        '111005997',
        '111006409',
        '230000000',
        '111006396',
        '111005490'
    )
    union
    /* need to add in manually a number of EOC participant who aren't currently
    picked up by PMI */
    select sp.uid
    from pmi.study_participant sp
    join pmi.concept it_c on sp.identifier_type_cid = it_c.uid
    where it_c.concept_code = '100k_participant_id' and 
    sp.identifier_value in (
        '233000244',
        '233000254',
        '233000229',
        '233000228',
        '233000223',
        '233000227',
        '233000211',
        '233000222',
        '233000300',
        '233000248',
        '233000210',
        '233000333',
        '233000331',
        '233000232',
        '233000328',
        '233000252',
        '233000353',
        '233000329',
        '233000240',
        '233000334',
        '233000253',
        '233000339',
        '233000242',
        '233000330',
        '233000235',
        '233000335',
        '233000356',
        '233000321',
        '233000241',
        '233000355',
        '233000354',
        '233000363',
        '233000359',
        '233000338',
        '233000344',
        '233000230',
        '233000238',
        '233000365',
        '233000324',
        '233000327',
        '233000218',
        '233000233',
        '233000360',
        '233000220',
        '233000226',
        '233000216',
        '233000224',
        '233000373',
        '233000340',
        '233000362',
        '233000374',
        '233000375',
        '233000208',
        '233000319',
        '233000219',
        '233000336',
        '233000205',
        '233000357',
        '233000343',
        '233000225',
        '233000371',
        '233000214',
        '233000306',
        '233000217',
        '233000209',
        '233000221',
        '233000304',
        '233000325',
        '233000337',
        '233000323',
        '233000212',
        '233000351',
        '233000367',
        '233000215',
        '233000308',
        '233000361',
        '233000207',
        '230000000',
        '233000213',
        '233000352',
        '233000358',
        '233000326',
        '233000303',
        '233000310',
        '233000370',
        '233000316',
        '233000332',
        '233000364',
        '233000366',
        '233000234',
        '233000372',
        '233000249',
        '233000301',
        '233000348',
        '233000206',
        '233000236',
        '233000243',
        '233000314',
        '233000311',
        '233000312',
        '233000320',
        '233000349',
        '233000313',
        '233000345',
        '233000305',
        '233000322',
        '233000309',
        '233000368',
        '233000350',
        '233000341',
        '233000342',
        '233000231',
        '233000347',
        '233000317',
        '233000302',
        '233000346',
        '233000307',
        '233000318',
        '233000369',
        '233000245',
        '233000247',
        '233000250',
        '233000315',
        '233000251',
        '233000239',
        '233000246',
        '233000237'
    )
),
_100k_on_child_consent as (
    /* get all study participant uids for those who we believe are currently
    child consent */
    select uid
    from all_tags
    where tag = '100k_on_child_consent'
),
_100k_dob as (
    /* get best guess at dob for every 100k participant, need to get top-ranked
    data as well as most recent unranked as some study participants are not a
    person and therefore their data groups don't get ranked currently */
    select dg.identifier_value as participant_id 
        ,de.value_datetime as date_of_birth
        ,dg.rank
        ,row_number() over (partition by dg.identifier_value order by
            dg.date_created desc) as rn
    from pmi.data_group dg
    join pmi.concept c_dg on dg.data_group_type_cid = c_dg.uid 
    join pmi.data_element de on dg.uid = de.data_group_uid 
    join pmi.concept c_de on de.field_type_cid = c_de.uid
    join pmi.concept c_it on dg.identifier_type_cid = c_it.uid
    where c_dg.concept_code = 'date_of_birth' and
        c_dg.codesystem = 'data_group' and 
        c_de.concept_code = 'date_of_birth' and
        c_de.codesystem = 'data_element' and 
        c_it.concept_code = '100k_participant_id' and
        c_it.codesystem = 'identifier_type' and
        dg.stale = false and dg.blacklisted = false
),
_100k_over_16 as (
    /* work out who will be 16 or over a month after release based on their
    best guess of dob */
    select participant_id
    from _100k_dob
    join rr_participant_list.release r on true
    where (rank = 1 or (rank is null and rn = 1)) and
        extract(year from age(
            r.release_date + interval '1 month', date_of_birth
        )) >= 16
),
_100k_ineligible as (
    /* get study participant uid for all 100k participants who have an
    ineligibility data group (so no sample sent or fail MR)
    needs the distinct as there are some participants with multiple
    ineligibility data groups*/
    select distinct sp.uid 
    from pmi.study_participant sp
    join pmi.data_group dg
        on dg.identifier_value = sp.identifier_value and
        dg.identifier_type_cid = sp.identifier_type_cid 
    join pmi.concept dg_c
        on dg.data_group_type_cid = dg_c.uid 
    join pmi.concept it_c
        on dg.identifier_type_cid = it_c.uid
    where dg_c.concept_code = '100k_ineligibility' and
        dg.blacklisted = false and
        dg.stale = false and 
        it_c.concept_code = '100k_participant_id' and 
        /* need to manually not exclude some participants as PMI wrongly failing
        them */
        sp.identifier_value not in (
            '117000309',
            '122006762',
            '111004512',
            '115017910',
            '112000056',
            '118003463',
            '115013311',
            '115003305',
            '120001116',
            '112003271',
            '111004516',
            '122000007',
            '210019145',
            '111004511',
            '111000013',
            '111004515',
            '114001604',
            '117000291',
            '111004517',
            '120000582',
            '115016335',
            '120000581',
            '115017391',
            '120000512',
            '120000946',
            '117002256',
            '111000000',
            '118003461',
            '112000878'
        )
)
/* bring it all together */
select sp.identifier_value as participant_id
    /* make the expired participant flag - any participant who is over 16 and
    on a child consent form */
    ,case when 
        _100k_on_child_consent.uid is not null and _100k_over_16.participant_id is not null then true 
        else false 
     end as expired_participant
    ,dob.date_of_birth::date as date_of_birth
    ,_100k_test_participants.uid is not null as test_participant
    ,_100k_full_withdrawals.uid is not null as full_withdrawal
    ,_100k_research_ineligible_cohorts.uid is not null as ineligible_cohort
    ,_100k_on_child_consent.uid is not null as on_child_consent
    ,_100k_over_16.participant_id is not null as over_16
    ,_100k_ineligible.uid is not null as ineligible
    ,_100k_test_participants.uid is null and 
    _100k_full_withdrawals.uid is null and 
    _100k_research_ineligible_cohorts.uid is null and
    _100k_ineligible.uid is null as eligible_for_release
    ,now() as de_datetime
from pmi.study_participant sp 
join pmi.concept c on sp.identifier_type_cid = c.uid 
left join _100k_test_participants on _100k_test_participants.uid = sp.uid
left join _100k_full_withdrawals on _100k_full_withdrawals.uid = sp.uid
left join _100k_research_ineligible_cohorts on _100k_research_ineligible_cohorts.uid = sp.uid
left join _100k_on_child_consent on _100k_on_child_consent.uid = sp.uid
left join _100k_ineligible on _100k_ineligible.uid = sp.uid
left join _100k_over_16 on _100k_over_16.participant_id = sp.identifier_value
left join (select * from _100k_dob where rank = 1 or (rank is null and rn = 1)) dob on dob.participant_id = sp.identifier_value 
where c.concept_code = '100k_participant_id' and c.codesystem = 'identifier_type'
;
