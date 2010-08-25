module ProfileExt
  def self.included(base)
    base.extend(ClassMethods)
  end
  module ClassMethods
    def profile_ext
      after_create :confirmation_and_newsletter
      include ProfileExt::InstanceMethods
    end
    def person_ext
      after_save :group_membership_check
      include ProfileExt::InstanceMethods
    end
  end
  module InstanceMethods
    def confirmation_and_newsletter
      self.person.update_attributes(:confirmed => false)
      group = PersonGroup.find_or_create_by_title("Newsletter")
      group2 = PersonGroup.find_or_create_by_title("Unconfirmed Profiles")
      self.person.person_group_ids = self.person.person_group_ids << group.id
      self.person.person_group_ids = self.person.person_group_ids << group2.id
      self.save
    end
  end
  def unconfirmed
    if self.respond_to?(:confirmed) 
      self.confirmed.blank?
    else
      self.person.confirmed.blank?
    end
  end
  def group_membership_check
    ids_for_person = self.person_group_ids
    for state in ["confirmed", "unconfirmed"]
      group = PersonGroup.find_or_create_by_title("#{state.capitalize} Profiles")
      if self.send(state.downcase.to_sym)
        self.person_group_ids = self.person_group_ids << group.id
      end
      unless self.send(state.to_sym)
        self.person_group_ids = self.person_group_ids.reject{|g| g == group.id}
      end
    end
    self.save unless ids_for_person == self.person_group_ids
  end
end
ActiveRecord::Base.send(:include, ProfileExt)
