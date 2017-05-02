# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "fhir_scorecard"
  s.summary = "Scorecard for a FHIR Patient Record (as Bundle)"
  s.description = "A Gem for scoring FHIR Patient Records (as Bundles)"
  s.email = "jwalonoski@mitre.org"
  s.homepage = "https://github.com/fhir-crucible/fhir_scorecard"
  s.authors = ["Jason Walonoski"]
  s.version = '3.0.1'

  s.files = s.files = `git ls-files`.split("\n")

  s.add_runtime_dependency 'fhir_models', '>= 3.0.0'
end
