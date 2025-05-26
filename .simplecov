SimpleCov.start 'rails' do
  add_filter '/bin/'
  add_filter '/db/'
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'
  add_filter '/tmp/'

  add_group 'Models', 'app/models'
  add_group 'Services', 'app/services'
  add_group 'Controllers', 'app/controllers'
  add_group 'Helpers', 'app/helpers'
  add_group 'Mailers', 'app/mailers'
  add_group 'Jobs', 'app/jobs'

  minimum_coverage 60
  minimum_coverage_by_file 50
end
