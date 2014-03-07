module ConcMysql2

  class Future < Delegator

    def initialize(proc)
      super
      @proc = proc
    end

    def __getobj__
      @value ||= @proc.call
    end

    def __setobj__(_)
      #noop
    end

  end

end
