require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'ConcMysql2' do

  describe 'Pool' do

    let(:pool_size) { 3 }
    let(:mysql_clients) do
      Array.new(pool_size) { |i| double(:mysql2_client, socket: i, async_result: i, query: nil, ping: true) }
    end
    let(:clients) do
      allow(Mysql2::Client).to receive(:new).and_return(*mysql_clients)
      Array.new(pool_size) { ConcMysql2::Client.new() }
    end
    let(:pool) do
      allow(ConcMysql2::Client).to receive(:new).and_return(*clients)
      ConcMysql2::Pool.new(size: pool_size)
    end
    let(:ios) { clients.map(&:io) }

    describe 'initialize' do

      it 'should initialize pool with the given pool size' do
        expect(pool.size).to eq(pool_size)
      end

      it 'should initialize mysql clients with the given options' do
        expect(Mysql2::Client).to receive(:new).with(foo: 'foo', bar: 'bar').and_return(*clients)

        ConcMysql2::Pool.new(size: pool_size, foo: 'foo', bar: 'bar')
      end

    end

    describe 'execute' do

      it 'should try to reconnect client if it is not connected' do
        allow(clients.first).to receive(:connected?).and_return(false)
        expect(clients.first).to receive(:reconnect!)

        pool.execute('query')
      end

      it 'should remove client from available_clients when query gets executed' do
        pool.execute('query')

        expect(pool.available_clients.size).to eq(pool_size - 1)
      end

      it 'should add client back to the pool once the query is finished' do
        pool.execute('query').to_s

        expect(pool.size).to eq(pool_size)
      end

      it 'should block until a client is ready if all clients are busy' do
        pool_size.times { pool.execute('query') }

        expect(pool.available_clients).to be_empty

        expect(IO).to receive(:select) do |_ios|
          expect(_ios.map(&:to_i)).to match_array(ios.map(&:to_i))
        end.and_return([[ios.first]])

        pool.execute('query')
      end

      [
          'MySQL server has gone away',
          'Lost connection to MySQL server during query',
          'closed MySQL connection'
      ].each do |exception|

        it "should retry on '#{exception}'" do
          i=0
          allow(clients.first).to receive(:query) do
            raise(Mysql2::Error, exception) if (i+=1) == 1
            'on second try'
          end

          expect(pool.execute('query')).to eq('on second try')
        end

        it "should not retry indefinitely on '#{exception}'" do
          allow(clients.first).to receive(:query).and_raise(Mysql2::Error, exception)

          expect { pool.execute('query') }.to raise_error(Mysql2::Error, exception)
        end

      end

      it 'should not retry on other Mysql2::Error' do
        i=0
        allow(clients.first).to receive(:query) do
          raise(Mysql2::Error, 'foo') if (i+=1) == 1
          'on second try'
        end

        expect { pool.execute('query') }.to raise_error(Mysql2::Error, 'foo')
      end
    end

  end

end
