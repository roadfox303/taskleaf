class Task < ApplicationRecord
  # コールバックを追加
  before_validation :set_nameless_name

  validates :name, presence: true, length: { maximum:30 }
  # 自作のバリデートメソッドを追加
  validate :validate_name_not_including_comma

  belongs_to :user

  scope :recent, -> { order(created_at: :desc) }

  def self.ransackable_attributes(auth_object = nil)
    %w[name created_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
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
