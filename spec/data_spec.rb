describe Spagmon::Data do

  describe 'instances' do

    subject { Spagmon::Data.new(SPEC_ROOT + '.spagmon') }

    it 'should act like a hash' do
      subject[:foo] = 123
      expect(subject[:foo]).to be 123
    end

    it 'should persist its data to disk' do
      subject[:a] = [1, 2]
      subject.save
      subject[:a] = 35
      subject.reload
      expect(subject[:a]).to eq [1, 2]
    end

  end

  describe 'default instance' do

    subject { Spagmon::Data.default_instance }

    it 'should use "/etc/spagmon" or "~/.spagmon" as its home dir' do
      expect(subject.home.to_s).to eq('/etc/spagmon').or eq(File.expand_path '~/.spagmon')
    end

    it 'should have made its home directory' do
      expect(subject.home).to exist
    end

    it 'should only be root if it is using "/etc/spagmon" for storage' do
      expect(subject.root?).to be (subject.home.to_s == '/etc/spagmon')
    end

  end

  describe 'class methods' do

    subject { Spagmon::Data }
    let(:default_instance) { subject.default_instance }

    it 'should behave as a hash on behalf of the default instance' do
      subject[:foo] = :bar
      expect(subject[:foo]).to be :bar
      expect(default_instance[:foo]).to be :bar
    end

    it 'should read and write files at a low level' do
      subject.write 'this.file', 12345
      expect(default_instance.home.join('this.file').read).to eq '12345'
      expect(subject.read 'this.file').to eq '12345'
    end

    it 'should delete files when nil is written to them' do
      subject.write 'delete.me', 'hello'
      expect(default_instance.home + 'delete.me').to exist
      subject.write 'delete.me', nil
      expect(default_instance.home + 'delete.me').not_to exist
    end

    it 'should read nonexistent files as nil' do
      expect(subject.read 'nothing').to be_nil
    end

  end

end
