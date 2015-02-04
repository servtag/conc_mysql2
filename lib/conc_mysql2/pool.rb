module ConcMysql2

  RECONNECT_ERROR_MESSAGES = [
      'MySQL server has gone away',
      'Lost connection to MySQL server during query',
      'closed MySQL connection'
  ]

  class Pool

    def initialize(options = { })
      @size = options.delete(:size)
      @clients = Array.new(size || 5) { ConcMysql2::Client.new(options) }
    end

    attr_reader :clients, :size

    def execute(query_string)
      tries ||= size
      while (client = available_client).nil? do
        if (ready = IO::select(clients.map(&:io), nil, nil, 1))
          ready.flatten.each { |io| client_by_io(io.to_i).future.__getobj__ }
        end
      end

      client.reconnect! unless client.connected?
      client.query(query_string)
    rescue Mysql2::Error, Errno::EBADF => e
      raise e if e.is_a?(Mysql2::Error) && !RECONNECT_ERROR_MESSAGES.include?(e.message)
      retry unless (tries-=1).zero?
      raise e
    end

    def available_client
      available_clients.first
    end

    def available_clients
      clients.select { |client| !client.busy? }
    end

    def client_by_io(io)
      clients.select { |client| client.io.to_i == io.to_i }.first
    end

  end

end
