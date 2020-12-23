require_relative 'delta_edi_file/transaction_set'
require_relative 'delta_edi_file/functional_group'
require_relative 'delta_edi_file/interchange_control'

module DeltaEDIFile
  def employer_sponsored_delta_groups
    %w[CA78541 CA78625]
  end

  def ifp_delta_groups
    %w[CA77130 CA78624]
  end

  def file_effective_date
    Date.civil(2015, 1, 1)
  end

  def cchp_tax_id
    '943021419'
  end

  def delta_tax_id
    '942411167'
  end

  module_function :employer_sponsored_delta_groups, :ifp_delta_groups,:file_effective_date,:cchp_tax_id,:delta_tax_id
end