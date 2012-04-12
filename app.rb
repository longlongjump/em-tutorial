require "em-synchrony"
require 'yaml' 
require "em-synchrony/mysql2"


class DefferBody

  include EventMachine::Deferrable
  
  def <<(chunk)
    @callback.call(chunk)
  end

  def each(&blk)
    @callback = @blk
  end
end

module Tutorial
  class App

    def initialize(*arg)
      config = YAML.load_file('database.yml')
      @db = EventMachine::Synchrony::ConnectionPool.new(:size=> 150) do
        Mysql2::EM::Client.new config
      end
    end

    def call(env)

      body = DefferBody.new

      env['async.callback'].call [200, {}, body]

      res = @db.aquery('SELECT SLEEP(0.1)')
      res.callback do |res|
        body << res.to_a.to_s
        body.succeed
      end

      res.errback do |e|
        body.succeed
      end


      [-1,{}, []]
    end

  end
end


