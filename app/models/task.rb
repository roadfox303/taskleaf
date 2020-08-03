class Task < ApplicationRecord
  # コールバックを追加
  before_validation :set_nameless_name

  validates :name, presence: true, length: { maximum:30 }
  # 自作のバリデートメソッドを追加
  validate :validate_name_not_including_comma

  belongs_to :user
  has_one_attached :image

  scope :recent, -> { order(created_at: :desc) }

  paginates_per 20

  def self.ransackable_attributes(auth_object = nil)
    %w[name created_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  def self.csv_attributes
    ["name", "description", "created_at", "updated_at"]
  end

  def self.generate_csv
    CSV.generate(headers: true) do |csv|
      csv << csv_attributes
      all.each do |task|
        csv << csv_attributes.map{|attr| task.send(attr)}
      end
    end
  end

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      task = new
      task.attributes = row.to_hash.slice(*csv_attributes)
      task.save!
    end
  end

  private
  # コールバックメソッド
  def set_nameless_name
    #self.name = '名前なし' if name.blank?
  end
  # 自作のバリデート用メソッド
  def validate_name_not_including_comma
    errors.add(:name, 'にカンマを含める事はできません') if name&.include?(',')
  end
end
