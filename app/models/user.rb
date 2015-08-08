class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  #provide a current_id method for current user id
  def self.logged_in=(id)
    Thread.current[:logged_in] = id
  end

  def self.logged_in
    Thread.current[:logged_in]
  end  

end
