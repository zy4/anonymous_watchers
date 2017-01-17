class ProjectSubscription < ActiveRecord::Base
  unloadable

  self.abstract_class = true
  self.table_name = "projects"

  acts_as_watchable
  delegate :visible?, :to => :project

  def project
    @project ||= Project.find(id)
  end
end