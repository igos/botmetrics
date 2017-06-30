class AddFirstOpinionToQueries < ActiveRecord::Migration
  def up
    execute "ALTER TABLE queries DROP CONSTRAINT validate_field"
    execute "ALTER TABLE queries DROP CONSTRAINT validate_method"

    execute(
      "ALTER TABLE queries ADD CONSTRAINT validate_field
      CHECK ((
        provider = 'slack'
        AND (
          field = 'nickname'
          OR field = 'email'
          OR field = 'full_name'
          OR field = 'interaction_count'
          OR field = 'interacted_at'
          OR field = 'user_created_at'
          OR field = 'followed_link'
          OR field LIKE 'dashboard:%'
        )
      ) OR
      (
        provider = 'facebook'
        AND (
          field = 'first_name'
          OR field = 'last_name'
          OR field = 'gender'
          OR field = 'interaction_count'
          OR field = 'interacted_at'
          OR field = 'user_created_at'
          OR field = 'followed_link'
          OR field LIKE 'dashboard:%'
        )
      ) OR
      (
        provider = 'kik'
        AND (
          field = 'first_name'
          OR field = 'last_name'
          OR field = 'interaction_count'
          OR field = 'interacted_at'
          OR field = 'user_created_at'
          OR field = 'followed_link'
          OR field LIKE 'dashboard:%'
        )
      ) OR
      (
        provider = 'first_opinion'
        AND (
          field = 'name'
          OR field = 'age'
          OR field = 'parent'
          OR field = 'created'
          OR field = 'state'
          OR field = 'gender'
          OR field = 'ip_city'
          OR field = 'ip_state'
          OR field = 'ip_country'
          OR field = 'interaction_count'
          OR field = 'interaction_count'
          OR field = 'interacted_at'
          OR field = 'user_created_at'
          OR field LIKE 'dashboard:%'
        )
      )
    )"
    )
    execute(
      "ALTER TABLE queries ADD CONSTRAINT validate_method
      CHECK (
        (
          provider = 'slack'
          AND (
            field = 'nickname'
            OR field = 'email'
            OR field = 'full_name'
            OR field = 'followed_link'
          )
          AND (
            method = 'equals_to'
            OR method = 'contains'
          )
        )
        OR
        (
          (provider = 'facebook' OR provider = 'kik')
          AND (
            field = 'first_name'
            OR field = 'last_name'
            OR field = 'followed_link'
          )
          AND (
            method = 'equals_to'
            OR method = 'contains'
          )
        )
        OR
        (
          provider = 'facebook'
          AND (
            field = 'gender'
          )
          AND (
            method = 'equals_to'
            OR method = 'contains'
          )
        )
        OR
        (
          provider = 'first_opinion'
          AND (
            field = 'name'
            OR field = 'state'
            OR field = 'gender'
            OR field = 'ip_city'
            OR field = 'ip_state'
            OR field = 'ip_country'
            OR field = 'parent'
          )
          AND (
            method = 'equals_to'
            OR method = 'contains'
          )
        )
        OR
        (
          (
            provider = 'slack' OR
            provider = 'facebook' OR
            provider = 'kik' OR
            provider = 'first_opinion'
          )
          AND (
            field = 'interaction_count'
            OR field = 'age'
          )
          AND (
            method = 'equals_to'
            OR method = 'between'
            OR method = 'greater_than'
            OR method = 'lesser_than'
          )
        )
        OR
        (
          (
            provider = 'slack' OR
            provider = 'facebook' OR
            provider = 'kik' OR
            provider = 'first_opinion'
          )
          AND (
            field = 'interacted_at'
            OR field = 'user_created_at'
            OR field = 'created'
            OR field LIKE 'dashboard:%'
          )
          AND (
            method = 'between'
            OR method = 'greater_than'
            OR method = 'lesser_than'
          )
        )
      )"
    )
  end

  def down
    execute "ALTER TABLE queries DROP CONSTRAINT validate_field"
    execute "ALTER TABLE queries DROP CONSTRAINT validate_method"

    execute(
      "ALTER TABLE queries ADD CONSTRAINT validate_field
      CHECK ((
        provider = 'slack'
        AND (
          field = 'nickname'
          OR field = 'email'
          OR field = 'full_name'
          OR field = 'interaction_count'
          OR field = 'interacted_at'
          OR field = 'user_created_at'
          OR field = 'followed_link'
          OR field LIKE 'dashboard:%'
        )
      ) OR
      (
        provider = 'facebook'
        AND (
          field = 'first_name'
          OR field = 'last_name'
          OR field = 'gender'
          OR field = 'interaction_count'
          OR field = 'interacted_at'
          OR field = 'user_created_at'
          OR field = 'followed_link'
          OR field LIKE 'dashboard:%'
        )
      ) OR
      (
        provider = 'kik'
        AND (
          field = 'first_name'
          OR field = 'last_name'
          OR field = 'interaction_count'
          OR field = 'interacted_at'
          OR field = 'user_created_at'
          OR field = 'followed_link'
          OR field LIKE 'dashboard:%'
        )
      )
    )"
    )
    execute(
      "ALTER TABLE queries ADD CONSTRAINT validate_method
      CHECK (
        (
          provider = 'slack'
          AND (
            field = 'nickname'
            OR field = 'email'
            OR field = 'full_name'
            OR field = 'followed_link'
          )
          AND (
            method = 'equals_to'
            OR method = 'contains'
          )
        )
        OR
        (
          (provider = 'facebook' OR provider = 'kik')
          AND (
            field = 'first_name'
            OR field = 'last_name'
            OR field = 'followed_link'
          )
          AND (
            method = 'equals_to'
            OR method = 'contains'
          )
        )
        OR
        (
          provider = 'facebook'
          AND (
            field = 'gender'
          )
          AND (
            method = 'equals_to'
            OR method = 'contains'
          )
        )
        OR
        (
          (
            provider = 'slack' OR
            provider = 'facebook' OR
            provider = 'kik'
          )
          AND (
            field = 'interaction_count'
          )
          AND (
            method = 'equals_to'
            OR method = 'between'
            OR method = 'greater_than'
            OR method = 'lesser_than'
          )
        )
        OR
        (
          (
            provider = 'slack' OR
            provider = 'facebook' OR
            provider = 'kik'
          )
          AND (
            field = 'interacted_at'
            OR field = 'user_created_at'
            OR field LIKE 'dashboard:%'
          )
          AND (
            method = 'between'
            OR method = 'greater_than'
            OR method = 'lesser_than'
          )
        )
      )"
    )
  end
end
