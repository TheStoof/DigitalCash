class User < ActiveRecord::Base
    attr_accessor :password
        
    before_save :encrypt_password
    after_save :clear_password
    
    EMAIL_REGEX = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+.[A-Z]{2,4}$/i
    PHONE_REGEX = /^[0-9]+$/
    BIRTHDAY_REGEX = /^(0\d|10|11|12)\/([012]\d|30|31)\/\d{4}$/
    USERNAME_REGEX = /^[A-Z\d]+$/i
    NAME_REGEX = /^[A-Za-z]+$/i
    validates :username, :presence => true, :uniqueness => true, :length => { :in => 5..20 }, :format => USERNAME_REGEX
    validates :email, :presence => true, :uniqueness => true, :format => EMAIL_REGEX
    validates :phone_num, :presence => true, :uniqueness => true, :format => PHONE_REGEX
    validates :dob, :presence => true, :format => BIRTHDAY_REGEX
    validates :f_name, :presence => true, :format => NAME_REGEX
    validates :l_name, :presence => true, :format => NAME_REGEX
    validates :password, :confirmation => true #password_confirmation attr
    validates_length_of :password, :in => 6..20, :on => :create
    
    attr_accessible :username, :email, :f_name, :l_name, :gender, :phone_num, :address, :dob, :password, :password_confirmation
    
    def self.authenticate(username_or_email="", login_password="")
      if  EMAIL_REGEX.match(username_or_email)    
        user = User.find_by_email(username_or_email)
      else
        user = User.find_by_username(username_or_email)
      end
    
      if user && user.match_password(login_password)
        return user
      else
        return false
      end
    end   
    
    def match_password(login_password="")
      encrypted_password == BCrypt::Engine.hash_secret(login_password, salt)
    end

    def encrypt_password
      if password.present?
        self.salt = BCrypt::Engine.generate_salt
        self.encrypted_password = BCrypt::Engine.hash_secret(password, salt)
      end
    end
    
    def clear_password
      self.password = nil
    end
end
