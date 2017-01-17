module RedmineAnonymousWatchers
  module IssuePatch
    unloadable

    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        safe_attributes 'watcher_mails',
          :if => lambda {|issue, user| issue.new_record? && user.allowed_to?(:add_issue_watchers, issue.project)}
      end
    end
    module InstanceMethods
    end
  end
end