require 'fileutils'

module Epi::Triggers
  describe Touch do

    let(:path) { SPEC_ROOT + 'fixtures/touch.me' }

    subject { Touch.new nil, nil, path }

    after { path.delete rescue nil }

    def touch(time = nil)
      FileUtils.touch path
      File.utime(time, time, path) if time
    end

    it 'should be triggered if the file is created' do
      expect(subject.test).to be false
      touch
      expect(subject.test).to be true
      expect(subject.test).to be false
    end

    it 'should be triggered if the file date changes' do
      touch Time.now - 30
      expect(subject.test).to be false
      touch
      expect(subject.test).to be true
      expect(subject.test).to be false
    end

    it 'should be triggered if the file is deleted' do
      touch
      expect(subject.test).to be false
      path.delete
      expect(subject.test).to be true
      expect(subject.test).to be false
    end

    it 'should be triggered if the file is replaced (inode change)' do
      touch
      expect(subject.test).to be false
      path.delete
      touch
      expect(subject.test).to be true
      expect(subject.test).to be false
    end

  end
end
