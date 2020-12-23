module DeltaEDIFile
  class FunctionalGroup
    attr_reader :transaction_sets
    def initialize(transaction_sets:)
      @transaction_sets = transaction_sets
    end

    def to_s
      [gs.to_s, transaction_sets.map(&:to_s), ge.to_s].flatten.join
    end

    def gs
      @gs ||= begin
        gs                                      = Hippo::Segments::GS.new
        gs.FunctionalIdentifierCode             = 'BE'
        gs.ApplicationSendersCode               = 'DDCA'
        gs.ApplicationReceiversCode             = DeltaEDIFile.delta_tax_id
        gs.Date                                 = Date.today
        gs.Time                                 = Time.now
        gs.GroupControlNumber                   = '%09d' % rand(100000000..999999999).to_s
        gs.ResponsibleAgencyCode                = 'X'
        gs.VersionReleaseIndustryIdentifierCode = '005010X220A1'
        gs
      end
    end

    def ge
      @ge ||= begin
        ge                                 = Hippo::Segments::GE.new
        ge.NumberOfTransactionSetsIncluded = transaction_sets.size
        ge.GroupControlNumber              = gs.GroupControlNumber
        ge
      end
    end
  end
end