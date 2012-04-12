require './app'
require 'rack/fiber_pool'


map '/' do
  use Rack::FiberPool
  run Tutorial::App.new
end

