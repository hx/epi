describe Epi::RunningProcess do

  subject { Epi::RunningProcess.new($$) }

  it 'should tell us who is running it' do
    expect(subject.user).to eq `whoami`.chomp
  end

  it 'should tell us the group running it' do
    expect(subject.group).to eq `id -gn`.chomp
  end

  it 'should tell us current CPU and memory percentages' do
    expect(subject.cpu_percentage).to be_a Float
    expect(subject.memory_percentage).to be_a Float
  end

  it 'should tell us the physical and virtual memory usage amounts' do
    expect(subject.physical_memory).to be_a Fixnum
    expect(subject.virtual_memory).to be_a Fixnum
  end

  it 'should tell us total memory usage (physical plus virtual)' do
    expect(subject.total_memory).to eq subject.physical_memory + subject.virtual_memory
  end

  it 'should tell us when the process started' do
    time = subject.started_at
    expect(time).to be_a Time
    expect(time).to be < Time.now
    expect(time).to be > Time.now - 300
  end

  it 'should tell us the command, including arguments' do
    expect(subject.command).to match /\brspec\b/
  end

  it 'should tell us if the process is running as root' do
    expect(subject.root?).to be `whoami`.chomp == 'root'
  end

end