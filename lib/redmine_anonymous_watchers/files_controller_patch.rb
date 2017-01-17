module RedmineAnonymousWatchers
  module FilesControllerPatch
    unloadable

    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        helper WatchersHelper
      end
    end

    module InstanceMethods
    end
  end
end