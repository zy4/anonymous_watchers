require 'redmine'
require 'redmine_anonymous_watchers/acts_as_watchable_patch'
require 'redmine_anonymous_watchers/hooks'

to_prepare = Proc.new do
  unless WatchersHelper.include?(RedmineAnonymousWatchers::WatchersHelperPatch)
    WatchersHelper.send :include, RedmineAnonymousWatchers::WatchersHelperPatch
  end
  unless Issue.include?(RedmineAnonymousWatchers::IssuePatch)
    Issue.send :include, RedmineAnonymousWatchers::IssuePatch
  end
  unless MailHandler.include?(RedmineAnonymousWatchers::MailHandlerPatch)
    MailHandler.send :include, RedmineAnonymousWatchers::MailHandlerPatch
  end
  unless Mailer.include?(RedmineAnonymousWatchers::MailerPatch)
    Mailer.send :include, RedmineAnonymousWatchers::MailerPatch
  end
  unless WatchersController.include?(RedmineAnonymousWatchers::WatchersControllerPatch)
    WatchersController.send :include, RedmineAnonymousWatchers::WatchersControllerPatch
  end
  unless ApplicationController.include?(RedmineAnonymousWatchers::ApplicationControllerPatch)
    ApplicationController.send :include, RedmineAnonymousWatchers::ApplicationControllerPatch
  end
  unless Project.include?(RedmineAnonymousWatchers::ProjectPatch)
    Project.send(:include, RedmineAnonymousWatchers::ProjectPatch)
  end
  unless ActionView::Base.include?(RedmineAnonymousWatchers::Helper)
    ActionView::Base.send(:include, RedmineAnonymousWatchers::Helper)
  end
  unless DocumentsController.include?(RedmineAnonymousWatchers::DocumentsControllerPatch)
    DocumentsController.send(:include, RedmineAnonymousWatchers::DocumentsControllerPatch)
  end
  unless FilesController.include?(RedmineAnonymousWatchers::FilesControllerPatch)
    FilesController.send(:include, RedmineAnonymousWatchers::FilesControllerPatch)
  end
end

if Redmine::VERSION::MAJOR >= 2
  Rails.configuration.to_prepare(&to_prepare)
else
  require 'dispatcher'
  Dispatcher.to_prepare(:redmine_anonymous_watchers, &to_prepare)
end

Redmine::Plugin.register :redmine_anonymous_watchers do
  name 'Redmine Anonymous Watchers plug-in'
  author 'Anton Argirov'
  author_url 'http://redmine.academ.org'
  description "Allows to add emails as watchers and subscribe to Redmine events anonymously"
  url "http://redmine.academ.org"
  version '0.1.0'

  permission :subscribe_anonymously, {:watchers => [:anonymous_watch, :anonymous_unwatch]}

  settings :default => {
    :ignore_emails => ''
  }, :partial => 'settings/anonymous_watchers'
end

