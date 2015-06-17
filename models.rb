ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']||"sqlite3:db/development.db")
class Item < ActiveRecord::Base
  validates :url, presence: true
  validates :url, format: { with: URI::regexp(%w(http https)) }
  belongs_to :tag
  belongs_to :user
end

class Tag < ActiveRecord::Base
  has_many :items
end

class User < ActiveRecord::Base
  has_secure_password
  validates :name, presence: true
  has_many :items
end
