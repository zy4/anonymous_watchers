module RedmineAnonymousWatchers
  module ApplicationControllerPatch
    unloadable

    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        before_filter :generate_anonymous_token
      end
    end

    module InstanceMethods
      def generate_anonymous_token
        return true if cookies[:anonymous_token].present?
        token = Redmine::Utils.random_hex(20)
        cookies[:anonymous_token] = token
      end

      def anonymous_token
        cookies[:anonymous_token].presence
      end
    end
  end
end