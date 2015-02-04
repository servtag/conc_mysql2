require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'ConcMysql2' do

  describe 'Client' do

    let(:query_string) { 'SELECT * FROM foo' }

    let(:mysql2_client) { double(:mysql2_client, async_result: [{'foo' => 1}]) }

    let(:client) do
      allow(Mysql2::Client).to receive(:new).and_return(mysql2_client)
      ConcMysql2::Client.new
    end

    before do
      allow(mysql2_client).to receive(:query)
    end

    describe 'query' do

      it 'should make async query on underlying mysql2_client' do
        expect(mysql2_client).to receive(:query).with(query_string, async: true)

        client.query(query_string)
      end

      it 'should return a future as response' do
        expect(client.query(query_string).class).to eq(ConcMysql2::Future)
      end

      it 'should raise error if client is already busy' do
        client.query(query_string)

        expect { client.query(query_string) }.to raise_error('client is busy')
      end

    end

    describe 'busy?' do

      it 'should return false if client was never used' do
        expect(client.busy?).to be_false
      end

      it 'should return true if client is being used' do
        client.query(query_string)
        expect(client.busy?).to be_true
      end

      it 'should return false if client finished last query' do
        client.query(query_string).__getobj__
        expect(client.busy?).to be_false
      end

    end

    describe 'connected?' do

      it 'should return true if mysql2_client can be pinged' do
        allow(mysql2_client).to receive(:ping).and_return(true)

        expect(client.connected?).to be_true
      end

      it 'should return false if mysql2_client cannot be pinged' do
        allow(mysql2_client).to receive(:ping).and_return(false)

        expect(client.connected?).to be_false
      end

    end

    describe 'reconnect!' do

      let(:options) { {foo: 'bar'} }

      before do
        allow(mysql2_client).to receive(:close)
      end

      it 'should close existing connection' do
        expect(mysql2_client).to receive(:close)

        client.reconnect!
      end

      it 'should nullify the future' do
        client.instance_variable_set(:@future, 'foo')
        client.reconnect!

        expect(client.future).to be_nil
      end

      it 'should open new connection' do
        expect(Mysql2::Client).to receive(:new)
        client.reconnect!
      end

    end

  end

end
