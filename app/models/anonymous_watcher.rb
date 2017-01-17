class AnonymousWatcher < ActiveRecord::Base
  unloadable

  belongs_to :watchable, :polymorphic => true

  validates_presence_of :mail
  validates_uniqueness_of :mail, :scope => [:watchable_type, :watchable_id], :allow_blank => true
  validates_format_of :mail, :with => /\A([\A@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, :allow_blank => true

  def anonymous?
    true
  end

  def logged?
    false
  end
end
