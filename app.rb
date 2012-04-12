require "em-synchrony"
require 'yaml' 
require "em-synchrony/mysql2"


class DefferBody
  include EventMachine::Deferrable
  
  def <<(chunk)
    @callback.call(chunk)
    self
  end

  def each(&blk)
    @callback = blk
  end
end

module Tutorial
  class App

    def config
      @config ||= YAML.load_file('database.yml').inject({}) do |res,kv|
        k,v = kv
        res[k.to_sym]=v
        res
      end
    end

    def initialize(*arg)
      puts config
      @db = EventMachine::Synchrony::ConnectionPool.new(:size=> 10) do
        Mysql2::EM::Client.new config
      end
    end

    def call(env)
      body = DefferBody.new
      env['async.callback'].call([200, {'Content-Type' => 'text/plain'}, body])

      res = @db.aquery('SELECT SLEEP(0.1)')

      res.callback do |res|
        body << res.to_a.to_s
        body.succeed
      end

      res.errback do |e|
        puts e.message, e.backtrace
        body.succeed
      end

      [-1, {}, []]
    end

  end
end


