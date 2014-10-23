module Epi
  module Triggers
    module Concerns
      module Comparison

        def compare(subject)
          tester.call subject, object
        end

        private

        def tester
          @tester ||= choose_tester
        end

        def op
          @op ||= args[0]
        end

        def object
          @object ||= args[1]
        end

        def choose_tester
          case op
            when :gt then -> a, b { a > b }
            when :lt then -> a, b { a < b }
            when :gte then -> a, b { a >= b }
            when :lte then -> a, b { a <= b }
            when :eq then -> a, b { a == b }
            when :not_eq then -> a, b { a != b}
            when :match then -> a, b { a =~ b }
            when :not_match then -> a, b { a !~ b }
            when :like then -> a, b { a === b }
            when :not_like then -> a, b { !(a === b) }
            else raise Exceptions::Fatal, "Unknown operation #{op}"
          end
        end

      end
    end
  end
end