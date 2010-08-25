module ProfileExt
  def self.included(base)
    base.extend(ClassMethods)
  end
  module ClassMethods
    def profile_ext
      after_create :confirmation_and_newsletter
      include ProfileExt::InstanceMethods
    end
  end
  module InstanceMethods
    def confirmation_and_newsletter
      self.person.update_attributes(:confirmed => false)
      group = PersonGroup.find_or_create_by_title("Newsletter")
      self.person.person_group_ids = self.person.person_group_ids << group.id
      self.save
    end
  end
end
ActiveRecord::Base.send(:include, ProfileExt)
