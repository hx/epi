module Epi
  module Triggers
    class Uptime < Trigger::ProcessTrigger
      include Concerns::Comparison

      def test(process)
        compare process.uptime
      end

    end
  end
end
