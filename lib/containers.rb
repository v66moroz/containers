require_relative "containers/version"

module Containers

  # Immutable container
  class IBox
    include Enumerable

    class << self
      def [](*args)
        new(*args)
      end
    end

    def initialize(pairs)
      pairs = pairs.to_a.clone

      eigen_class =
        class << self
          self
        end

      eigen_class.instance_eval do
        pairs.each do |k, v|
          define_method(k) do
            v
          end
        end

        define_method(:each) do |&block|
          if block
            pairs.each(&block)
          else
            pairs.each
          end
        end
      end
    end

    def get_binding
      binding
    end

    def inspect
      "#<IBox: #{map { |k, v| "#{k}=#{v.inspect}"}.join(', ')}>"
    end
  end

  # Immutable lambda container
  class LBox
    include Enumerable

    class << self
      def [](*args)
        new(*args)
      end
    end

    def initialize(pairs)
      pairs = pairs.to_a.clone

      eigen_class =
        class << self
          self
        end

      eigen_class.instance_eval do
        pairs.each do |k, p|
          define_method(k, &p.to_proc)
        end

        define_method(:each) do |&block|
          if block
            pairs.each(&block)
          else
            pairs.each
          end
        end
      end

      def get_binding
        binding
      end
    end

    def inspect
      "#<LBox: #{map { |k, p| "#{k}=#{p.inspect}"}.join(', ')}>"
    end
  end

  class << self

    def ibox(ps)
      ps = 
        ps.map do |k, p|
          [k, p.to_proc]
        end
      ->(x) do
        IBox.new(
          ps.map do |k, p| 
            [k, p[x]]
          end
        )
      end
    end

  end
end