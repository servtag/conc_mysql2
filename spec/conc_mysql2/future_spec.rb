require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'ConcMysql2' do

  describe 'Future' do

    describe '__getobj__' do

      it 'should call proc' do
        future = ConcMysql2::Future.new(Proc.new { 4711 })

        expect(future).to eq(4711)
      end

      it 'should call proc only once' do
        future = ConcMysql2::Future.new(proc = Proc.new { 'ignored' })

        expect(proc).to receive(:call).once.and_return(4711)

        10.times { future.__getobj__ }
      end

    end

    describe 'method_missing' do

      it 'should delegate method size to proc-result' do
        future = ConcMysql2::Future.new(Proc.new { [4711] })

        expect(future.size).to eq(1)
      end

      it 'should delegate method + to proc-result' do
        future = ConcMysql2::Future.new(Proc.new { 4711 })

        expect(future + 1).to eq(4712)
      end

    end

  end

end
