class Department < ActiveRecord::Base
  self.primary_keys = :id, :location_id

  has_many :employees,
           # We intentionally redefine primary key for test purposes. #455
           :primary_key =>  [:id, :location_id],
           :foreign_key => [:department_id, :location_id]

  has_many :comments, :through => :employees

  has_one :head, :class_name => 'Employee',  :autosave => true, :dependent => :delete,
                 # We intentionally redefine primary key for test purposes. #455
                 :primary_key =>  [:id, :location_id],
                 :foreign_key => [:department_id, :location_id]

  has_one :head_without_autosave, :class_name => 'Employee',
          # We intentionally redefine primary key for test purposes. #455
          :primary_key =>  [:id, :location_id],
          :foreign_key => [:department_id, :location_id]
end
