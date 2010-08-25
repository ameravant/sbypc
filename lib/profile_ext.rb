module ProfileExt
  def self.included(base)
    base.extend(ClassMethods)
  end
  module ClassMethods
    def profile_ext
      after_create :make_person_unconfirmed
      include ProfileExt::InstanceMethods
    end
  end
  module InstanceMethods
    def make_person_unconfirmed
      self.person.update_attributes(:confirmed => false)
    end
  end
end
ActiveRecord::Base.send(:include, ProfileExt)
