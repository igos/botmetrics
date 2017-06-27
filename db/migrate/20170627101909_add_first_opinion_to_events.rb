class AddFirstOpinionToEvents < ActiveRecord::Migration
  def up
    execute "ALTER TABLE events DROP CONSTRAINT IF EXISTS valid_event_type_on_events"
    execute "ALTER TABLE events DROP CONSTRAINT IF EXISTS validate_attributes_id"
    execute "ALTER TABLE events DROP CONSTRAINT IF EXISTS validate_attributes_sub_type"
    execute "ALTER TABLE events DROP CONSTRAINT IF EXISTS validate_attributes_mid"
    execute "ALTER TABLE events DROP CONSTRAINT IF EXISTS validate_attributes_seq"
    execute "ALTER TABLE events DROP CONSTRAINT IF EXISTS validate_attributes_channel"
    execute "ALTER TABLE events DROP CONSTRAINT IF EXISTS validate_attributes_timestamp"
    execute "ALTER TABLE events DROP CONSTRAINT IF EXISTS validate_attributes_reaction"
    execute "ALTER TABLE events ADD CONSTRAINT validate_attributes_channel
                   CHECK (
                           (
                             (event_attributes->>'channel') IS NOT NULL
                             AND length(event_attributes->>'channel') > 0
                             AND provider = 'slack'
                             AND (event_type = 'message' OR event_type = 'message_reaction')
                           )
                           OR (
                             provider = 'slack'
                             AND (event_type <> 'message' AND event_type <> 'message_reaction')
                             AND event_attributes IS NOT NULL
                           )
                           OR
                             provider IN ('facebook', 'kik', 'first_opinion')
                         )"
    execute "ALTER TABLE events ADD CONSTRAINT validate_attributes_timestamp
                   CHECK (
                           (
                             (event_attributes->>'timestamp') IS NOT NULL
                             AND length(event_attributes->>'timestamp') > 0
                             AND provider = 'slack'
                             AND (event_type = 'message' OR event_type = 'message_reaction')
                           )
                           OR (
                             provider = 'slack'
                             AND (event_type <> 'message' AND event_type <> 'message_reaction')
                             AND event_attributes IS NOT NULL
                           )
                           OR
                             provider IN ('facebook', 'kik', 'first_opinion')
                         )"
    execute "ALTER TABLE events ADD CONSTRAINT validate_attributes_reaction
                   CHECK (
                           (
                             (event_attributes->>'reaction') IS NOT NULL
                             AND length(event_attributes->>'reaction') > 0
                             AND provider = 'slack'
                             AND event_type = 'message_reaction'
                           )
                           OR (
                             provider = 'slack'
                             AND event_type <> 'message_reaction'
                             AND event_attributes IS NOT NULL
                           )
                           OR
                             provider IN ('facebook', 'kik', 'first_opinion')
                         )"

    execute "ALTER TABLE events ADD CONSTRAINT validate_attributes_mid
                   CHECK (
                          (
                            (event_attributes->>'mid') IS NOT NULL
                            AND length(event_attributes->>'mid') > 0
                            AND provider = 'facebook'
                            AND event_type = 'message'
                          )
                          OR
                          (
                            provider = 'facebook'
                            AND event_type <> 'message'
                            AND event_attributes IS NOT NULL
                          )
                          OR
                            provider IN ('slack', 'kik', 'first_opinion')
                         )"

    execute "ALTER TABLE events ADD CONSTRAINT validate_attributes_seq
                   CHECK (
                          (
                            (event_attributes->>'seq') IS NOT NULL
                            AND length(event_attributes->>'seq') > 0
                            AND provider = 'facebook'
                            AND event_type = 'message'
                          )
                          OR
                          (
                            provider = 'facebook'
                            AND event_type <> 'message'
                            AND event_attributes IS NOT NULL
                          )
                          OR
                            provider IN ('slack', 'kik', 'first_opinion')
                         )"

    execute "ALTER TABLE events ADD CONSTRAINT validate_attributes_sub_type
                   CHECK (
                           (
                             (event_attributes->>'sub_type') IS NOT NULL
                             AND length(event_attributes->>'sub_type') > 0
                             AND (event_attributes->>'sub_type') IN ('text', 'link', 'picture', 'video', 'start-chatting', 'scan-data', 'sticker', 'is-typing', 'friend-picker')
                             AND provider = 'kik'
                             AND event_type = 'message'
                           )
                           OR
                             provider IN ('facebook', 'slack', 'first_opinion')
                         )"

    execute "ALTER TABLE events ADD CONSTRAINT validate_attributes_id
                   CHECK (
                           (
                             (event_attributes->>'id') IS NOT NULL
                             AND length(event_attributes->>'id') > 0
                             AND provider IN ('kik', 'first_opinion')
                           )
                           OR
                             provider IN ('facebook', 'slack', 'kik')
                         )"

    execute "ALTER TABLE events ADD CONSTRAINT valid_event_type_on_events
                   CHECK (
                          (
                            event_type IN ('user-added', 'followed-link', 'bot-installed', 'bot_disabled', 'added_to_channel', 'message', 'message_reaction')
                          ) AND provider = 'slack'
                          OR (
                            (
                              event_type IN ('user-added', 'followed-link', 'message', 'messaging_postbacks', 'messaging_optins', 'account_linking', 'messaging_referrals', 'message:image-uploaded', 'message:audio-uploaded', 'message:video-uploaded', 'message:file-uploaded', 'message:location-sent')
                            ) AND provider = 'facebook'
                          ) AND bot_user_id IS NOT NULL
                          OR (
                            (
                              event_type IN ('user-added', 'followed-link', 'message', 'message:image-uploaded', 'message:video-uploaded', 'message:link-uploaded', 'message:scanned-data', 'message:sticker-uploaded', 'message:friend-picker-chosen', 'message:is-typing', 'message:start-chatting')
                            ) AND provider = 'kik'
                          ) AND bot_user_id IS NOT NULL
                          OR (
                            (
                              event_type IN ('user-added', 'message')
                            ) AND provider = 'first_opinion'
                          ) AND bot_user_id IS NOT NULL
                        )"
  end

  def down
    execute "ALTER TABLE events DROP CONSTRAINT IF EXISTS valid_event_type_on_events"
    execute "ALTER TABLE events DROP CONSTRAINT IF EXISTS validate_attributes_id"
    execute "ALTER TABLE events DROP CONSTRAINT IF EXISTS validate_attributes_sub_type"
    execute "ALTER TABLE events DROP CONSTRAINT IF EXISTS validate_attributes_mid"
    execute "ALTER TABLE events DROP CONSTRAINT IF EXISTS validate_attributes_seq"
    execute "ALTER TABLE events DROP CONSTRAINT IF EXISTS validate_attributes_channel"
    execute "ALTER TABLE events DROP CONSTRAINT IF EXISTS validate_attributes_timestamp"
    execute "ALTER TABLE events DROP CONSTRAINT IF EXISTS validate_attributes_reaction"
    execute "ALTER TABLE events ADD CONSTRAINT validate_attributes_channel
                   CHECK (
                           (
                             (event_attributes->>'channel') IS NOT NULL
                             AND length(event_attributes->>'channel') > 0
                             AND provider = 'slack'
                             AND (event_type = 'message' OR event_type = 'message_reaction')
                           )
                           OR (
                             provider = 'slack'
                             AND (event_type <> 'message' AND event_type <> 'message_reaction')
                             AND event_attributes IS NOT NULL
                           )
                           OR
                             provider IN ('facebook', 'kik')
                         )"
    execute "ALTER TABLE events ADD CONSTRAINT validate_attributes_timestamp
                   CHECK (
                           (
                             (event_attributes->>'timestamp') IS NOT NULL
                             AND length(event_attributes->>'timestamp') > 0
                             AND provider = 'slack'
                             AND (event_type = 'message' OR event_type = 'message_reaction')
                           )
                           OR (
                             provider = 'slack'
                             AND (event_type <> 'message' AND event_type <> 'message_reaction')
                             AND event_attributes IS NOT NULL
                           )
                           OR
                             provider IN ('facebook', 'kik')
                         )"
    execute "ALTER TABLE events ADD CONSTRAINT validate_attributes_reaction
                   CHECK (
                           (
                             (event_attributes->>'reaction') IS NOT NULL
                             AND length(event_attributes->>'reaction') > 0
                             AND provider = 'slack'
                             AND event_type = 'message_reaction'
                           )
                           OR (
                             provider = 'slack'
                             AND event_type <> 'message_reaction'
                             AND event_attributes IS NOT NULL
                           )
                           OR
                             provider IN ('facebook', 'kik')
                         )"

    execute "ALTER TABLE events ADD CONSTRAINT validate_attributes_mid
                   CHECK (
                          (
                            (event_attributes->>'mid') IS NOT NULL
                            AND length(event_attributes->>'mid') > 0
                            AND provider = 'facebook'
                            AND event_type = 'message'
                          )
                          OR
                          (
                            provider = 'facebook'
                            AND event_type <> 'message'
                            AND event_attributes IS NOT NULL
                          )
                          OR
                            provider IN ('slack', 'kik')
                         )"

    execute "ALTER TABLE events ADD CONSTRAINT validate_attributes_seq
                   CHECK (
                          (
                            (event_attributes->>'seq') IS NOT NULL
                            AND length(event_attributes->>'seq') > 0
                            AND provider = 'facebook'
                            AND event_type = 'message'
                          )
                          OR
                          (
                            provider = 'facebook'
                            AND event_type <> 'message'
                            AND event_attributes IS NOT NULL
                          )
                          OR
                            provider IN ('slack', 'kik')
                         )"

    execute "ALTER TABLE events ADD CONSTRAINT validate_attributes_sub_type
                   CHECK (
                           (
                             (event_attributes->>'sub_type') IS NOT NULL
                             AND length(event_attributes->>'sub_type') > 0
                             AND (event_attributes->>'sub_type') IN ('text', 'link', 'picture', 'video', 'start-chatting', 'scan-data', 'sticker', 'is-typing', 'friend-picker')
                             AND provider = 'kik'
                             AND event_type = 'message'
                           )
                           OR
                             provider IN ('facebook', 'slack')
                         )"

    execute "ALTER TABLE events ADD CONSTRAINT validate_attributes_id
                   CHECK (
                           (
                             (event_attributes->>'id') IS NOT NULL
                             AND length(event_attributes->>'id') > 0
                             AND provider = 'kik'
                           )
                           OR
                             provider IN ('facebook', 'slack', 'kik')
                         )"

    execute "ALTER TABLE events ADD CONSTRAINT valid_event_type_on_events
                   CHECK (
                          (
                            event_type IN ('user-added', 'followed-link', 'bot-installed', 'bot_disabled', 'added_to_channel', 'message', 'message_reaction')
                          ) AND provider = 'slack'
                          OR (
                            (
                              event_type IN ('user-added', 'followed-link', 'message', 'messaging_postbacks', 'messaging_optins', 'account_linking', 'messaging_referrals', 'message:image-uploaded', 'message:audio-uploaded', 'message:video-uploaded', 'message:file-uploaded', 'message:location-sent')
                            ) AND provider = 'facebook'
                          ) AND bot_user_id IS NOT NULL
                          OR (
                            (
                              event_type IN ('user-added', 'followed-link', 'message', 'message:image-uploaded', 'message:video-uploaded', 'message:link-uploaded', 'message:scanned-data', 'message:sticker-uploaded', 'message:friend-picker-chosen', 'message:is-typing', 'message:start-chatting')
                            ) AND provider = 'kik'
                          ) AND bot_user_id IS NOT NULL
                        )"

  end
end
