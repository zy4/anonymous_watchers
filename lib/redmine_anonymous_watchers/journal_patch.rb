module RedmineAnonymousWatchers
  module JournalPatch
    unloadable

    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :watcher_recipients, :anonymous
      end
    end
    module InstanceMethods
      def watcher_recipients_with_anonymous
        recipients = watcher_recipients_without_anonymous
        recipients += issue.watcher_mails unless private_notes
        recipients.uniq
      end
    end
  end
end


    