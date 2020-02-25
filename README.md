# mimic_NLP
Stroke analysis from MIMIC III dataset with multiple NLP modules.

All the tutorial and experiments are done on Mac OSX.

#### Download MIMIC III raw csv data

Finish the test from [this site](https://mimic.physionet.org/gettingstarted/access/) and get approved from the MIT MIMIC III team. Then you are able to access the data from [physionet.org](https://physionet.org/content/mimiciii/1.4/).

The data will take about 100GB, so try to mount the large volume disk in your computer, in my case I mount the external hard drive at `/Volumes/YOUR_DISK_NAME`. Since all the files are compressed csv formats, download them with the following command:

```sh
cd /Volumes/YOUR_DISK_NAME
mkdir mimic_data
cd mimic_data
wget -r -N -c -np --user YOUR_USER_NAME --ask-password https://physionet.org/files/mimiciii/1.4/
```

where `YOUR_USER_NAME` is the username you applied from [physionet.org](https://physionet.org/content/mimiciii/1.4/).

#### Install PostgreSQL
 - install `postgresql` from homebrew using the following command: `brew install postgresql`
 - start postgresql service : `brew services start postgresql`
 
#### Build MIMIC III Database

Go to your hard drive directory `/Volumes/YOUR_DISK_NAME` and clone the mimic-code repo:

```sh
git clone https://github.com/MIT-LCP/mimic-code
cd mimic-code/buildmimic/postgres
```

Now we are inside the `postgres` directory which contains bunch of `.sql` scripts. Let's start from here and build the `postgresql` databse use the following instructions: 

 - install `postgresql` from homebrew using the following command: `brew install postgresql`
 - start the `postgresql` service with the following command: `brew services start postgresql`
 - connect with postgresql : `psql -U username -d postgres`

### Data Wrangling
 - Find acute stroke patient `ICD code：hemorrhagic stroke (I60–I62; 430-431) and ischemic stroke (I63; 434)` from diagnoses_icd table. 
 - ADMISSIONS — a table containing admission and discharge dates (has a unique identifier HADM_ID for each admission)
 - NOTEEVENTS — contains all notes for each hospitalization (links with HADM_ID). There are detailed information in text column and note catorgary. 
 - For target variables:
 1.length of stay.
 2.30-day readmission.
 3.Mortality.
 
 There are 58976 records in admission table with 46520 distinct	patients, within them, there are 1912 distinct patient and 2025	admissions with diagnosis with acute stroke, there are 8 record that should be recognized as invalid since their discharge time is before admission time. When look into those target variables, the samples fall into the following table:

|               | Yes |  No  |
|:-------------:|:---:|:----:|
|    Is Dead    | 584 | 1433 |
| Is Readmitted |  83 | 1934 |
