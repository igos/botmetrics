class FirstOpinionEventsService
  AVAILABLE_USER_FIELDS = %w(name gender age state ip_city ip_state ip_country)
  AVAILABLE_DOCTOR_FIELDS = %w(name)

  def initialize(bot_id:, events:)
    @bot_id = bot_id
    @events = events
  end

  # We are using find_by here, because in Kik's case
  # only one instance of BotInstance will ever exist
  def bot_instance
    @bot_instance ||= BotInstance.find_by(bot_id: bot.id)
  end

  def bot
    @bot ||= Bot.find_by(uid: bot_id)
  end

  def create_events!
    serialized_params.each do |p|
      @params = p
      @event_type = params.dig(:data, :type)
      create_message_events!
    end
  end

  private
  attr_accessor :events, :bot_id, :params

  def create_message_events!
    BotUser.with_advisory_lock("bot-user-#{@bot.uid}-#{bot_user_uid}") do
      @bot_user = bot_instance.users.find_by(uid: bot_user_uid) || BotUser.new(uid: bot_user_uid)

      if @bot_user.new_record?
        @bot_user.assign_attributes(bot_user_params)
        @bot_user.save!
      end
    end

    begin
      event = @bot_user.events.create!(event_params)

      if event.is_for_bot?
        @bot_user.increment!(:bot_interaction_count)
        @bot_user.update_attribute(:last_interacted_with_bot_at, event.created_at)
      end

      if (text = event.text).present?
        bot.dashboards.custom.enabled.each do |dashboard|
          r = Regexp.new(dashboard.regex, Regexp::IGNORECASE)
          dashboard.dashboard_events.create(event: event) if r.match(text)
        end
      end

      bot.update_first_received_event_at!
    rescue ActiveRecord::RecordNotUnique => e
      Rails.logger.error "Could not create event for instance #{bot.uid} #{e.inspect}"
    end
  end

  def serialized_params
    EventSerializer.new(:first_opinion, events, bot_instance.uid).serialize
  end

  def event_params
    params.dig(:data).merge(bot_instance_id: bot_instance.id)
  end

  def bot_user_params
    user = params[:recip_info].symbolize_keys
    if user[:type] == 'user'
      {
        user_attributes: {
          name: user[:name],
          gender: user[:gender],
          age: user[:age],
          state: user[:state],
          ip_city: user[:ip_city],
          ip_state: user[:ip_state],
          ip_country: user[:ip_country]
        },
        bot_instance_id: bot_instance.id,
        provider: 'first_opinion',
        membership_type: 'user'
      }
    else
      {
        user_attributes: {
          name: user[:name]
        },
        bot_instance_id: bot_instance.id,
        provider: 'first_opinion',
        membership_type: 'doctor'
      }
    end
  end

  def bot_user_uid
    params.dig(:recip_info, :token)
  end
end
