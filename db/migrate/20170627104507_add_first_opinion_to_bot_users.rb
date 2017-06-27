class AddFirstOpinionToBotUsers < ActiveRecord::Migration
  def up
    execute "ALTER TABLE bot_users DROP CONSTRAINT IF EXISTS valid_provider_on_bot_users"
    execute "ALTER TABLE bot_users ADD CONSTRAINT valid_provider_on_bot_users CHECK (provider = 'slack' OR provider = 'kik' OR provider = 'facebook' OR provider = 'telegram' OR provider = 'first_opinion')"
  end

  def down
    execute "ALTER TABLE bot_users DROP CONSTRAINT IF EXISTS valid_provider_on_bot_users"
    execute "ALTER TABLE bot_users ADD CONSTRAINT valid_provider_on_bot_users CHECK (provider = 'slack' OR provider = 'kik' OR provider = 'facebook' OR provider = 'telegram')"
  end
end
