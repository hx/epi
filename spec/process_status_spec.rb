describe Epi::ProcessStatus do

  subject { Epi::ProcessStatus.now }
  let(:current_process) { subject[$$] }

  it 'should include the currently running process' do
    expect(current_process).to be_a Epi::RunningProcess
    expect(current_process.pid).to be $$
  end

end
