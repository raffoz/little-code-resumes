# This file resumes the basis of Active Record
# Nothing more :)


rake db:drop
rake db:create
rake db:migrate
rake db:seed


######################################
######################################
######################################


MIGRATION

# db/migrate/**********_create_restaurants.rb
class CreateRestaurants < ActiveRecord::Migration[6.0]
  def change
    create_table :restaurants do |t|
      t.string    :name
      t.string    :address
      t.timestamps null: false # this attribute will not accept NULL values for timestamps
      # add 2 columns, `created_at` and `updated_at`
    end
  end
end

# db/migrate/20141027100300_create_doctors.rb
class CreateDoctors < ActiveRecord::Migration[6.0]
  def change
    create_table :doctors do |t|
      t.string      :first_name
      t.string      :last_name
      t.timestamps null: false # this attribute will not accept NULL values for timestamps
      # add 2 columns, `created_at` and `updated_at`

      validates :last_name, presence: true
    end
  end
end

# db/migrate/20141027100400_create_interns.rb
class CreateInterns < ActiveRecord::Migration[6.0]
  def change
    create_table :interns do |t|
      t.string      :first_name
      t.string      :last_name
      t.references  :doctor, foreign_key: true # this foreign_key must be inserted
      # doctor at singular
      t.timestamps
    end
  end
end

# db/migrate/20141027114700_create_patients.rb
class CreatePatients < ActiveRecord::Migration[6.0]
  def change
    create_table :patients do |t|
      t.string      :first_name
      t.string      :last_name
      t.timestamps
    end
  end
end

# db/migrate/20141027114800_create_consultations.rb
class CreateConsultations < ActiveRecord::Migration[6.0]
  def change
    create_table :consultations do |t|
      t.references :doctor, foreign_key: true
      t.references :patient, foreign_key: true
      t.timestamps
    end
  end
end


######################################
######################################
######################################


# db/migrate/********_add_rating_to_restaurants.rb
class AddRatingToRestaurants < ActiveRecord::Migration[6.0]
  def change
    add_column :restaurants, :rating, :integer, default: 0, null: false
  end
end

class AddReferenceToPosts < ActiveRecord::Migration[6.0]
  def change
    add_reference :posts, :user, foreign_key: true
  end
end

class RemoveAgeFromPatients < ActiveRecord::Migration[6.0]
  def change
    remove_column :patients, :age
  end
end

class RenameAgeInPatients < ActiveRecord::Migration[6.0]
  def change
    rename_column :patients, :age, :real_age
  end
end


######################################
######################################
######################################


MODEL

# app/models/restaurant.rb
class Restaurant < ActiveRecord::Base
end

# app/models/doctor.rb
class Doctor < ActiveRecord::Base
  has_many :interns # doctor.interns # here we use the plural
end

# app/models/intern.rb
class Intern < ActiveRecord::Base
  belongs_to :doctor # intern.doctor # here we use the singular
end

# app/models/patient.rb
class Patient < ActiveRecord::Base
  has_many :consultations
  has_many :doctors, through: :consultations
end

# app/models/consultation.rb
class Consultation < ActiveRecord::Base
  belongs_to :patient # this is equal to the foreign key
  belongs_to :doctor # this is equal to the foreign key

# app/models/doctor.rb
class Doctor < ActiveRecord::Base
  has_many :interns
  has_many :consultations
  has_many :patients, through: :consultations # this line must always be after the previous one
end


######################################
######################################
######################################


METHODS

https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html
https://guides.rubyonrails.org/active_record_basics.html


ALL
restaurants = Restaurant.all
# => SELECT * FROM restaurants

# Calling all - that is a class method - on your model gives you
# an ActiveRecord::Relation (similar to Array) of all your records for this model.
# Elements of this ‘array’ are instances of the model class Restaurant.


COUNT
# to count how many "rows"
Restaurant.count


FIND
# find => Returns one record
restaurant = Restaurant.find(1)
restaurant = Restaurant.find_by(id: 1)
# in this second case if the id doesn't exist, it will return nil and the code won't be broken


WHERE
# will not give as a result just one (difference with find method)
restaurant = Restaurant.where(id: [1, 2, 3]) # => SELECT * FROM restaurants WHERE id = 1, 2, 3 [array]
restaurants_in_london = Restaurants.where(address: "London")


FIND_BY
# Finding by attribute
Restaurant.find_by_name("La Tour d'Argent")
Restaurant.find_by(name: "La Tour d'Argent")
# => SELECT * FROM restaurants WHERE name = 'La Tour d\'Argent' LIMIT 1
Restaurant.find_by(address: "London")
# => SELECT * FROM restaurants WHERE address = 'London' LIMIT 1


WHERE LIKE
restaurants = Restaurant.where("name LIKE ?", "%tour%")
# => SELECT * FROM restaurants WHERE name LIKE '%tour%'


RETRIEVE VALUES
restaurant.name
# => "La Tour d'Argent"
restaurant.address
# => "15 Quai de la Tournelle, 75005 Paris"


# Updating an existing record
restaurant = Restaurant.find(1)
restaurant.address = '14 Quai de la Tournelle, 75005 Paris'
restaurant.save
# => UPDATE restaurants SET address = '14 Quai [...]' WHERE id = 1


# Deleting a record
restaurant = Restaurant.find(1)
restaurant.destroy


# Filtering records
restaurants = Restaurant.where(rating: 3)
# => SELECT * FROM restaurants WHERE rating = 3


# First and Last
# https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html
Restaurant.first # Returns the first restaurant in DB
Restaurant.last  # Returns the last restaurant in DB
Restaurant.forty_two # the universe!!!
# https://www.quora.com/Why-is-Array-forty_two-called-the-reddit-in-Ruby-on-Rails
# https://github.com/rails/rails/blob/master/activesupport/lib/active_support/core_ext/array/access.rb#L53


######################################
######################################
######################################


RESUME

# Initialize a restaurant and save
fox = Restaurant.new(name: "The fox")
fox.save

# Create = new + save (at the same time)
Restaurant.create(name: "The fox")
fox = Restaurant.create(name: "The fox")
# the second syntax is the same, but save it in a variable to use it immediately in the code


# Update
restaurant = Restaurant.find(1)
restaurant.address = "Cosenza" # it's my hometown
restaurant.save


# Read (all or one)
restaurants = Restaurant.all # array of Restaurant objects
second_restaurant = Restaurant.find(2)
first_bristol = Restaurant.find_by_address("Bristol")
# find works for every column of the table


# Delete one
second_restaurant.destroy

# Delete all
Restaurant.destroy_all
# pay attention when launching it!!!
# it will delete all your database


# Order
Restaurant.order(address: :asc)
Restaurant.order(rating: :desc)


######################################
######################################
######################################


ADVANCED METHODS AND ASSOCIATIONS


house = Doctor.new(first_name: "Gregory", last_name: "House")
house.interns # => `Array` (`ActiveRecord::Relation`) of `Intern` instances
house.interns.count
house.save

cameron = Intern.new(first_name: "Allison", last_name: "Cameron")
cameron.doctor = house
cameron.save

cameron.doctor.first_name # => "Gregory"


seb = Patient.new(first_name: "Seb", last_name: "Saunier")
flu = Consultation.new
flu.patient = seb
flu.doctor = house
flu.save

seb.consultations # has_many

flu.patient.first_name
flu.doctor.first_name

###

house.patients
# I can do it because I used through: in the Model

# normal Ruby way
patients = []
doctor.consultations.each do |consultation|
  patients << consultation.patient
end
# => `Array` (`ActiveRecord::Relation`) of `Patient` instance

USING THROUGH
# app/models/doctor.rb
class Doctor < ActiveRecord::Base
  has_many :interns
  has_many :consultations

  has_many :patients, through: :consultations
end


######################################
######################################
######################################


VALIDATION

IT CHECKS IF A MODEL IS VALID

# app/models/doctor.rb
class Doctor
  has_many :interns
  has_many :consultations
  has_many :patients, through: :consultations

  validates :last_name, presence: true
end

doctor = Doctor.new(first_name: "Gregory")
doctor.valid?
# => false

doctor.errors.messages
# => { last_name: [ "can't be blank" ] }

doctor.last_name = "House"

doctor.valid?
# => true


IT AUTOMATICALLY HAPPENS
# When calling the save method when your instance is invalid
# the record will not be be inserted in the database!

doctor = Doctor.new(first_name: "Gregory")
doctor.save
# => false
# The record has not been inserted

save # returns true if the record has been inserted
save! # raises an Exception if the record is invalid

save(validate: false) # bypass the control!!!


##################################


UNIQUENESS
# All doctors must have a unique last_name
class Doctor < ActiveRecord::Base
  validates :last_name, uniqueness: true
end


UNIQUENESS and SCOPE
# All doctors must have a unique first_name last_name combination
class Doctor < ActiveRecord::Base
  validates :first_name, uniqueness: { scope: :last_name }
end


LENGTH
# Doctor last names must be at least 3 characters
class Doctor < ActiveRecord::Base
  validates :last_name, length: { minimum: 3 }
end


FORMAT
# Doctor email (column not yet created, migration!) must match a Regex
class Doctor < ActiveRecord::Base
  validates :email, format: { with: /\A.*@.*\.com\z/ }
end
