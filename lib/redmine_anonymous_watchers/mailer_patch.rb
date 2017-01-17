module RedmineAnonymousWatchers
  module MailerPatch
    unloadable

    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :issue_add, :anonymous_watchers
        alias_method_chain :issue_edit, :anonymous_watchers
        alias_method_chain :document_added, :anonymous_watchers
        alias_method_chain :attachments_added, :anonymous_watchers
        alias_method_chain :news_added, :anonymous_watchers
        if Redmine::VERSION::MAJOR < 2
          alias_method_chain :create_mail, :anonymous_watchers
        else
          alias_method_chain :mail, :anonymous_watchers
        end
      end
    end

    module InstanceMethods
      def issue_add_with_anonymous_watchers(issue, to_users, cc_users)
        @subscription_recipients = issue.project.issues_recipients
        ## fixed: issue.project.issues_recipients -> issue.journalized.watcher_recipients
         #@subscription_recipients = issue.journalized.watcher_recipients
        issue_add_without_anonymous_watchers(issue, to_users, cc_users)
      end
      
      def issue_edit_with_anonymous_watchers(journal, to_users, cc_users)
        @subscription_recipients = journal.journalized.watcher_recipients
        ## fixed: issue.project.issues_recipients -> journal.journalized.watcher_recipients
        issue_edit_without_anonymous_watchers(journal, to_users, cc_users)
      end
      
      def document_added_with_anonymous_watchers(document)
        @subscription_recipients = document.project.documents_recipients
        document_added_without_anonymous_watchers(document)
      end
      def attachments_added_with_anonymous_watchers(attachments)
        container = attachments.first.container
        case container.class.name
        when 'Project'
          @subscription_recipients = container.files_recipients
        when 'Version'
          @subscription_recipients = container.project.files_recipients
        when 'Document'
          @subscription_recipients = container.project.documents_recipients
        end
        attachments_added_without_anonymous_watchers(attachments)
      end
      def news_added_with_anonymous_watchers(news)
        @subscription_recipients = news.project.news_recipients
        news_added_without_anonymous_watchers(news)
      end
      def mail_with_anonymous_watchers(headers={})
        headers[:cc] = (Array(headers[:cc]) + Array(@subscription_recipients) - Array(headers[:to])).uniq
        mail_without_anonymous_watchers(headers)
      end
      def create_mail_with_anonymous_watchers
        cc (Array(cc) + Array(@subscription_recipients) - Array(recipients)).uniq
        create_mail_without_anonymous_watchers
      end
    end
  end
end

