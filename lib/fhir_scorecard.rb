# Top level include file that brings in all the necessary code
require 'bundler/setup'
require 'fhir_models'
require 'fhir_dstu2_models'

root = File.expand_path '..', File.dirname(File.absolute_path(__FILE__))

require File.join(root,'lib','scorecard.rb')
require File.join(root,'lib','terminology.rb')
require File.join(root,'lib','implementation_guides.rb')
require File.join(root,'lib','rubrics.rb')
require File.join(root,'lib','fhir_helper.rb')

Dir.glob(File.join(root, 'lib','rubrics','**','*.rb')).each do |file|
  require file
end