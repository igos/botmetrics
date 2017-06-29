class NullTokenForFirstOpinionInBotInstances < ActiveRecord::Migration
  def up
    execute "ALTER TABLE bot_instances ALTER token DROP NOT NULL"
    execute "ALTER TABLE bot_instances ADD CONSTRAINT not_null_token_on_bot_instances CHECK ((provider IN ('slack', 'kik', 'facebook', 'telegram') AND token IS NOT NULL) OR provider = 'first_opinion')"
  end

  def down
    execute "ALTER TABLE bot_instances DROP CONSTRAINT IF EXISTS not_null_token_on_bot_instances"
    execute "ALTER TABLE bot_instances ALTER token SET NOT NULL"
  end
end
