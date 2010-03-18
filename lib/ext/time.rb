class Time
  def self.today
    now = Time.now
    Time.local(now.year, now.month, now.day)
  end
end
