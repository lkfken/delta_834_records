module DeltaEDIFile
  class InterchangeControl
    attr_reader :functional_groups, :production

    def initialize(functional_groups:, production: false)
      @functional_groups = functional_groups
      @production        = production
    end

    def to_s
      [isa.to_s, functional_groups.map(&:to_s), iea.to_s].flatten.join
    end

    def isa
      @isa ||= begin
        isa                                   = Hippo::Segments::ISA.new
        isa.AuthorizationInformationQualifier = '00'
        isa.AuthorizationInformation          = nil
        isa.SecurityInformationQualifier      = '00'
        isa.SecurityInformation               = nil
        isa.InterchangeIdQualifier_01         = 'ZZ'
        isa.InterchangeSenderId               = 'DDCA'
        isa.InterchangeIdQualifier_02         = 'ZZ'
        isa.InterchangeReceiverId             = DeltaEDIFile.delta_tax_id
        isa.InterchangeDate                   = Date.today
        isa.InterchangeTime                   = Time.now
        isa.RepetitionSeparator               = '^'
        isa.InterchangeControlVersionNumber   = '00501'
        isa.InterchangeControlNumber          = '%09d' % rand(100000000..999999999).to_s
        isa.AcknowledgmentRequested           = '0'
        isa.InterchangeUsageIndicator         = (production ? 'P' : 'T')
        isa.ComponentElementSeparator         = ':'
        isa
      end
    end

    def iea
      @iea ||= begin
        iea                                  = Hippo::Segments::IEA.new
        iea.NumberOfIncludedFunctionalGroups = functional_groups.size
        iea.InterchangeControlNumber         = isa.InterchangeControlNumber
        iea
      end
    end
  end
end