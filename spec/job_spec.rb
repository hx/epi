require 'pathname'

describe Epi::Job do

  let(:configuration_file) { Epi::ConfigurationFile.new SPEC_ROOT + 'fixtures/jobs.epi' }
  let(:job_description) { configuration_file.tap(&:read).job_descriptions[:test] }
  let(:out_path) { Pathname job_description.stdout }
  let(:err_path) { Pathname job_description.stderr }

  after :each do
    out_path.delete if out_path.exist?
    err_path.delete if err_path.exist?
  end

  subject { Epi::Job.new job_description, 0 }

  specify 'fixtures should be set up' do
    expect(job_description).to be_a Epi::JobDescription
    expect(job_description.name).to eq 'Test Job'
    expect(Pathname job_description.stdout).not_to exist
    expect(Pathname job_description.stderr).not_to exist
  end

  describe 'an idle job' do

    it 'should have no running processes' do
      expect(subject.running_count).to be 0
      expect(subject.expected_count).to be 0
    end

  end

  describe 'one process running' do

    before :each do
      subject.expected_count = 1
      subject.sync!
    end

    after { subject.terminate! }

    it 'should have one running process' do
      expect(subject.running_count).to be 1
    end

    it 'should have started writing to the expected files' do
      expect(out_path).to exist
      expect(err_path).to exist
    end

    it 'should eventually send some output to the expected files' do
      20.times do
        break if out_path.size > 0 && err_path.size > 0
        sleep 0.1
      end
      expect(out_path.read).to match /^\.+$/
      expect(err_path.read).to match /^!+$/
    end

    it 'should report the PID of the process' do
      expect(subject.pids.first).to be_a Fixnum
      expect(`ps -p #{subject.pids.first} -o command=`).to include 'test.rb'
    end

  end

end