class BotInstance < ActiveRecord::Base
  belongs_to :bot
  has_many :users, class_name: 'BotUser'
  has_many :events
  has_many :messages
  has_many :short_links

  validates_presence_of :bot_id, :provider
  validates_presence_of :token, if: proc { provider != 'first_opinion' }
  validates_uniqueness_of :token, if: proc { provider != 'first_opinion' }
  validates_inclusion_of  :provider, in: %w(slack kik facebook telegram first_opinion)
  validates_inclusion_of  :state, in: %w(pending enabled disabled)

  validates_presence_of :uid, if: Proc.new { |bi| bi.state == 'enabled' }

  validates_with BotInstanceAttributesValidator

  scope :legit,     -> { where("bot_instances.state <> ?", 'pending') }
  scope :enabled,   -> { where("bot_instances.state = ?", 'enabled') }
  scope :disabled,  -> { where("bot_instances.state = ?", 'disabled') }

  delegate :owners, to: :bot
  delegate :collaborators, to: :bot

  store_accessor :instance_attributes, :team_id, :team_name, :team_url, :name

  def self.find_by_bot_and_team!(bot, team_id)
    bot_instance = BotInstance.where(bot_id: bot.id).where("instance_attributes->>'team_id' = ?", team_id).first
    bot_instance.presence || (raise ActiveRecord::RecordNotFound)
  end

  def self.with_events(events_relation)
    select("bot_instances.*, COALESCE(users.cnt, 0) AS users_count, e.c_at AS last_event_at").
    joins("LEFT JOIN (SELECT bot_instance_id, COUNT(*) AS cnt FROM bot_users GROUP BY bot_instance_id) users on users.bot_instance_id = bot_instances.id").
    joins("INNER JOIN (SELECT bot_instance_id, MAX(rolledup_events.created_at) AS c_at FROM rolledup_events WHERE rolledup_events.id IN (#{events_relation.to_sql}) GROUP by bot_instance_id) e ON e.bot_instance_id = bot_instances.id").
    order("last_event_at DESC")
  end

  def self.membership_type_from_hash(user_hash)
    membership_type = nil

    if user_hash['deleted']
      membership_type = 'deleted'
    elsif user_hash['is_owner']
      membership_type = 'owner'
    elsif user_hash['is_admin']
      membership_type = 'admin'
    elsif user_hash['is_restricted']
      membership_type = 'guest'
    else
      membership_type = 'member'
    end

    membership_type
  end

  def import_users!
    slack_client = Slack.new(self.token)

    BotInstance.with_advisory_lock("team-import-#{self.uid}") do
      object_nesting_level = 0
      current_user = {}
      current_profile = {}

      current_user_key = nil
      current_profile_key = nil
      _bi = self

      parser = JSON::Stream::Parser.new do
        start_object { object_nesting_level += 1 }
        end_object do
          if object_nesting_level.eql? 2
            _bi.import_user_from_hash!(current_user)
            current_user = {}
          elsif object_nesting_level.eql? 3
            current_user[current_user_key] = current_profile
            current_profile = {}
          end

          object_nesting_level -= 1
        end

        key do |k|
          if object_nesting_level.eql? 2
            current_user_key = k
          elsif object_nesting_level.eql? 3
            current_profile_key = k
          end
        end

        value do |v|
          if object_nesting_level.eql? 2
            current_user[current_user_key] = v
          elsif object_nesting_level.eql? 3
            current_profile[current_profile_key] = v
          end
        end
      end

      slack_client.call('users.list', :get) do |chunk, remaining_bytes, total_bytes|
        parser << chunk
      end
    end

    Rails.logger.warn "[ImportUsersForBotInstanceJob] importing members: #{self.users.count} ID: #{self.id}"
  end

  def import_user_from_hash!(user)
    u = self.users.find_by(uid: user['id']) || self.users.new(uid: user['id'], provider: 'slack')

    u.user_attributes['nickname'] = user['name']
    u.user_attributes['email'] = user['profile']['email']

    u.user_attributes['first_name'] = user['profile']['first_name']
    u.user_attributes['last_name'] = user['profile']['last_name']
    u.user_attributes['full_name'] = user['profile']['real_name']

    u.user_attributes['timezone'] = user['tz']
    u.user_attributes['timezone_description'] = user['tz_label']
    u.user_attributes['timezone_offset'] = user['tz_offset'].to_i
    u.membership_type = BotInstance.membership_type_from_hash(user)
    u.save!
  end

  def bot_team_name
    case provider
    when 'facebook'
      name
    when 'slack'
      team_name
    end
  end
end
