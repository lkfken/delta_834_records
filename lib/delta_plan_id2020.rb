class DeltaPlanId2020
  attr_reader :cchp_plan_id, :delta_group_id

  def initialize(cchp_plan_id:, delta_group_id:)
    @cchp_plan_id = cchp_plan_id
    @delta_group_id = delta_group_id
  end

  def group_number
    'CA79203'
  end

  def value
    @value ||= begin
      v = if esp?
            case cchp_plan_id
            when 'CCHPA003'
              '78541CC0000240'
            when 'OPAL252018', 'OPAL252019'
              '78541CC0000226'
            when 'OPAL502019'
              '78541CC0000238'
            when 'OSIL70GR18', 'OSIL70GR19'
              '78541CC0000145'
            when 'OXBRHDGR19'
              '78541CC0000248'
            when 'OXBRONGR18', 'OXBRONGR19'
              '78541CC0000290'
            when 'OXGOLDGR18', 'OXGOLDGR19'
              '78541CC0000246'
            when 'OXPLATGR19'
              '78541CC0000239'
            when 'RIDER'
              '78625CC0000001'
            when 'RUBY102018', 'RUBY102019'
              '78541CC0000250'
            when 'RUBY202018', 'RUBY202019'
              '78541CC0000270'
            when 'RUBY402018', 'RUBY402019'
              '78541CC0000242'
            when 'BR60HDGR19'
              '78541CC0000247'
            when 'BRON60GR19'
              '78541CC0000280'
            when 'GOLD80GR18', 'GOLD80GR19'
              '78541CC0000244'
            when 'PLAT90GR19'
              '78541CC0000237'
            when 'SILV70GR18', 'SILV70GR19'
              '78541CC0000141'
            else
              raise "#{cchp_plan_id} is not defined under ESP"
            end
          elsif ifp?
            case cchp_plan_id
            when 'ACTPPOIF19', 'AMBER2019'
              '77130CC0000121'
            when 'JADE2019'
              '77130CC0000151'
            when 'BR60HDIF'
              '77130CC0000245'
            when 'OXBRHDIF19'
              '77130CC0000246'
            when 'OXBRONIF19', 'OXGOLDIF19', 'SILVER70IF'
              '77130CC0000241'
            when 'OXMINI2019'
              '77130CC0000239'
            when 'OXPLATIF19'
              '77130CC0000250'
            when 'RIDER'
              '78624CC0000001'
            when 'SIL70ALT19'
              '77130CC0000253'
            when 'SILVER94'
              '77130CC0000042'
            when 'BRONZE60', 'GOLD80'
              '77130CC0000240'
            when 'MINICOVER'
              '77130CC0000238'
            when 'PLATINUM90'
              '77130CC0000249'
            else
              raise "#{cchp_plan_id} is not defined under IFP"
            end
          else
            raise "#{delta_group_id} is not defined!"
          end
      v
    end
  end

  def esp?
    ['CA78541', 'CA78625'].include?(delta_group_id)
  end

  def ifp?
    ['CA77130', 'CA78624'].include?(delta_group_id)
  end

end