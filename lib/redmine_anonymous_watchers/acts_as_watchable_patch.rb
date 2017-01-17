require 'plugins/acts_as_watchable/lib/acts_as_watchable'

module RedmineAnonymousWatchers
  module ActsAsWatchablePatch
    def self.included(base)
      base::ClassMethods.send(:include, ClassMethods)
      base::ClassMethods.module_eval do
        alias_method_chain :acts_as_watchable, :anonymous
      end

      base::InstanceMethods.send(:include, InstanceMethods)
      base::InstanceMethods.module_eval do
        alias_method_chain :add_watcher, :anonymous
        alias_method_chain :remove_watcher, :anonymous
        alias_method_chain :watched_by?, :anonymous
        alias_method_chain :watcher_recipients, :anonymous

        def watcher_mails
          anonymous_watchers.map(&:mail).compact
        end

        def watcher_mails=(mails)
          anonymous_watchers.delete_all
          mails = Array(mails).map {|m| m.split(/[\s,]+/)}.flatten.delete_if {|m| m.blank?}
          mails.each {|m| anonymous_watchers << AnonymousWatcher.new(:mail => m)}
        end
      end
    end

    module ClassMethods
      def acts_as_watchable_with_anonymous(options = {})
      return if self.included_modules.include?(Redmine::Acts::Watchable::InstanceMethods)
          
          
        acts_as_watchable_without_anonymous(options)
        #logger.debug(">>>>>>>after acts_as_watchable_without_anon")
        has_many :anonymous_watchers, :as => :watchable, :dependent => :delete_all
        #logger.debug(">>>>>>>after has many")
        #logger.debug("watchable: " + @watchable.inspect)
      end
    end

    module InstanceMethods
      def add_watcher_with_anonymous(obj)
      	#logger.debug(">>>>>>>add_watcher_with_anon")
      	#logger.debug(">>>>>>>obj: "+obj.inspect)
        case obj
        when User
          add_watcher_without_anonymous(obj)
        when String
          anonymous_watchers << AnonymousWatcher.new(:mail => obj)
        when AnonymousWatcher
          anonymous_watchers << obj
        end
      end

      def remove_watcher_with_anonymous(obj)
        case obj
        when User
          remove_watcher_without_anonymous(obj)
        when String
          AnonymousWatcher.delete_all(:watchable_type => self.class.name, :watchable_id => self.id, :mail => obj)
        when AnonymousWatcher
          AnonymousWatcher.delete_all({:watchable_type => self.class.name, :watchable_id => self.id}.merge(
                                          obj.anonymous_token ? {:anonymous_token => obj.anonymous_token} : {:mail => obj.mail}))
        end
      end

      def watched_by_with_anonymous?(obj)
        case obj
        when User
          watched_by_without_anonymous?(obj)
        when String
          watcher_mails.include?(obj)
        when AnonymousWatcher
          anonymous_watchers.any? {|w| obj.anonymous_token ? obj.anonymous_token == w.anonymous_token : obj.mail == w.mail}
        else
          false
        end
      end

      def watcher_recipients_with_anonymous
        recipients = watcher_recipients_without_anonymous
        #logger.debug(">>>>>>>>>>>watcher_recipients_with_anon")
        recipients += watcher_mails
        #logger.debug(">>>>>>>>>>>anon watcher_mails:" + watcher_mails.inspect)
        recipients.uniq
      end
    end
  end
end

Redmine::Acts::Watchable.send :include, RedmineAnonymousWatchers::ActsAsWatchablePatch
