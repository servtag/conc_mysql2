module ConcMysql2

  RECONNECT_ERROR_MESSAGES = [
      'MySQL server has gone away',
      'Lost connection to MySQL server during query'
  ]

  class Pool

    def initialize(options = { })
      @size = options.delete(:size)
      @clients = []
      @ios = []
      @futures = {}
      @options = options
      reconnect!
    end

    attr_reader :size, :options

    def execute(query_string)
      reconnect! unless connected?

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
    rescue Mysql2::Error, Errno::EBADF => e
      raise e if e.is_a?(Mysql2::Error) && !RECONNECT_ERROR_MESSAGES.include?(e.message)
      reconnect!
      connected? ? execute(query_string) : raise(e)
    end

    def reconnect!
      @clients.each(&:close)
      @clients = Array.new(size || 5) { Mysql2::Client.new(options) }

      @pool = @clients.dup

      @ios = @pool.map { |client| IO::open(client.socket) }

      @futures.clear
    end

    def connected?
      @pool.inject(true) { |bool, client| bool && client.ping }
    end

  end

end
