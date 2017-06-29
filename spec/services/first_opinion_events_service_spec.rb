RSpec.describe FirstOpinionEventsService do
  let!(:admin_user)   { create :user }
  let!(:timestamp)    { Time.now.to_i }
  let!(:bot)          { create :bot, provider: 'first_opinion' }
  let!(:bc1)          { create :bot_collaborator, bot: bot, user: admin_user }
  let!(:bot_instance) { create :bot_instance, provider: 'first_opinion', bot: bot }
  let!(:first_name)   { Faker::Name.first_name }
  let!(:last_name)   { Faker::Name.last_name }
  let!(:profile_pic_url)           { Faker::Internet.url }
  let!(:profile_pic_last_modified) { Faker::Date.between(2.days.ago, Date.today)  }

  def do_request
    FirstOpinionEventsService.new(bot_id: bot.uid, events: events).create_events!
  end

  shared_examples "associates event with custom dashboard if custom dashboards exist" do
    let!(:dashboard1) { create :dashboard, bot: bot, regex: 'hello', dashboard_type: 'custom', provider: 'first_opinion' }
    let!(:dashboard2) { create :dashboard, bot: bot, regex: 'eLLo', dashboard_type: 'custom', provider: 'first_opinion' }
    let!(:dashboard3) { create :dashboard, bot: bot, regex: 'welcome', dashboard_type: 'custom', provider: 'first_opinion' }

    it 'should associate events with dashboards that match the text' do
      do_request
      dashboard1.reload; dashboard2.reload; dashboard3.reload
      e = bot_instance.events.last

      expect(dashboard1.raw_events.to_a).to eql [e]
      expect(dashboard2.raw_events.to_a).to eql [e]
      expect(dashboard3.raw_events.to_a).to be_empty
    end
  end

  shared_examples "should create an event as well as create the bot users" do
    it "should create an event" do
      expect {
        do_request
        bot_instance.reload
      }.to change(bot_instance.events, :count).by(2)

      event = bot_instance.events.find_by(event_type: event_type)

      expect(event.event_type).to eql event_type
      expect(event.provider).to eql 'first_opinion'
      expect(event.user).to eql BotUser.find_by(uid: first_opinion_user_id)
      expect(event.event_attributes.slice(*required_event_attributes.keys)).to eql required_event_attributes
      expect(event.text).to eql text
      expect(event.created_at.to_i).to eql timestamp
      expect(event.is_from_bot).to be is_from_bot
      expect(event.is_im).to be is_im
      expect(event.is_for_bot).to be is_for_bot
    end

    it "should create a new BotUser" do
      expect {
        do_request
        bot_instance.reload
      }.to change(bot_instance.users, :count).by(1)

      user = bot_instance.users.last
      expect(user.user_attributes['name']).to eql name
      expect(user.user_attributes['age']).to eql age
      expect(user.user_attributes['gender']).to eql gender
      expect(user.user_attributes['state']).to eql state
      expect(user.user_attributes['ip_city']).to eql ip_city
      expect(user.user_attributes['ip_state']).to eql ip_state
      expect(user.user_attributes['ip_country']).to eql ip_country
      expect(user.uid).to eql first_opinion_user_id
      expect(user.provider).to eql 'first_opinion'
      expect(user.membership_type).to eql 'user'
    end

    it 'should create a user-added event' do
      expect {
        do_request
        bot_instance.reload
      }.to change(bot_instance.events, :count).by(2)

      user = bot_instance.users.last
      event = bot_instance.events.find_by(event_type: 'user-added')
      expect(event.user).to eql user
      expect(event.provider).to eql 'first_opinion'
    end

    it 'should increment bot_interaction_count if is_for_bot, otherwise do not increment' do
      do_request
      user = bot_instance.users.last

      if is_for_bot
        expect(user.bot_interaction_count).to eql 1
      else
        expect(user.bot_interaction_count).to eql 0
      end
    end

    it "should set last_interacted_with_bot_at to the event's created_at timestamp if is_for_bot, otherwise don't do anything" do
      do_request
      user = bot_instance.users.last
      event = bot_instance.events.last

      if is_for_bot
        expect(user.last_interacted_with_bot_at).to eql event.created_at
      else
        expect(user.last_interacted_with_bot_at).to be_nil
      end
    end
  end

  shared_examples "should create an event but not create any bot users" do
    let!(:user)        { create :bot_user, provider: 'first_opinion', bot_instance: bot_instance, uid: first_opinion_user_id }

    it "should create an event" do
      expect {
        do_request
        bot_instance.reload
      }.to change(bot_instance.events, :count).by(1)

      event = bot_instance.events.last

      expect(event.event_type).to eql event_type
      expect(event.provider).to eql 'first_opinion'
      expect(event.user).to eql user
      expect(event.event_attributes.slice(*required_event_attributes.keys)).to eql required_event_attributes
      expect(event.text).to eql text
      expect(event.created_at.to_i).to eql timestamp
      expect(event.is_from_bot).to be is_from_bot
      expect(event.is_im).to be is_im
      expect(event.is_for_bot).to be is_for_bot
    end

    it "should NOT create new BotUsers" do
      expect {
        do_request
        bot_instance.reload
      }.to_not change(bot_instance.users, :count)
    end

    it 'should increment bot_interaction_count if is_for_bot, otherwise do not increment' do
      if is_for_bot
        expect {
          do_request
          user.reload
        }.to change(user, :bot_interaction_count).from(0).to(1)
      else
        expect {
          do_request
          user.reload
        }.to_not change(user, :bot_interaction_count)
      end
    end

    it "should set last_interacted_with_bot_at to the event's created_at timestamp if is_for_bot, otherwise don't do anything" do
      if is_for_bot
        expect {
          do_request
          user.reload
        }.to change(user, :last_interacted_with_bot_at)

        expect(user.last_interacted_with_bot_at).to eql bot_instance.events.last.created_at
      else
        expect {
          do_request
          user.reload
        }.to_not change(user, :last_interacted_with_bot_at)
      end
    end
  end

  describe 'message event' do
    let(:first_opinion_user_id)   { "first-opinion-user-id"  }
    let(:bot_user_id)   { bot.uid        }
    let(:text)          { event_text     }
    let(:event_type)    { 'message'      }
    let(:is_from_bot)   { false }
    let(:is_for_bot)    { true  }
    let(:is_im)         { true  }
    let(:name)         { "user-name"  }
    let(:gender)         { "user-gender"  }
    let(:age)         { "user-age"  }
    let(:state)         { "user-state"  }
    let(:ip_city)         { "user-ip-city"  }
    let(:ip_state)         { "user-ip-state"  }
    let(:ip_country)         { "user-ip-country"  }
    let(:required_event_attributes) {
      Hash["id", "id", "message_token", "message-token"]
    }
    let(:event_text) { 'Hello' }
    let(:events) {
      [
        {
          "id": required_event_attributes['id'],
          "type": "text",
          "timestamp": timestamp,
          "body": text,
          "message_token": required_event_attributes['message_token'],
          "user": {
            "type": "user",
            "name": name,
            "gender": gender,
            "age": age,
            "state": state,
            "ip_city": ip_city,
            "ip_state": ip_state,
            "ip_country": ip_country,
            "token": first_opinion_user_id
          }
        }
      ]
    }
    let(:event_type) { 'message' }

    context "bot user exists" do
      it_behaves_like "should create an event as well as create the bot users"
      it_behaves_like "associates event with custom dashboard if custom dashboards exist"
    end

    context "bot user does not exist" do
      it_behaves_like "should create an event but not create any bot users"
      it_behaves_like "associates event with custom dashboard if custom dashboards exist"
    end
  end
end
