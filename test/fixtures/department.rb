class Department < ActiveRecord::Base
  self.primary_keys = :department_id, :location_id

  has_many :employees,
           # We intentionally redefine primary key for test purposes. #455
           :primary_key =>  [:department_id, :location_id],
           :foreign_key => [:department_id, :location_id]

  has_many :comments, :through => :employees

  has_one :head, :class_name => 'Employee',  :autosave => true, :dependent => :delete,
                 # We intentionally redefine primary key for test purposes. #455
                 :primary_key =>  [:department_id, :location_id],
                 :foreign_key => [:department_id, :location_id]
end
