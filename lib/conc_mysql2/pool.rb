module ConcMysql2

  class Pool

    def initialize(options = { })
      @pool    = Array.new(options.delete(:size) || 5) { Mysql2::Client.new(options) }
      @ios     = @pool.map { |client| IO::open(client.socket) }
      @futures = { }
    end

    def execute(query_string)
      while (client = @pool.pop).nil? do
        if (ready = IO::select(@ios, nil, nil, 1))
          ready.flatten.each { |io| @futures[io.to_i].__getobj__ }
        end
      end

      client.query(query_string, async: true)

      @futures[client.socket] = Future.new(Proc.new {
        res = client.async_result
        @futures.delete(client.socket)
        @pool.push(client)
        res
      })
    end

  end

end
