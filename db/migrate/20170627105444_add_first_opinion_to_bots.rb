class AddFirstOpinionToBots < ActiveRecord::Migration
  def up
    execute "ALTER TABLE bots DROP CONSTRAINT IF EXISTS valid_provider_on_bots"
    execute "ALTER TABLE bots ADD CONSTRAINT valid_provider_on_bots CHECK (provider = 'slack' OR provider = 'kik' OR provider = 'facebook' OR provider = 'telegram' OR provider = 'first_opinion')"
  end

  def down
    execute "ALTER TABLE bots DROP CONSTRAINT IF EXISTS valid_provider_on_bots"
    execute "ALTER TABLE bots ADD CONSTRAINT valid_provider_on_bots CHECK (provider = 'slack' OR provider = 'kik' OR provider = 'facebook' OR provider = 'telegram')"
  end
end
