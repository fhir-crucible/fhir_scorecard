# Top level include file that brings in all the necessary code
require 'bundler/setup'
require 'fhir_models'

root = File.expand_path '..', File.dirname(File.absolute_path(__FILE__))

FHIR.logger = Logger.new(File.join(root,'logs','fhir_models.log'),1,1024000)

require File.join(root,'lib','scorecard.rb')
require File.join(root,'lib','terminology.rb')
require File.join(root,'lib','rubrics.rb')

Dir.glob(File.join(root, 'lib','rubrics','**','*.rb')).each do |file|
  require file
end