module RedmineAnonymousWatchers
  module MailHandlerPatch
    unloadable

    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :add_watchers, :anonymous
      end
    end

    module InstanceMethods
      def add_watchers_with_anonymous(obj)
        add_watchers_without_anonymous(obj)
        handler_options = MailHandler.send :class_variable_get, :@@handler_options
        if handler_options[:no_permission_check] || user.allowed_to?("add_#{obj.class.name.underscore}_watchers".to_sym, obj.project)
          addresses = [email.to, email.cc, email.from].flatten.compact.uniq.collect {|a| a.strip.downcase}
          addresses -= Setting.plugin_redmine_anonymous_watchers[:ignore_emails].downcase.split(/[\s,]+/)
          addresses -= [redmine_emission_address.downcase]
          addresses -= obj.watcher_users.map(&:mail)
          obj.watcher_mails = addresses
        end
      end

      def redmine_emission_address
        obj = if Redmine::VERSION::MAJOR >= 2
          Mail::Address.new(Setting.mail_from)
        else
          TMail::Address.parse(Setting.mail_from)
        end
        obj.address
      end
    end
  end
end

