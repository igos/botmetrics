class AddFirstOpinionToBotInstances < ActiveRecord::Migration
  def up
    execute "ALTER TABLE bot_instances DROP CONSTRAINT IF EXISTS valid_provider_on_bot_instances"
    execute "ALTER TABLE bot_instances ADD CONSTRAINT valid_provider_on_bot_instances CHECK (provider = 'slack' OR provider = 'kik' OR provider = 'facebook' OR provider = 'telegram' OR provider = 'first_opinion')"
  end

  def down
    execute "ALTER TABLE bot_instances DROP CONSTRAINT IF EXISTS valid_provider_on_bot_instances"
    execute "ALTER TABLE bot_instances ADD CONSTRAINT valid_provider_on_bot_instances CHECK (provider = 'slack' OR provider = 'kik' OR provider = 'facebook' OR provider = 'telegram')"
  end
end
