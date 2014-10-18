describe Spagmon::ProcessStatus do

  subject { Spagmon::ProcessStatus.now }
  let(:current_process) { subject[$$] }

  it 'should include the currently running process' do
    expect(current_process).to be_a Spagmon::RunningProcess
    expect(current_process.pid).to be $$
  end

end
