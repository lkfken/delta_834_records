module DeltaGroupSetupFile
  class Record
    attr_accessor :delta_cchp_group_id, :group_renew_date, :contract_year, :delta_plan_id, :group_name
    UNPACK_STRING = 'A35A17A5A1A50A20A9A50A20A10A40A55A55A30A2A9A10A30A5A30A2A40A55A55A30A2A9A10A30A50A20A10'
    #[["delta_cchp_group_id", "35"], ["delta_plan_id", "17"], ["division_number", "5"], ["region_id", "1"], ["group_contract_name", "50"], ["group_tin", "20"], ["group_sic_code", "9"], ["group_name", "50"], ["industry_type", "20"], ["effective_date", "10"], ["group_contact", "40"], ["addr1", "55"], ["addr2", "55"], ["city", "30"], ["state", "2"], ["zip", "9"], ["phone_number", "10"], ["email", "30"], ["eligible_employees", "5"], ["waiting_period", "30"], ["eligibility_hours", "2"], ["invoice_contact", "40"], ["bill_addr1", "55"], ["bill_addr2", "55"], ["bill_city", "30"], ["bill_state", "2"], ["bill_zip", "9"], ["bill_phone_number", "10"], ["bill_email", "30"], ["agent_name", "50"], ["tax_id", "20"], ["disenroll_date", "10"]]

    def initialize(delta_cchp_group_id:, group_renew_date:, contract_year:, delta_plan_id:, group_name:)
      @delta_cchp_group_id = delta_cchp_group_id
      @group_renew_date = group_renew_date
      @contract_year = contract_year
      @delta_plan_id = delta_plan_id
      @group_name = group_name
    end

    def to_s
      to_a.pack(UNPACK_STRING)
    end

    def active_group
      @active_group ||= DST::Group.active.where(Sequel.like(:group_id, delta_cchp_group_id + '%')).first
    end

    def disenrolled_group
      @disenrolled_group ||= DST::Group.where(:group_id => last_disenroll_record.c_grp).first
    end

    def group
      @group ||= active_group.nil? ? disenrolled_group : active_group
    end

    def disenroll_date
      # @disenroll_date ||= begin
      #   date = active_group.nil? ? last_disenroll_record.disenr_dt : nil
      #   date = if date
      #            if date.respond_to?(:month)
      #              date.strftime('%m/%d/%Y')
      #            else
      #              Date.strptime(date.to_s, '%Y-%m-%d').strftime('%m/%d/%Y')
      #            end
      #          end
      #   raise "#{delta_cchp_group_id} EFF #{effective_date} > TERM #{date}" if date && Date.strptime(effective_date, '%m/%d/%Y') > Date.strptime(date, '%m/%d/%Y')
      #   date
      # end
      nil
    end

    def last_disenroll_record
      DST::DisenrollRecord.where(Sequel.like(:c_grp, delta_cchp_group_id + '%')).reverse(:disenr_dt).first
    end

    def group_contract_name
      group_name || group.name
    end

    def group_renew_date
      if @group_renew_date.respond_to? :month
        @group_renew_date
      else
        Date.strptime(@group_renew_date.to_s, '%Y-%m-%d')
      end
    end

    def renew_month
      group_renew_date.month
    end

    def effective_date
      date = Date.civil(contract_year, renew_month, 1)
      date.strftime('%m/%d/%Y')
    end

    def group_contact
      'KENNETH LEUNG' # group.contact
    end

    def addr1
      '445 GRANT AVE' # group.address1
    end

    def addr2
      # group.address2
    end

    def city
      'SAN FRANCISCO' # group.city
    end

    def state
      'CA' #group.state
    end

    def zip
      '94108' #group.zip
    end

    def phone_number
     '4159558800' # group.phone.gsub(/[^\d]/, '')
    end

    def not_require
      nil
    end

    alias_method :division_number, :not_require
    alias_method :group_tin, :not_require
    alias_method :email, :not_require
    alias_method :region_id, :not_require
    alias_method :group_sic_code, :not_require
    # alias_method :group_name, :not_require
    alias_method :industry_type, :not_require
    alias_method :eligible_employees, :not_require
    alias_method :waiting_period, :not_require
    alias_method :eligibility_hours, :not_require
    alias_method :invoice_contact, :not_require
    alias_method :bill_addr1, :not_require
    alias_method :bill_addr2, :not_require
    alias_method :bill_city, :not_require
    alias_method :bill_state, :not_require
    alias_method :bill_zip, :not_require
    alias_method :bill_phone_number, :not_require
    alias_method :bill_email, :not_require
    alias_method :agent_name, :not_require
    alias_method :tax_id, :not_require


    def to_a
      [delta_cchp_group_id, delta_plan_id, division_number, region_id, group_contract_name, group_tin,
       group_sic_code, group_name, industry_type, effective_date, group_contact,
       addr1, addr2, city, state, zip, phone_number, email,
       eligible_employees, waiting_period, eligibility_hours, invoice_contact,
       bill_addr1, bill_addr2, bill_city, bill_state, bill_zip, bill_phone_number, bill_email, agent_name, tax_id,
       disenroll_date]
    end
  end
end