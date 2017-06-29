module Queries
  class FirstOpinion < Base
    FIELDS  = {
      'membership_type'        => 'Type',
      'name'        => 'Name',
      'age'        => 'Age',
      'state'        => 'State',
      'gender'        => 'Gender',
      'ip_city'        => 'IP city',
      'ip_state'        => 'IP state',
      'ip_country'        => 'IP country',
      'interaction_count' => 'Number of Interactions with Bot',
      'interacted_at'     => 'Last Interacted With Bot',
      'user_created_at'   => 'Signed Up',
    }

    def is_string_query?(field)
      field.in?(['membership_type', 'name', 'state', 'gender', 'ip_city', 'ip_state', 'ip_country'])
    end

    def is_number_query?(field)
      field.in?(['age'])
    end
  end
end
