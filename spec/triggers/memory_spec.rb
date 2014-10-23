module Epi::Triggers
  describe Memory do

    subject { Memory.new nil, :gt, 5 }

    it 'should test positive when the comparison matches' do
      expect(subject.test double('Process', physical_memory: 6)).to be true
    end

    it 'should test negative when the comparison does not match' do
      expect(subject.test double('Process', physical_memory: 5)).to be false
    end

  end
end
