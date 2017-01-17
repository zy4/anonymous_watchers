module RedmineAnonymousWatchers
  module WatchersControllerPatch
    unloadable

    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :destroy, :anonymous
        alias_method_chain :create, :anonymous
        alias_method_chain :append, :anonymous

        before_filter :check_project_privacy, :only => [:anonymous_watch, :anonymous_unwatch]
        before_filter :authorize_global, :only => [:anonymous_watch, :anonymous_unwatch]
      end
    end

    module InstanceMethods
      def anonymous_watch
        if @watched.respond_to?(:visible?) && !@watched.visible?(User.current)
          render_403
        else
          watcher = AnonymousWatcher.new(:mail => params[:mail], :anonymous_token => anonymous_token)
          if !watcher.valid?
            respond_to do |format|
              format.html { flash[:error] = l(:text_cannot_add_watcher); redirect_to_referer_or {render_error :text_cannot_add_watcher} }
              format.js { render :partial => 'anonymous_error', :locals => {:text => l(:text_cannot_add_watcher), :prompt => true} }
            end
          elsif @watched.watched_by?(params[:mail]) && !@watched.watched_by?(watcher)
            respond_to do |format|
              format.html { flash[:error] = l(:text_already_subscribed); redirect_to_referer_or {render_error :text_already_subscribed} }
              format.js { render :partial => 'anonymous_error', :locals => {:text => l(:text_already_subscribed), :prompt => false} }
            end
          else
            cookies[:watcher_mail] = params[:mail]
            set_watcher(watcher, true)
          end
        end
      end

      def anonymous_unwatch
        set_watcher(AnonymousWatcher.new(:anonymous_token => anonymous_token), false) if anonymous_token
      end

      def destroy_with_anonymous
        if params[:mail]
          @watched.set_watcher(params[:mail], false) if request.delete?
          respond_to do |format|
            format.html { redirect_to :back }
            format.js
          end
        else
          destroy_without_anonymous
        end
      end

      def append_with_anonymous
        if params[:watcher].is_a?(Hash)
          @watcher_mails = params[:watcher][:mails].split(/[\s,]+/) || [params[:watcher][:mail]]
        end
        append_without_anonymous
      end

      def create_with_anonymous
        if params[:watcher].is_a?(Hash) && request.post?
          mails = params[:watcher][:mails].split(/[\s,]+/) || [params[:watcher][:mail]]
          mails.each do |mail|
            AnonymousWatcher.create(:watchable => @watched, :mail => mail) if mail.present?
          end
        end
        create_without_anonymous
      end

    end
  end
end
