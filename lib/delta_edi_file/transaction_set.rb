require 'hippo'
require_relative '../delta_plan_id2020'

module DeltaEDIFile
  class TransactionSet
    attr_reader :dataset, :transaction_set_control_number, :members, :hsp_data

    def initialize(dataset: nil, transaction_set_control_number:, members:, hsp_data: Hash.new)
      @dataset = dataset
      @members = members || dataset.all
      @transaction_set_control_number = transaction_set_control_number
      @hsp_data = hsp_data
    end

    def to_s
      value.to_s
    end

    private

    def check_hsp
      member_ids = members.map(&:member_id)
      msg = []
      member_ids.each do |member_id|
        hsp_data.fetch(member_id) { |id| msg << id }
      end
      raise msg.join(" ") + ' has no member number' unless msg.empty?
    end

    def value
      #check_hsp
      ts = ::Hippo::TransactionSets::HIPAA_834::Base.new
      ts.ST do |st|
        st.TransactionSetIdentifierCode = '834'
        st.TransactionSetControlNumber = transaction_set_control_number
        st.ImplementationConventionReference = '005010X220A1'
      end

      ts.BGN do |bgn|
        bgn.TransactionSetPurposeCode = '00'
        bgn.ReferenceIdentification = '0001'
        bgn.Date = Date.today.strftime('%Y%m%d')
        bgn.Time = Time.now.strftime('%H%M')
        bgn.TimeCode = 'PT'
        bgn.ActionCode = '4' # full file
      end

      ts.DTP do |dtp|
        dtp.DateTimeQualifier = '007' # effective date
        dtp.DateTimePeriodFormatQualifier = 'D8' # CCYYMMDD
        dtp.DateTimePeriod = DeltaEDIFile.file_effective_date
      end

      ts.L1000A do |l1000a|
        l1000a.N1 do |n1|
          n1.EntityIdentifierCode = 'P5'
          n1.Name = 'CHINESE COMMUNITY HEALTH PLAN'
          n1.IdentificationCodeQualifier = 'FI'
          n1.IdentificationCode = DeltaEDIFile.cchp_tax_id
        end
      end

      ts.L1000B do |l1000b|
        l1000b.N1 do |n1|
          n1.EntityIdentifierCode = 'IN'
          n1.Name = 'DELTA DENTAL OF CALIFORNIA'
          n1.IdentificationCodeQualifier = 'FI'
          n1.IdentificationCode = DeltaEDIFile.delta_tax_id
        end
      end

      members.each do |member|
        #delta_plan_id_2020 = DeltaPlanId2020.new(cchp_plan_id: member.benefit_plan, delta_group_id: member.delta_group_id)

        ts.L2000.build do |l2000|
          l2000.INS do |ins|
            ins.YesNoConditionOrResponseCode = 'Y'
            ins.IndividualRelationshipCode = '18'
            ins.MaintenanceTypeCode = '030'
            ins.BenefitStatusCode = 'A'
          end

          # OLD MEMBER ID
          l2000.REF_01 do |ref|
            ref.ReferenceIdentificationQualifier_01 = '0F'
            ref.ReferenceIdentification_01 = member.delta_subscriber_id
          end

          l2000.REF_02 do |ref|
            ref.ReferenceIdentificationQualifier = '1L'
            ref.ReferenceIdentification = member.delta_group_id
          end

          ##############################################################################################################
          [:dxp].each do |scenario|
            #  Every time #build is called, segment count is +1. Thus must skip if no alternate ID is included.
            next if scenario == :alternate && (hsp_data.empty?)
            l2000.REF_03.build do |ref|
              case scenario
              when :dxp
                # Note: Without DXP implementation
                ref.ReferenceIdentificationQualifier = 'DX'
                ref.ReferenceIdentification = member.delta_cchp_group_id # CCHP group number
                ref.Description_01 = member.group_name
              when :alternate
                # Note: Intermittent use to move from old member ID to new member number  (NEW MEMBER NUMBER, one time use only)
                hsp_member_numbers = hsp_data.fetch(member.member_id) { |id| raise "#{id} has no HSP member number" }
                ids = hsp_member_numbers.select { |mem_no| mem_no =~ /\A\d{6}\z/ }
                if ids.size.zero? || ids.size > 1
                  raise "#{member.member_id} => #{ids.join(' ')}"
                end
                hsp_member_number = ids.first
                alternate_id = hsp_member_number
                ref.ReferenceIdentificationQualifier = '17'
                ref.ReferenceIdentification = alternate_id
              end
            end
          end
          ##############################################################################################################

          l2000.DTP do |dtp|
            dtp.DateTimeQualifier = '303'
            dtp.DateTimePeriodFormatQualifier = 'D8'
            group_renew_date = member.group_renew_date.is_a?(String) ? Date.parse(member.group_renew_date) : member.group_renew_date
            group_renew_date = Date.civil(Date.today.year + 1, group_renew_date.month, group_renew_date.day) if group_renew_date < Date.today
            dtp.DateTimePeriod = group_renew_date
          end
          ##############################################################################################################

          l2000.L2100A do |l2100a|
            l2100a.NM1 do |nm1|
              nm1.EntityIdentifierCode = 'IL'
              nm1.EntityTypeQualifier = 1
              nm1.NameLastOrOrganizationName = member.last_name
              nm1.NameFirst = member.first_name
            end
            l2100a.N3 do |n3|
              n3.N301 = member.residential_address_1 # same as n3.AddressLine1 = member.residential_address_1
              n3.N302 = member.residential_address_2 # same as n3.AddressLine2 = member.residential_address_2
              n3.N303 = member.residential_address_3 # same as n3.AddressLine3 = member.residential_address_3
            end
            l2100a.N4 do |n4|
              n4.N401 = member.residential_city
              n4.N402 = member.residential_state
              n4.N403 = member.residential_zipcode
            end
            l2100a.DMG do |dmg|
              dmg.DateTimePeriodFormatQualifier = 'D8'
              dmg.DateTimePeriod = member.dob.strftime('%Y%m%d')
              dmg.GenderCode = member.gender
            end
          end
          l2000.L2300.build do |l2300|
            l2300.HD do |hd|
              hd.MaintenanceTypeCode = '030'
              hd.InsuranceLineCode = 'DEN'
              hd.CoverageLevelCode = 'IND'
            end

            [:effective_date, :disenroll_date].each do |qualifier|
              next if qualifier == :disenroll_date && member.disenroll_date.to_date == Date.civil(9999, 12, 31) # do not send disenroll date if member is active
              date = member.send(qualifier)
              l2300.DTP.build do |dtp|
                dtp.DateTimeQualifier = qualifier == :effective_date ? '348' : '349'
                dtp.DateTimePeriodFormatQualifier = 'D8'
                dtp.DateTimePeriod = date
              end
            end

            l2300.REF_01 do |ref|
              ref.ReferenceIdentificationQualifier = 'CE'
              ref.ReferenceIdentification = member.delta_plan_id
            end

          end
        end
      end

      ts.SE do |se|
        se.TransactionSetControlNumber = transaction_set_control_number
        se.NumberOfIncludedSegments = ts.segment_count
      end

      ts
    end

    def alternate_id

    end
  end
end