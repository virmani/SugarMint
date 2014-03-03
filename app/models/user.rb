require 'json'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :provider, :uid
  has_many :events
  has_many :user_auths

  def self.find_for_oauth(auth, signed_in_resource=nil)
    user = (User.all :joins => [:user_auths], :readonly => false,
                     :conditions => ["user_auths.provider = ? and user_auths.uid = ?", auth.provider, auth.uid]).first

    unless user
      user = User.create(:name => auth.extra.raw_info.name,
                         :email => auth.info.email,
                         :password => Devise.friendly_token[0, 20]
      )
      auth = UserAuth.create(:user => user, :uid => auth.uid, :provider => auth.provider, :auth_token => auth[:credentials][:token])
    end
    user
  end

  class << self
    alias :find_for_foursquare_oauth :find_for_oauth
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.foursquare_data"]
        user.email = data["email"] if user.email.blank?
      end

      if data = session["devise.foursquare_data"] && session["devise.foursquare_data"][:credentials]
        user.foursquare_token=data[:token]
      end
    end
  end

  def all_checkins
    foursquare_user.all_checkins
  end

  def foursquare_token
    auth = user_auths.where(:provider => :foursquare).first
    auth.auth_token if auth
  end

  def foursquare_token=(token)
    auth = UserAuth.find_or_initialize_by_user_id_and_provider(id, :foursquare)
    auth.auth_token=token
    auth.save!
    auth.auth_token
  end

  private

  def foursquare
    @foursquare ||= Foursquare::Base.new(foursquare_token)
  end

  def foursquare_user
    begin
      @foursquare_user ||= foursquare.users.find("self")
    rescue Foursquare::InvalidAuth => e
      Rails.logger.error("Invalid auth. Error: #{e.inspect}")
    end
  end

end
