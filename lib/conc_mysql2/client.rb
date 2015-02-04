module ConcMysql2

  class Client

    def initialize options = {}
      @options = options
      @client = Mysql2::Client.new(options)
      @busy = false
    end

    attr_reader :options, :client, :future

    def query(query_string)
      raise 'client is busy' if busy?

      @busy = true
      client.query(query_string, async: true)

      @future = Future.new(Proc.new {
        res = client.async_result
        @future = nil
        @busy = false
        res
      })
    end

    def busy?
      @busy
    end

    def connected?
      client && client.ping
    end

    def reconnect!
      client.close
      @future = nil
      @busy = false
      @client = Mysql2::Client.new(options)
    end

    def io
      IO::open(client.socket)
    end

    def socket
      client.socket
    end

  end

end
