class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

    user ||= User.new # guest user (not logged in)

    # Even guests can see the apply button
    # This is revoked for coaches and organizers below.
    can :view_apply_button, Event
    can %i(show index archive), Event

    if user.role? :pupil
      # Pupils can only edit their own profiles
      can %i(new create), Profile
      can %i(index show edit update destroy), Profile, user: { id: user.id }
      # Pupils can only edit their own applications
      can %i(new create), ApplicationLetter if user.profile.present?
      can %i(index show edit update check destroy), ApplicationLetter, user: { id: user.id }
      # Pupils can upload their letters of agreement
      can [:create], AgreementLetter
      can %i(new create), Request
      cannot :view_personal_details, ApplicationLetter, user: { id: !user.id }
    end
    if user.role? :coach
      # Coaches can view Applications and participants for and view, upload and download materials for Event
      can %i(view_applicants view_participants view_material upload_material print_applications download_material), Event
      can %i(view_and_add_notes show), ApplicationLetter
      can %i(show index), Request
      cannot :view_apply_button, Event
      cannot :check, ApplicationLetter
    end
    if user.role? :organizer
      can %i(index show), Profile
      can %i(index show view_and_add_notes update_status), ApplicationLetter
      cannot :update, ApplicationLetter
      can %i(view_applicants edit_applicants view_participants print_applications
             manage view_material upload_material print_agreement_letters download_material
             view_unpublished show_eating_habits print_applications_eating_habits view_hidden), Event
      can :send_email, Email
      can %i(manage set_contact_person set_notes), Request
      cannot :apply, Event
      cannot :view_apply_button, Event
      can %i(edit update destroy), Event
      can [:update], ParticipantGroup

      # Organizers can update user roles of pupil, coach and organizer, but cannot manage admins and cannot update a role to admin
      can :manage, User, role: %w(pupil coach organizer)
      cannot :update_role, User, role: 'admin'
      cannot :update_role_to_admin, User
    end
    if user.role? :admin
      can :manage, :all

      can :view_delete_button, ApplicationLetter
      cannot %i(edit update), ApplicationLetter
    end
  end
end
