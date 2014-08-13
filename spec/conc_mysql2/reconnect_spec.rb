require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'ConcMysql2' do

  describe 'Pool' do

    let(:pool_size) { 3 }
    let(:clients) { Array.new(pool_size) { |i| double(:client, socket: i, async_result: i, query: nil, close: nil) } }
    let(:ios) { Array.new(pool_size) { |i| double(:io, to_i: i) } }
    let(:pool) do
      Mysql2::Client.stub(:new).and_return(*clients)
      IO.stub(:open).and_return(*ios)
      ConcMysql2::Pool.new(size: pool_size)
    end
    let(:_clients) { pool.instance_variable_get(:@clients) }
    let(:_futures) { pool.instance_variable_get(:@futures) }

    describe 'execute' do


      it 'should call reconnect! unless connected' do
        allow(pool).to receive(:connected?).and_return(false)
        
        expect(pool).to receive(:reconnect!)

        pool.execute('query')
      end

      it 'should call reconnect! on Errno::EBADF' do
        allow(pool).to receive(:connected?).and_return(true)

        Array.new(pool_size) { pool.execute('query') }

        i=0
        allow(IO).to receive(:select).with(ios, nil, nil, anything) do
          raise Errno::EBADF if (i+=1) == 1
          [[ios.first]]
        end

        expect(pool).to receive(:reconnect!)

        pool.execute('query')
      end

      it 'should call reconnect! on "MySQL server has gone away"' do
        allow(pool).to receive(:connected?).and_return(true)

        expect(clients.last).to receive(:query).and_raise(Mysql2::Error, 'MySQL server has gone away')

        expect(pool).to receive(:reconnect!)

        pool.execute('query')
      end

      it 'should call reconnect! on "Lost connection to MySQL server during query"' do
        allow(pool).to receive(:connected?).and_return(true)

        expect(clients.last).to receive(:query).and_raise(Mysql2::Error, 'Lost connection to MySQL server during query')

        expect(pool).to receive(:reconnect!)

        pool.execute('query')
      end

      it 'should not call reconnect! on other Mysql2::Error' do
        allow(pool).to receive(:connected?).and_return(true)

        expect(clients.last).to receive(:query).and_raise(Mysql2::Error, 'foo')

        expect(pool).to_not receive(:reconnect!)

        expect { pool.execute('query') }.to raise_error(Mysql2::Error, 'foo')
      end

    end

    describe 'reconnect!' do

      it 'should clear futures' do
        allow(pool).to receive(:connected?).and_return(true)

        Array.new(pool_size) { pool.execute('query') }

        expect(_futures.size).to eq(pool_size)

        pool.reconnect!

        expect(_futures.size).to eq(0)
      end

      it 'should initialize new clients and ios' do
        pool #initialize

        clients = Array.new(pool_size) { |i| double(:client, socket: i*10) }
        expect(Mysql2::Client).to receive(:new).and_return(*clients)

        clients.each { |client| expect(IO).to receive(:open).with(client.socket) }

        pool.reconnect!
      end

      it 'should initialize new pool and clients' do
        pool #initialize

        clients = Array.new(pool_size) { double(:client, socket: nil) }
        expect(Mysql2::Client).to receive(:new).and_return(*clients)

        expect(IO).to receive(:open).exactly(3).times

        pool.reconnect!

        new_pool = pool.instance_variable_get(:@pool)
        new_clients = pool.instance_variable_get(:@clients)

        expect(new_pool).to match_array(new_clients)
        expect(new_pool.object_id).not_to eq(new_clients.object_id)
      end

      it 'should close clients' do
        _clients.each { |client| expect(client).to receive(:close) }

        pool.reconnect!
      end

    end

    describe 'connected?' do

      it 'should return true' do
        clients = Array.new(pool_size) { |i| double(:client, socket: i, async_result: i, query: nil, ping: true) }
        pool.instance_variable_set(:@pool, clients)
        expect(pool.connected?).to be_true
      end

      it 'should return false' do
        clients = Array.new(pool_size) { |i| double(:client, socket: i, async_result: i, query: nil, ping: i.odd?) }
        pool.instance_variable_set(:@pool, clients)
        expect(pool.connected?).to be_false
      end

    end

  end

end