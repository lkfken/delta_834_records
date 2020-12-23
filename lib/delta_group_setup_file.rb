require_relative 'delta_group_setup_file/record'

module DeltaGroupSetupFile
  GROUP_SETUP_FILENAME  = "grp_cchp_to_delta_#{Time.now.strftime('%Y%m%d%H%M%S')}.txt"

  #####################################################################
  # per Rajkumar Narayanaswamy (Delta.org), carved out 78624CC0000001 #
  # CA78624 is Off-Exchange IFP adult dental rider                    #
  # CA77130 is IFP pediatric dental rider                             #
  #####################################################################
  EXCLUDE_DELTA_GROUPS = %w[CA78624 CA77130]
end