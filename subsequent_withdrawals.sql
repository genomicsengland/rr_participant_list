-- query to check for newly ineligible participants
-- only checking for new withdrawals or new ineligibility
with all_tags as (
    /* get all the tag data so subqueries are quicker */
    select distinct tm.study_participant_uid as uid
        ,c.concept_code as tag
    from pmi.tag_membership tm
    join pmi.concept c on tm.tag_cid = c.uid
),
_100k_full_withdrawals as (
    /* get all study participant uids for those with full withdrawals */
    select uid
    from all_tags
    where tag = '100k_full_withdrawals'
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
        it_c.concept_code = '100k_participant_id'
)
select sp.identifier_value
from pmi.study_participant sp
join (select uid from _100k_full_withdrawals union select uid from _100k_ineligible) ineligible 
    on ineligible.uid = sp.uid
join (select participant_id from rr_participant_list.participant_list where eligible_for_release = true) pl 
    on pl.participant_id = sp.identifier_value
join pmi.concept it_c 
    on it_c.uid = sp.identifier_type_cid 
where it_c.concept_code = '100k_participant_id'
;
