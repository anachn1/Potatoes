require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  require 'rspec'
  require 'rack/test'
  require_relative '../server'

  include Rack::Test::Methods

  def app
  	Sinatra::Application
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.

end
