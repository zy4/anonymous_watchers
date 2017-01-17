module RedmineAnonymousWatchers
  module ProjectPatch
    unloadable

    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
      end
    end
    module InstanceMethods
      def issues_subscription
        IssuesSubscription.find(id)
      end
      def issues_recipients
        issues_subscription.watcher_recipients
      end
      def files_subscription
        FilesSubscription.find(id)
      end
      def files_recipients
        files_subscription.watcher_recipients
      end
      def news_subscription
        NewsSubscription.find(id)
      end
      def news_recipients
        news_subscription.watcher_recipients
      end
      def documents_subscription
        DocumentsSubscription.find(id)
      end
      def documents_recipients
        documents_subscription.watcher_recipients
      end
    end
  end
end