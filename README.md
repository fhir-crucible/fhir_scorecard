# fhir_scorecard [![Build Status](https://travis-ci.org/fhir-crucible/fhir_scorecard.svg?branch=master)](https://travis-ci.org/fhir-crucible/fhir_scorecard)

`fhir_scorecard` provides a scorecard for a FHIR Patient Record (as Bundle). Achieving interoperability
of a Patient Healthcare Record within FHIR will require agreement on "best practices" beyond the base specification.
Those agreements could be in the form of an Implementation Guide, with associated Profiles, but `fhir_scorecard`
provides them in the form of testable rubrics.

This project borrows inspiration and rubrics from [ccdaScorecard](https://github.com/chb/ccdaScorecard),
a scorecard for C-CDA documents.

## Scorecard on the Command Line

```
$ bundle exec rake fhir:score[fhir_bundle.json]

  POINTS            CATEGORY   MESSAGE
  ------            --------   -------
    10                bundle   Patient Record is a FHIR Bundle.
    10               patient   Patient Record contains one FHIR Patient.
     2           codes_exist   21% (282/1323) of codes, Codings, and CodeableConcepts had values. Maximum of 10 points.
     4            codes_umls   42% (145/344) of SNOMED, LOINC, RxNorm, ICD9, and ICD10 validated against UMLS. Maximum of 10 points.
     0          descriptions   7% (26/344) of SNOMED, LOINC, RxNorm, ICD9, and ICD10 codes use preferred descriptions. Maximum of 10 points.
    17          completeness   85% of REQUIRED Resources and 9% of EXPECTED Resources were present. Maximum of 20 points.
    10     cvx_immunizations   100% (6/6) of Immunization vaccine codes use CVX. Maximum of 10 points.
     0       cvx_medications   0% (0/4) of Medication[x] Resource codes use CVX. Maximum of 10 point penalty.
     3         iso8601_dates   30% (149/494) of date/time/dateTime/instant fields were populated with reasonable iso8601 values. Maximum of 10 points.
     6            loinc_labs   68% (75/110) of Observations and DiagnosticReports validated against the LOINC Top 2000. Maximum of 10 points.
     8       ucum_quantities   83% (80/96) of physical quantities used or declared UCUM. Maximum of 10 points.
     4    references_resolve   43% (326/750) of all possible References resolved locally within the Bundle. Maximum of 10 points.
    10           rxnorm_meds   100% (4/4) of Medication[x] Resource codes use RxNorm. Maximum of 10 points.
     0        smoking_status   The Patient Record should include Smoking Status (DAF-core-smokingstatus profile on Observation).
     2           snomed_core   29% (5/17) of Condition Resource codes use the SNOMED Core Subset. Maximum of 10 points.
     2           vital_signs   22% (2/9) of Vital Signs had at least one recorded Observation. Maximum of 10 points.
  ------
    88                 TOTAL


```

## Scorecard in Ruby

```ruby
bundle_json = "{\"entry\":[{\"resource\":{\"resourceType\":\"Patient\"}}],\"resourceType\":\"Bundle\"}"
scorecard = FHIR::Scorecard.new
report = scorecard.score(bundle_json)
=> {:bundle=>{:points=>10, :message=>"Patient Record is a FHIR Bundle."},
    :patient=>{:points=>10, :message=>"Patient Record contains one FHIR Patient."},
    :points=>20}
```

## Optional Terminology Support

The scorecard requires some terminology files to operate several rubrics related
to codes. Download the files (requires accounts) and place them in `./terminology`

- https://www.nlm.nih.gov/research/umls/licensedcontent/umlsknowledgesources.html
 - When installing the metathesaurus, include the following sources:
  `CVX|CVX;
   ICD10CM|ICD10CM;
   ICD10PCS|ICD10PCS;
   ICD9CM|ICD9CM;
   LNC|LNC;
   MTHICD9|ICD9CM;
   RXNORM|RXNORM;
   SNOMEDCT_US|SNOMEDCT`

- https://www.nlm.nih.gov/research/umls/Snomed/core_subset.html
- http://loinc.org/usage/obs/loinc-top-2000-plus-loinc-lab-observations-us.csv
- http://download.hl7.de/documents/ucum/concepts.tsv

After downloading the files, run these rake tasks to post-process each terminology file:

```
> bundle exec rake fhir:process_umls
> bundle exec rake fhir:process_snomed
> bundle exec rake fhir:process_loinc
> bundle exec rake fhir:process_ucum
```

# License

Copyright 2016 The MITRE Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
