class SubmissionFile
  attr_reader :dataset, :filename, :production

  def initialize(dataset:, filename:, production: false)
    @dataset = dataset
    @filename = filename
  end

  def create!
    transaction_set_control_number = '%09d' % rand(100000000..999999999).to_s
    ts = DeltaEDIFile::TransactionSet.new(members: dataset, transaction_set_control_number: transaction_set_control_number)
    functional_group = DeltaEDIFile::FunctionalGroup.new(transaction_sets: [ts])
    interchange_control = DeltaEDIFile::InterchangeControl.new(functional_groups: [functional_group], production: production)
    File.open(filename, 'w') { |f| f.puts interchange_control }
  end
end