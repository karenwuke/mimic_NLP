
select count(distinct hadm_id),HOSPITAL_EXPIRE_FLAG from mimic.mimiciii.admissions a group by HOSPITAL_EXPIRE_FLAG

with cte as (select dischtime-ADMITTIME as lengthof,hadm_id from mimic.mimiciii.admissions a ) select count(*) from cte where lengthof = 0

select * from mimic.mimiciii.admissions where dischtime is null

drop materialized view if exists stroke_patients_admissions;

create materialized view stroke_patients_admissions as
	select 
		a.*,
		date_part('day' , age(a.dischtime,a.admittime)) as lengthofstay,
		a.hospital_expire_flag  as isdead,
		case when 
			exists
				(select 1 from mimic.mimiciii.admissions re where
					re.subject_id = a.subject_id and
					re.admittime between a.dischtime and (a.dischtime +  INTERVAL '30 day')::DATE) then 1
			else 0 end as IsReadmitted
	from mimic.mimiciii.admissions a 
	left join mimic.mimiciii.diagnoses_icd d 
		on a.hadm_id = d.hadm_id 
	where d.icd9_code in ('430','431','434');

create materialized view stroke_patients_admissions as
	select 
		a.*,
		d.icd9_code ,
		date_part('day' , age(a.dischtime,a.admittime)) as lengthofstay,
		a.hospital_expire_flag  as isdead,
		case when 
			exists
				(select 1 from mimic.mimiciii.admissions re where
					re.subject_id = a.subject_id and
					date_part('day' , age(re.admittime ,a.dischtime )) between 1 and 30) then 1
			else 0 end as IsReadmitted
	from mimic.mimiciii.admissions a 
	left join mimic.mimiciii.diagnoses_icd d 
		on a.hadm_id = d.hadm_id 
	where d.icd9_code in ('433','434','436');

select * from mimic.mimiciii.diagnoses_icd d where d.icd9_code in ('433','434','436');
	
select count(*),IsReadmitted from stroke_patients_admissions where lengthofstay >=0 group by IsReadmitted

select count(*),isdead from stroke_patients_admissions where lengthofstay > INTERVAL '0 day' group by isdead

select * from stroke_patients_admissions where IsReadmitted = 1 and lengthofstay >=0 and subject_id = 99166 order by subject_id

select * from mimic.mimiciii.admissions a 
--	left join mimic.mimiciii.diagnoses_icd d 
--		on a.hadm_id = d.hadm_id 
		where a.subject_id = 103

select * from stroke_patients_admissions where subject_id = 103

select subject_id, max(isdead) from stroke_patients_admissions spa where isreadmitted 

with cte as (
	select distinct subject_id from stroke_patients_admissions spa where isreadmitted = 1)
	select
		c.subject_id,
		max(isdead)
	from cte c left join stroke_patients_admissions s on c.subject_id = s.subject_id group by c.subject_id 

select count(*) from stroke_patients_admissions where IsReadmitted = 1 and hospital_expire_flag = 1

select count(*) from stroke_patients_admissions where lengthofstay > INTERVAL '0 day'

select count(*), hadm_id , category from mimic.mimiciii.noteevents n where category = 'Discharge summary' group by 2,3 having count(*)>1

select * from mimic.mimiciii.noteevents n where hadm_id = 144859

select * from stroke_patients_admissions_withnotes where isreadmitted = 1 order by subject_id --lengthofstay > INTERVAL '0 day'

create materialized view stroke_patients_admissions_notes_backup as
	select * from stroke_patients_admissions_withnotes
