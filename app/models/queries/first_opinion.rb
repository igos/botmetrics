module Queries
  class FirstOpinion < Base
    FIELDS  = {
      'name'        => 'Name',
      'interaction_count' => 'Number of Interactions with Bot',
      'interacted_at'     => 'Last Interacted With Bot',
      'user_created_at'   => 'Signed Up',
    }

    def is_string_query?(field)
      field.in?(['name'])
    end
  end
end
