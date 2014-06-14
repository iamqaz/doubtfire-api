class UnitRole < ActiveRecord::Base

  # Model associations
  belongs_to :unit    # Foreign key
  belongs_to :user		# Foreign key
  belongs_to :tutorial 		# Foreign key
  belongs_to :role    # Foreign key
  has_one :project, dependent: :destroy

  validates :unit_id, presence: true
  validates :user_id, presence: true
  validates :role_id, presence: true

  scope :students,  -> { joins(:role).where('roles.name = :role', role: 'Student') }
  scope :tutors,    -> { joins(:role).where('roles.name = :role', role: 'Tutor') }
  scope :convenors, -> { joins(:role).where('roles.name = :role', role: 'Convenor') }
  # scope :staff,     -> { where('role_id != ?', 1) }

  scope :other_roles, -> (other) { where("user_id = ? and unit_id = ? and id != ?", other.user_id, other.unit_id, other.id)}

  def self.for_user(user)
    UnitRole.where(user_id: user.id)
  end

  def other_roles
    UnitRole.other_roles( self )  
  end

  def self.permissions
    { 
      student: [ :get ],
      tutor: [ :get ],
      nil => []
    }
  end

  def role_for(user)
    unit_role = unit.role_for(user)
    if unit_role == :student and self.user != user
      unit_role = nil
    end
    unit_role
  end 


  def is_tutor?
    role == Role.tutor
  end

  def is_student?
    role == Role.student
  end

  def is_convenor?
    role == Role.convenor
  end

  def is_teacher?
    is_tutor? or is_convenor?
  end



end
