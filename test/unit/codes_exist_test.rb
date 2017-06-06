require_relative '../test_helper'

class CodesExistTest < Minitest::Test

  # turn off the ridiculous warnings
  $VERBOSE=nil

  def test_codes_exist_none_stu3
    patient = FHIR::Patient.new
    bundle = FHIR::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle)
    assert_sections_exist(report, :points, :bundle, :patient, :codes_exist)
    assert (report[:codes_exist][:points]==0), "Codes Exist section points incorrect (#{report[:codes_exist][:points]}!=0)."
  end

  def test_codes_exist_1of3_stu3
    patient = FHIR::Patient.new({ 'gender'=>'male' })
    bundle = FHIR::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle)
    assert_sections_exist(report, :points, :bundle, :patient, :codes_exist)
    assert (report[:codes_exist][:points]==3), "Codes Exist section points incorrect (#{report[:codes_exist][:points]}!=3)."
  end

  def test_codes_exist_1of3_wrongtype_stu3
    patient = FHIR::Patient.new({ 'gender'=>0 })
    bundle = FHIR::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle)
    assert_sections_exist(report, :points, :bundle, :patient, :codes_exist)
    assert (report[:codes_exist][:points]==0), "Codes Exist section points incorrect (#{report[:codes_exist][:points]}!=0)."
  end

  def test_codes_exist_2of3_stu3
    patient = FHIR::Patient.new({ 
      'gender'=>'male', 
      'maritalStatus'=> { 
        'coding'=>[ {'code'=>'S','system'=>'http://hl7.org/fhir/v3/MaritalStatus'} ]
      } 
    })
    bundle = FHIR::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle)
    assert_sections_exist(report, :points, :bundle, :patient, :codes_exist)
    assert (report[:codes_exist][:points]==6), "Codes Exist section points incorrect (#{report[:codes_exist][:points]}!=6)."
  end

  def test_codes_exist_2of3_textonly_stu3
    patient = FHIR::Patient.new({ 
      'gender'=>'male', 
      'maritalStatus'=> { 
        'text'=>'Single'
      } 
    })
    bundle = FHIR::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle)
    assert_sections_exist(report, :points, :bundle, :patient, :codes_exist)
    assert (report[:codes_exist][:points]==3), "Codes Exist section points incorrect (#{report[:codes_exist][:points]}!=3)."
  end

  def test_codes_exist_3of3_stu3
    patient = FHIR::Patient.new({ 
      'language'=>'en-US',
      'gender'=>'male', 
      'maritalStatus'=> { 
        'coding'=>[ {'code'=>'S','system'=>'http://hl7.org/fhir/v3/MaritalStatus'} ]
      } 
    })
    bundle = FHIR::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle)
    assert_sections_exist(report, :points, :bundle, :patient, :codes_exist)
    assert (report[:codes_exist][:points]==10), "Codes Exist section points incorrect (#{report[:codes_exist][:points]}!=10)."
  end

  def test_codes_exist_with_backbone_elements_stu3
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
    report = scorecard.score(bundle)
    assert_sections_exist(report, :points, :bundle, :patient, :codes_exist)
    assert (report[:codes_exist][:points]==10), "Codes Exist section points incorrect (#{report[:codes_exist][:points]}!=10)."
  end

  def test_codes_exist_with_backbone_elements_and_array_stu3
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
    report = scorecard.score(bundle)
    assert_sections_exist(report, :points, :bundle, :patient, :codes_exist)
    assert (report[:codes_exist][:points]==10), "Codes Exist section points incorrect (#{report[:codes_exist][:points]}!=10)."
  end

  def test_codes_exist_with_coding_stu3
    encounter = FHIR::Encounter.new({ 
      'language'=>'en-US',
      'status'=>'planned',
      'class'=>{'code'=>'AMB','system'=>'http://hl7.org/fhir/v3/ActCode'}
    })
    bundle = FHIR::Bundle.new({ 'entry'=>[ { 'resource' => encounter.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle)
    assert_sections_exist(report, :points, :bundle, :patient, :codes_exist)
    assert (report[:codes_exist][:points]==5), "Codes Exist section points incorrect (#{report[:codes_exist][:points]}!=5)."
  end

  def test_codes_exist_none_dstu2
    patient = FHIR::DSTU2::Patient.new( 'active' => true )
    bundle = FHIR::DSTU2::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle)
    assert_sections_exist(report, :points, :bundle, :patient, :codes_exist)
    assert (report[:codes_exist][:points]==0), "Codes Exist section points incorrect (#{report[:codes_exist][:points]}!=0)."
  end

  def test_codes_exist_1of3_dstu2
    patient = FHIR::DSTU2::Patient.new({ 'gender'=>'male' })
    bundle = FHIR::DSTU2::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle)
    assert_sections_exist(report, :points, :bundle, :patient, :codes_exist)
    assert (report[:codes_exist][:points]==3), "Codes Exist section points incorrect (#{report[:codes_exist][:points]}!=3)."
  end

  def test_codes_exist_1of3_wrongtype_dstu2
    patient = FHIR::DSTU2::Patient.new({ 'gender'=>0 })
    bundle = FHIR::DSTU2::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle)
    assert_sections_exist(report, :points, :bundle, :patient, :codes_exist)
    assert (report[:codes_exist][:points]==0), "Codes Exist section points incorrect (#{report[:codes_exist][:points]}!=0)."
  end

  def test_codes_exist_2of3_dstu2
    patient = FHIR::DSTU2::Patient.new({ 
      'gender'=>'male', 
      'maritalStatus'=> { 
        'coding'=>[ {'code'=>'S','system'=>'http://hl7.org/fhir/v3/MaritalStatus'} ]
      } 
    })
    bundle = FHIR::DSTU2::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle)
    assert_sections_exist(report, :points, :bundle, :patient, :codes_exist)
    assert (report[:codes_exist][:points]==6), "Codes Exist section points incorrect (#{report[:codes_exist][:points]}!=6)."
  end

  def test_codes_exist_2of3_textonly_dstu2
    patient = FHIR::DSTU2::Patient.new({ 
      'gender'=>'male', 
      'maritalStatus'=> { 
        'text'=>'Single'
      } 
    })
    bundle = FHIR::DSTU2::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle)
    assert_sections_exist(report, :points, :bundle, :patient, :codes_exist)
    assert (report[:codes_exist][:points]==3), "Codes Exist section points incorrect (#{report[:codes_exist][:points]}!=3)."
  end

  def test_codes_exist_3of3_dstu2
    patient = FHIR::DSTU2::Patient.new({ 
      'language'=>'en-US',
      'gender'=>'male', 
      'maritalStatus'=> { 
        'coding'=>[ {'code'=>'S','system'=>'http://hl7.org/fhir/v3/MaritalStatus'} ]
      } 
    })
    bundle = FHIR::DSTU2::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle)
    assert_sections_exist(report, :points, :bundle, :patient, :codes_exist)
    assert (report[:codes_exist][:points]==10), "Codes Exist section points incorrect (#{report[:codes_exist][:points]}!=10)."
  end

  def test_codes_exist_with_backbone_elements_dstu2
    patient = FHIR::DSTU2::Patient.new({ 
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
    bundle = FHIR::DSTU2::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle)
    assert_sections_exist(report, :points, :bundle, :patient, :codes_exist)
    assert (report[:codes_exist][:points]==10), "Codes Exist section points incorrect (#{report[:codes_exist][:points]}!=10)."
  end

  def test_codes_exist_with_backbone_elements_and_array_dstu2
    patient = FHIR::DSTU2::Patient.new({ 
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
    bundle = FHIR::DSTU2::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle)
    assert_sections_exist(report, :points, :bundle, :patient, :codes_exist)
    assert (report[:codes_exist][:points]==10), "Codes Exist section points incorrect (#{report[:codes_exist][:points]}!=10)."
  end

  def test_codes_exist_with_coding_dstu2
    encounter = FHIR::DSTU2::Encounter.new({ 
      'language'=>'en-US',
      'status'=>'planned',
      'class'=>'ambulatory'
    })
    bundle = FHIR::DSTU2::Bundle.new({ 'entry'=>[ { 'resource' => encounter.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle)
    assert_sections_exist(report, :points, :bundle, :patient, :codes_exist)
    assert (report[:codes_exist][:points]==5), "Codes Exist section points incorrect (#{report[:codes_exist][:points]}!=5)."
  end

  def assert_sections_exist(report, *sections)
    sections.each do |section|
      assert(report[section], "Scorecard should report #{section} section.")
    end
  end

end