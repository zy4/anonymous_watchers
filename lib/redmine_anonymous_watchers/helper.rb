module RedmineAnonymousWatchers
  module Helper
    unloadable

    def include_anonymous_watchers_tags
      unless @anonymous_watchers_tags_included
        @anonymous_watchers_tags_included = true
        content_for :header_tags do
          javascript_include_tag 'anonymous_watchers', :plugin => 'redmine_anonymous_watchers'
        end
      end
    end
  end
end