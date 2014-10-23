module Epi
  module Triggers
    class Memory < Trigger::ProcessTrigger
      include Concerns::Comparison

      def test(process)
        compare process.physical_memory
      end

    end
  end
end
