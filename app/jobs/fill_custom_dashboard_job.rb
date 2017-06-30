class FillCustomDashboardJob < Job
  def perform(dashboard_id)
    dashboard = Dashboard.find(dashboard_id)
    events = Event.where("text ILIKE '%#{dashboard.regex}%'")
    events = events.map { |e| { event: e } }
    dashboard.dashboard_events.create(events)
  end
end
