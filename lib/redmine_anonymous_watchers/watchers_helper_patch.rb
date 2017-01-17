module RedmineAnonymousWatchers
  module WatchersHelperPatch
    unloadable

    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :watchers_checkboxes, :anonymous
        alias_method_chain :watchers_list, :anonymous
        alias_method_chain :watcher_link, :anonymous
      end
    end
    module InstanceMethods
      def watcher_link_with_anonymous(object, user)
        return watcher_link_without_anonymous(object, user) unless user && user.anonymous? && object.respond_to?('watched_by?')
        return '' unless User.current.allowed_to?(:subscribe_anonymously, nil, :global => true)
        include_anonymous_watchers_tags
        watched = cookies[:anonymous_token] && object.watched_by?(AnonymousWatcher.new(:anonymous_token => cookies[:anonymous_token]))
        url = {:controller => 'watchers',
               :action => (watched ? 'anonymous_unwatch' : 'anonymous_watch'),
               :object_type => object.class.to_s.underscore,
               :object_id => object.id}
        link_to((watched ? l(:button_unwatch) : l(:button_watch)), url,
                :class => (watched ? 'icon icon-fav' : 'icon icon-fav-off'),
                :onclick => watched ? "return anonymousUnwatch(this.href);" :
                    "return anonymousWatch(#{l(:text_enter_watcher_email).to_json}, #{(cookies[:watcher_mail] || cookies[:author_mail] || "").to_json}, this.href);")
      end
      def watchers_list_with_anonymous(object)
        str = watchers_list_without_anonymous(object)
        remove_allowed = User.current.allowed_to?("delete_#{object.class.name.underscore}_watchers".to_sym, object.project)
        content = ''.html_safe
        object.watcher_mails.collect do |mail|
          s = ''.html_safe
          s << link_to(mail, "mailto:"<<mail, :class => 'mail')
          if remove_allowed
            url = {:controller => 'watchers',
                   :action => 'destroy',
                   :object_type => object.class.to_s.underscore,
                   :object_id => object.id,
                   :mail => mail}
            s << ' '
            if Redmine::VERSION::MAJOR >= 2
              s << link_to(image_tag('delete.png'), url,
                           :remote => true, :method => 'delete', :style => "vertical-align: middle", :class => "delete")
            else
              s << link_to_remote(image_tag('delete.png'), {:url => url}, :href => url_for(url),
                           :style => "vertical-align: middle", :class => "delete")
            end
          end
          content << content_tag('li', s)
        end
        content.present? ? str + content_tag('ul', content) : str
      end
      def watchers_checkboxes_with_anonymous(object, users, checked=nil)
        str = watchers_checkboxes_without_anonymous(object, users, checked)
        mails = object && object.watcher_mails || @watcher_mails
        mails ? str + mails.map do |mail|
          c = checked.nil? ? object.watched_by?(mail) : checked
          tag = check_box_tag 'issue[watcher_mails][]', mail, c, :id => nil
          content_tag 'label', "#{tag} #{h(mail)}".html_safe,
                      :id => "issue_watcher_mails_"+mail.gsub(/[^\w]+/, '_'),
                      :class => "floating"
        end.join.html_safe : str
      end
    end
  end
end
