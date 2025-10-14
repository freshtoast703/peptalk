class Post < ApplicationRecord
  has_many :share_links, dependent: :destroy
end
