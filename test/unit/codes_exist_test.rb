require_relative '../test_helper'

class BasicTest < Minitest::Test

  # turn off the ridiculous warnings
  $VERBOSE=nil

  def test_codes_exist_none
    patient = FHIR::Patient.new
    bundle = FHIR::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle.to_json)
    assert (report[:points]), 'Scorecard should report points.'
    assert (report[:bundle]), 'Scorecard should report Bundle section.'
    assert (report[:patient]), 'Scorecard should report Patient section.'
    assert (report[:codes_exist]), 'Scorecard should report Codes Exist section.'
    assert (report[:codes_exist][:points]==0), 'Codes Exist section points incorrect.'
  end

  def test_codes_exist_1of3
    patient = FHIR::Patient.new({ 'gender'=>'male' })
    bundle = FHIR::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle.to_json)
    assert (report[:points]), 'Scorecard should report points.'
    assert (report[:bundle]), 'Scorecard should report Bundle section.'
    assert (report[:patient]), 'Scorecard should report Patient section.'
    assert (report[:codes_exist]), 'Scorecard should report Codes Exist section.'
    assert (report[:codes_exist][:points]==3), 'Codes Exist section points incorrect.'
  end

  def test_codes_exist_1of3_wrongtype
    patient = FHIR::Patient.new({ 'gender'=>0 })
    bundle = FHIR::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle.to_json)
    assert (report[:points]), 'Scorecard should report points.'
    assert (report[:bundle]), 'Scorecard should report Bundle section.'
    assert (report[:patient]), 'Scorecard should report Patient section.'
    assert (report[:codes_exist]), 'Scorecard should report Codes Exist section.'
    assert (report[:codes_exist][:points]==0), 'Codes Exist section points incorrect.'
  end

  def test_codes_exist_2of3
    patient = FHIR::Patient.new({ 
      'gender'=>'male', 
      'maritalStatus'=> { 
        'coding'=>[ {'code'=>'S','system'=>'http://hl7.org/fhir/v3/MaritalStatus'} ]
      } 
    })
    bundle = FHIR::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle.to_json)
    assert (report[:points]), 'Scorecard should report points.'
    assert (report[:bundle]), 'Scorecard should report Bundle section.'
    assert (report[:patient]), 'Scorecard should report Patient section.'
    assert (report[:codes_exist]), 'Scorecard should report Codes Exist section.'
    assert (report[:codes_exist][:points]==6), 'Codes Exist section points incorrect.'
  end

  def test_codes_exist_2of3_textonly
    patient = FHIR::Patient.new({ 
      'gender'=>'male', 
      'maritalStatus'=> { 
        'text'=>'Single'
      } 
    })
    bundle = FHIR::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle.to_json)
    assert (report[:points]), 'Scorecard should report points.'
    assert (report[:bundle]), 'Scorecard should report Bundle section.'
    assert (report[:patient]), 'Scorecard should report Patient section.'
    assert (report[:codes_exist]), 'Scorecard should report Codes Exist section.'
    assert (report[:codes_exist][:points]==3), 'Codes Exist section points incorrect.'
  end

  def test_codes_exist_3of3
    patient = FHIR::Patient.new({ 
      'language'=>'en-US',
      'gender'=>'male', 
      'maritalStatus'=> { 
        'coding'=>[ {'code'=>'S','system'=>'http://hl7.org/fhir/v3/MaritalStatus'} ]
      } 
    })
    bundle = FHIR::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle.to_json)
    assert (report[:points]), 'Scorecard should report points.'
    assert (report[:bundle]), 'Scorecard should report Bundle section.'
    assert (report[:patient]), 'Scorecard should report Patient section.'
    assert (report[:codes_exist]), 'Scorecard should report Codes Exist section.'
    assert (report[:codes_exist][:points]==10), 'Codes Exist section points incorrect.'
  end

  def test_codes_exist_with_backbone_elements
    patient = FHIR::Patient.new({ 
      'language'=>'en-US',
      'gender'=>'male', 
      'maritalStatus'=> { 
        'coding'=>[ {'code'=>'S','system'=>'http://hl7.org/fhir/v3/MaritalStatus'} ]
      },
      'communication'=> [
        { 'language'=> { 
            'coding'=>[ {'code'=>'en-US','system'=>'urn:ietf:bcp:47'} ]
          }, 
          'preferred'=> true },
        { 'language'=> { 
            'coding'=>[ {'code'=>'es','system'=>'urn:ietf:bcp:47'} ]
          }
        }
      ]
    })
    bundle = FHIR::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle.to_json)
    assert (report[:points]), 'Scorecard should report points.'
    assert (report[:bundle]), 'Scorecard should report Bundle section.'
    assert (report[:patient]), 'Scorecard should report Patient section.'
    assert (report[:codes_exist]), 'Scorecard should report Codes Exist section.'
    assert (report[:codes_exist][:points]==10), 'Codes Exist section points incorrect.'
  end

  def test_codes_exist_with_backbone_elements_and_array
    patient = FHIR::Patient.new({ 
      'language'=>'en-US',
      'gender'=>'male', 
      'maritalStatus'=> { 
        'coding'=>[ {'code'=>'S','system'=>'http://hl7.org/fhir/v3/MaritalStatus'} ]
      },
      'contact'=> [
        { 'gender'=>'male',
          'relationship'=> [
            {  'coding'=>[ {'code'=>'c','system'=>'http://hl7.org/fhir/v2/0131'} ] }
          ]
        },{ 'gender'=>'female',
          'relationship'=> [
            {  'coding'=>[ {'code'=>'n','system'=>'http://hl7.org/fhir/v2/0131'} ] }
          ]
        }
      ] 
    })
    bundle = FHIR::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle.to_json)
    assert (report[:points]), 'Scorecard should report points.'
    assert (report[:bundle]), 'Scorecard should report Bundle section.'
    assert (report[:patient]), 'Scorecard should report Patient section.'
    assert (report[:codes_exist]), 'Scorecard should report Codes Exist section.'
    assert (report[:codes_exist][:points]==10), 'Codes Exist section points incorrect.'
  end

  def test_codes_exist_with_coding
    encounter = FHIR::Encounter.new({ 
      'language'=>'en-US',
      'status'=>'planned',
      'class'=>{'code'=>'AMB','system'=>'http://hl7.org/fhir/v3/ActCode'}
    })
    bundle = FHIR::Bundle.new({ 'entry'=>[ { 'resource' => encounter.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle.to_json)
    assert (report[:points]), 'Scorecard should report points.'
    assert (report[:bundle]), 'Scorecard should report Bundle section.'
    assert (report[:patient]), 'Scorecard should report Patient section.'
    assert (report[:codes_exist]), 'Scorecard should report Codes Exist section.'
    assert (report[:codes_exist][:points]==5), 'Codes Exist section points incorrect.'
  end

end