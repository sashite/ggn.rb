# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.pattern = "test/**/test_*.rb"
  t.verbose = true
  t.warning = true
end

Dir["tasks/**/*.rake"].each { |t| load t }

task default: %i[
  test
]
