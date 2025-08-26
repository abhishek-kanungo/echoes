class Event < ApplicationRecord
  belongs_to :submitted_by_user, class_name: 'User', optional: true
  has_many :event_tags, dependent: :destroy
  has_many :tags, through: :event_tags
  
  before_validation :set_event_year

  # Enums (Rails 8+)
  enum :event_type,
       {
         generic: 0,
         movie: 1,
         music: 2,
         sports: 3,
         gaming: 4,
         tech: 5,
         politics: 6,
         meme: 7,
         education: 8,
         internet: 9,
         fashion: 10,
         history: 11,
         tv: 12
       },
       prefix: true
enum :visibility,
     {
       visible_to_all: "public",
       visible_to_self: "private",
       visible_to_friends: "friends"
     },
     prefix: true

     
  validates :title, presence: true, length: { maximum: 255 }
  validates :event_date, presence: true
  validates :event_type, presence: true, inclusion: { in: self.event_types.keys }
  validates :visibility, presence: true, inclusion: { in: self.visibilities.values }
  validates :external_id, uniqueness: { scope: [:external_source, :event_type] }, allow_nil: true

  # Optional: default visibility
  attribute :visibility, :string, default: 'public'
  
  scope :series, -> { where(event_type: event_types[:tv]) }  
  scope :movies, -> { where(event_type: event_types[:movie]) }  

  private

  def set_event_year
    self.event_year ||= event_date&.year
  end
end
