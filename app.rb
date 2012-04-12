require "em-synchrony"
require 'yaml' 
require "em-synchrony/mysql2"

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
      @db = EventMachine::Synchrony::ConnectionPool.new(:size=> 150) do
        Mysql2::EM::Client.new config
      end
    end

    def call(env)
      begin
        res = @db.query('SELECT SLEEP(0.1)')
        [200, {}, res.to_a]
      rescue Exception => e
        puts e.message, e.backtrace
        [500, {}, []]
      end
    end

  end
end


