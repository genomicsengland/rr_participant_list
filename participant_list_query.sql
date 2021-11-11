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
    select sp.uid
    from pmi.study_participant sp
    join pmi.concept it_c on sp.identifier_type_cid = it_c.uid
    where sp.identifier_value not ilike 'g%' and
        floor(sp.identifier_value::int / 1000000) in (0, 100, 200, 900) and 
        it_c.concept_code = '100k_participant_id'
),
_100k_full_withdrawals as (
    /* get all study participant uids for those with full withdrawals */
    select uid
    from all_tags
    where tag = '100k_full_withdrawals'
),
_100k_research_ineligible_cohorts as (
    /* get all study participant uids for those in ineligible cohorts */
    select uid
    from all_tags
    where tag = '100k_research_ineligible_cohorts'
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
