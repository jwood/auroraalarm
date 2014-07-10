class CleanupService

  def self.execute
    Proby.monitor(ENV['PROBY_CLEANUP']) do
      MessageHistory.purge_old_messages
      AuroraAlert.purge_old_alerts
    end
  end

end
