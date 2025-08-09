module ActiveRecord
  class Base
    class << self
      alias_method :__original_enum, :enum

      def enum(*args, **kwargs, &block)
        if args.empty? && kwargs.empty?
          puts "🚨 [FATAL] enum called with 0 args on #{self.name}"
          puts caller[0..10].join("\n")
        end

        __original_enum(*args, **kwargs, &block)
      end
    end
  end
end
