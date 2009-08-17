class Time

  # this code adds a Time.freeze method to make time "stand still"
  # during execution of a block. This can be helpful during testing of
  # methods that depend on Time.new or Time.now
  #
  # Example:
  #
  #   Time.freeze do
  #      puts Time.new.to_f
  #      # ... do stuff; real time passes
  #      puts Time.new.to_f     # outputs same time as above
  #   end
  #   # ... time returns to normal
  #
  # An optional Time object may be passed to freeze to a specific time:
  #
  #   Time.freeze(Time.at(2007, 11, 15)) do
  #      # ...
  #   end
  #
  # While inside the block, Time.frozen? will return true

  class << self

    def now
      @time || orig_new
    end

    alias_method :orig_freeze, :freeze
    alias_method :orig_new, :new
    alias_method :new, :now

    # makes time "stand still" during execution of a block. if no time is
    # supplied, the current time is used. While in the block, Time.new and
    # Time.now will always return the "frozen" value.
    def freeze(time = nil)
      raise "A block is required" unless block_given?
      begin
        prev = @time
        @time = time || now
        yield
      ensure
        @time = prev
      end
    end

    def frozen?
      !@time.nil?
    end

  end
end
