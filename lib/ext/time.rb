class Time
  def self.today
    now = Time.now
    Time.utc(now.year, now.month, now.day, 0, 0, 0, 0, 0)
  end
end
