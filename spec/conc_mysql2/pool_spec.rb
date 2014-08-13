require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'ConcMysql2' do

  describe 'Pool' do

    let(:pool_size) { 3 }
    let(:clients) { Array.new(pool_size) { |i| double(:client, socket: i, async_result: i, query: nil, ping: true) } }
    let(:ios) { ios = Array.new(pool_size) { |i| double(:io, to_i: i) } }
    let(:pool) do
      allow(Mysql2::Client).to receive(:new).and_return(*clients)
      allow(IO).to receive(:open).and_return(*ios)
      ConcMysql2::Pool.new(size: pool_size)
    end
    let(:_pool) { pool.instance_variable_get(:@pool) }
    let(:_futures) { pool.instance_variable_get(:@futures) }

    describe 'initialize' do

      it 'should initialize pool with the given pool size' do
        expect(_pool.size).to eq(pool_size)
      end

      it 'should initialize mysql clients with the given options' do
        allow(IO).to receive(:open).and_return(*ios)
        expect(Mysql2::Client).to receive(:new).with(foo: 'foo', bar: 'bar').and_return(*clients)

        ConcMysql2::Pool.new(size: pool_size, foo: 'foo', bar: 'bar')
      end

    end

    describe 'execute' do

      it 'should remove client from pool when query gets executed' do
        expect(_pool.size).to eq(pool_size)

        pool.execute('query')

        expect(_pool.size).to eq(pool_size - 1)
      end

      it 'should add client back to the pool once the query is finished' do
        expect(_pool.size).to eq(pool_size)

        pool.execute('query').to_s

        expect(_pool.size).to eq(pool_size)
      end

      it 'should block until a client is ready if all clients are busy' do
        expect(_pool.size).to eq(pool_size)

        pool_size.times { pool.execute('query') }

        expect(_pool).to be_empty

        expect(IO).to receive(:select).with(ios, nil, nil, anything).and_return([[ios.first]])

        expect(pool.execute('query')).to eq(0)
      end

      it 'should not leak futures on future eval' do
        expect(_futures).to be_empty

        results = Array.new(pool_size) { pool.execute('query') }

        expect(_futures.size).to eq(pool_size)

        results.each(&:to_i)

        expect(_futures).to be_empty
      end

      it 'should not leak futures on busy pool' do
        expect(_futures).to be_empty

        results = Array.new(pool_size) { pool.execute('query') }

        expect(_futures.size).to eq(pool_size)

        expect(IO).to receive(:select).with(ios, nil, nil, anything).and_return([[ios.first]])

        pool.execute('query')

        expect(_futures.size).to eq(pool_size)

        results.each(&:to_i)

        expect(_futures.size).to eq(1)
      end

    end

  end

end
