# fhir_scorecard [![Build Status](https://travis-ci.org/fhir-crucible/fhir_scorecard.svg?branch=master)](https://travis-ci.org/fhir-crucible/fhir_scorecard)

Scorecard for a FHIR Patient Record (as Bundle)

```ruby
bundle_json = "{\"entry\":[{\"resource\":{\"resourceType\":\"Patient\"}}],\"resourceType\":\"Bundle\"}"
scorecard = FHIR::Scorecard.new
report = scorecard.score(bundle_json)
=> {:bundle=>{:points=>10, :message=>"Patient Record is a FHIR Bundle."},
    :patient=>{:points=>10, :message=>"Patient Record contains one FHIR Patient."},
    :points=>20}
```

# Optional Terminology Support

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

Then, run rake tasks to post-process each terminology file:

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
