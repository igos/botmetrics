class Query < ActiveRecord::Base
  belongs_to :query_set

  validates_presence_of  :provider
  validates_inclusion_of :provider, in: %w(slack kik facebook telegram first_opinion)

  validates_presence_of  :field
  validates_inclusion_of :field,  in: ->(query) { query.fields(query.query_set.bot).keys }
  validates_presence_of  :method
  validates_inclusion_of :method, in: ->(query) { query.string_methods.keys | query.number_methods.keys | query.datetime_methods.keys }
  validates_presence_of  :value,     if: ->(query) { query.method != 'between' }
  validates_presence_of  :min_value, if: ->(query) { query.method == 'between' }
  validates_presence_of  :max_value, if: ->(query) { query.method == 'between' }

  delegate :fields, :select_fields_collection, :string_methods, :number_methods, :datetime_methods,
           to: :query_source

  def query_source
    @_query_source ||= Queries::Finder.for_type(provider)
  end

  def is_string_query?
    query_source.is_string_query?(field)
  end

  def is_number_query?
    query_source.is_number_query?(field)
  end

  def is_datetime_query?
    query_source.is_datetime_query?(field)
  end

  def to_form_params
    { provider: provider, field: field, method: method, value: value }
  end

  def dashboard
    dashboard_uid = self.field.match(/\Adashboard:([0-9a-f]+)\Z/)[1]
    bot = self.query_set.bot
    bot.dashboards.find_by(uid: dashboard_uid)
  end
end
