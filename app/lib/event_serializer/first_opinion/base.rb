class EventSerializer::FirstOpinion::Base
  def initialize(data, bi_uid)
    raise 'Supplied Option Is Nil' if data.nil?
    @data = data
    @bi_uid = bi_uid
  end

  def serialize
    { data: data, recip_info: recip_info }
  end

  protected
  def recip_info
    user = @data[:user]
    if user[:type] == 'user'
      {
        name: user[:name],
        type: user[:type],
        gender: user[:gender],
        age: user[:age],
        state: user[:state],
        ip_city: user[:ip_city],
        ip_state: user[:ip_state],
        ip_country: user[:ip_country],
        token: user[:token]
      }
    else
      {
        name: user[:name],
        type: user[:type],
        token: user[:token]
      }
    end
  end

  def timestamp
    Time.at(@data[:timestamp])
  end
end
