module RedmineAnonymousAuthors
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_issues_sidebar_queries_bottom, :partial => 'issues/sidebar_anonymous_watchers'
  end
end