class User < ApplicationRecord
  has_secure_password validations: false 
  
  validates :email, presence: true, uniqueness: true
   
end
