RSpec.describe EventSerializer::FirstOpinion do
  let!(:timestamp)    { Time.now.to_i }
  let(:data) {
    [
      {
        "id": "event-id",
        "type": "text",
        "timestamp": timestamp,
        "body": "Hi!",
        "message_token": "message-token",
        "user": {
          "type": "user",
          "name": "user-name",
          "gender": "user-gender",
          "age": "user-age",
          "state": "user-state",
          "ip_city": "user-ip-city",
          "ip_state": "user-ip-state",
          "ip_country": "user-ip-country",
          "token": "user-token"
        }
      }
    ]
  }

  describe '.new' do
    context 'invalid params' do
      it { expect { EventSerializer::FirstOpinion.new(nil, 'bi_uid') }.to raise_error('Supplied Option Is Nil') }
    end

    context 'invalid data' do
      it { expect { EventSerializer::FirstOpinion.new({ data: data }, 'bi_uid') }.to raise_error('Invalid Data Supplied') }
    end
  end

  describe '#serialize' do
    subject { EventSerializer.new(:first_opinion, data, 'bi_uid').serialize }

    let(:serialized) {
      [{
        data:  {
          event_type: 'message',
          is_for_bot: true,
          is_from_bot: false,
          is_im: true,
          text: "Hi!",
          provider: "first_opinion",
          created_at: Time.at(timestamp),
          event_attributes: {
            message_token: "message-token",
            id: "event-id"
          }
        },
        recip_info: {
          name: 'user-name',
          type: 'user',
          gender: 'user-gender',
          age: 'user-age',
          state: 'user-state',
          ip_city: 'user-ip-city',
          ip_state: 'user-ip-state',
          ip_country: 'user-ip-country',
          token: 'user-token'
        }
      }]
    }


    it { expect(subject).to eql serialized }
  end
end
