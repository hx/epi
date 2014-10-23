module Epi
  module Triggers
    class Touch < Trigger::JobTrigger

      def initialize(*args)
        super *args
        update
      end

      def test
        ino = @ino; mtime = @mtime
        update
        ino != @ino || mtime != @mtime
      end

      private

      def path
        @path ||= Pathname args.first
      end

      def update
        @ino, @mtime = begin
          stat = path.stat
          [stat.ino, stat.mtime]
        rescue Errno::ENOENT
          [nil, nil]
        end
      end

    end
  end
end
