drop materialized view if exists admissions_withnextadm;

create materialized view admissions_withnextadm as
	select 
		date_part('day' , age(a.dischtime,a.admittime)) as lengthofstay,
		a.hospital_expire_flag  as isdead,
		lead (admittime) over (partition by a.subject_id order by admittime asc)as next_admtime,
		lead (admission_type ) over (partition by a.subject_id order by admittime asc) as next_admtype,
		--d.icd9_code,
		a.*
	from mimic.mimiciii.admissions a ;
--	left join mimic.mimiciii.diagnoses_icd d 
--		on a.hadm_id = d.hadm_id
	--where d.icd9_code in ('430','431','434');

select * from admissions_withnextadm where subject_id in (61,67)

drop materialized view if exists stroke_patients_admissions;
create materialized view stroke_patients_admissions as
	select 
		a.hadm_id,
		d.icd9_code,
		a.subject_id 
	from mimic.mimiciii.admissions a
	inner join mimic.mimiciii.diagnoses_icd d 
		on d.icd9_code in ('430','431','434') and a.hadm_id = d.hadm_id;
	
drop materialized view if exists stroke_patients_admissions2;
create materialized view stroke_patients_admissions2 as
	select 
		a.hadm_id,
		d.icd9_code,
		a.subject_id 
	from mimic.mimiciii.admissions a
	inner join mimic.mimiciii.diagnoses_icd d 
		on d.icd9_code in ('430','431','434','433','436') and a.hadm_id = d.hadm_id;
	
select count(distinct hadm_id ) from stroke_patients_admissions group by hadm_id having count (*)> 1

select * from mimic.mimiciii.admissions where hadm_id = 108196
	
	
drop materialized view if exists stroke_adminfo;
create materialized view stroke_adminfo as
	select
		date_part('day' , age(a.next_admtime,a.dischtime)) as reDays,
		a.*
	from admissions_withnextadm a
	where exists (select 1 from stroke_patients_admissions s where s.hadm_id = a.hadm_id);

select count(*),next_admtype from public.stroke_adminfo where isdead = 0 and reDays <= 30 group by next_admtype

	
select * from mimic.mimiciii.admissions where subject_id in (61,67)

select * from stroke_adminfo where subject_id in (61,67)

select count(distinct hadm_id) from stroke_patients_admissions



select * from stroke_patients_admissions where subject_id in (198,203,274) and icd9_code in ('430','431','434')

select count(*), hadm_id , category from mimic.mimiciii.noteevents n where category = 'Discharge summary' group by 2,3 having count(*)>1
select * from mimic.mimiciii.noteevents where hadm_id = 102164

drop view if exists note;
create view note as
	select
		a.*,
		case when n.category is null then 0 else 1 end as hasDischargeSum,
		n.text as summary
	from stroke_adminfo a
	left join mimic.mimiciii.noteevents n
	on a.hadm_id = n.hadm_id and n.category = 'Discharge summary' and description = 'Report';

select nt.hadm_id from note nt group by nt.hadm_id having count(*)>1

select count(*),hospital_expire_flag from note where category is null group by hospital_expire_flag

select * from note where category is null and hospital_expire_flag = 0

with cte as (
	select 
		a.*,
		row_number () over (partition by hadm_id) as i
	from note a)
	select * from cte where i = 1 and isdead = 0


select count(*) from stroke_adminfo

