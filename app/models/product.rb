class Product < ActiveRecord::Base
  attr_accessor :category_mode
  attr_accessor :existing_category
  attr_accessor :new_category
  attr_accessor :existing_tags
  attr_accessor :new_tags

  belongs_to :grocery
  belongs_to :category
  has_one :product_image
  has_one :inventory
  has_and_belongs_to_many :tags
  has_many :reports

  accepts_nested_attributes_for :product_image, update_only: true, reject_if: proc { |attributes| attributes[:product_image].blank? }
  accepts_nested_attributes_for :inventory, update_only: true

  # ojo: debe estar en orden 0,1,2,...
  enum unit: {item: 0, kg:1, g:2, L:3, mL:4, m:5}

  validates :grocery, presence: true
  validates :name, presence: true, length: {minimum: 1, maximum: 30}
  validates :stock, numericality: { greater_than_or_equal_to: 0, only_integer: true }, if: "unit == 'item'"
  validates :stock, numericality: { greater_than_or_equal_to: 0 }, unless: "unit == 'item'"
  validates :unit, inclusion: { in: Product.units.keys }
  validates :price, numericality: { only_integer: true, greater_than: 0 }
  validates_uniqueness_of :name, allow_blank: false, scope: :grocery
  validate :validate_new_category
  validate :validate_new_tags

  def setup_attributes_new
    #defaults
    self.category_mode ||= :existing_category
    self.existing_category ||= nil
    self.new_category ||= nil
    self.existing_tags ||= []
    self.new_tags ||= []
    self.product_image ||= ProductImage.new
    self.inventory ||= Inventory.new

  end

  def setup_attributes_edit
    self.existing_category = self.category.nil? ? nil : self.category.id
    self.category_mode = self.category.nil? ? :new_category : :existing_category
    self.new_category = nil
    self.existing_tags = self.tags.map {|x|x.id}
    self.new_tags = []
    self.product_image ||= ProductImage.new
    self.inventory ||= Inventory.new
  end

  def setup_attributes_from_form
    #sanitize existing_tags if it comes from form
    et = @existing_tags
    @existing_tags = []
    et.each do |x|
      next unless x.is_i?
      @existing_tags << x.to_i
    end

    #sanitize existing_category if it comes from form
    ec = @existing_category
    @existing_category = ec.blank? ? nil: ec.to_i

    #sanitize category_mode
    @category_mode = @category_mode.to_sym unless @category_mode.nil?

    self.product_image ||= ProductImage.new
    self.inventory ||= Inventory.new
  end

  def has_image?
    return self.product_image && !self.product_image.product_image.blank?
  end

  def validate_new_tags
    unless @new_tags.blank? || (/^(\w+(,\w+)*)?$/ =~ @new_tags) == 0
      errors.add(:new_tags, ": some tags are invalid. Please use letters [a-zA-Z], numbers [0-9] and underscore (_) only.")
    end
  end

  def validate_new_category
    unless @category_mode != 'new_category' || @new_category.blank? || (/^\w+$/ =~ @new_category) == 0
      errors.add(:new_category, " invalid, plase use letters [a-zA-Z], numbers [0-9] and underscore (_) only.")
    end
  end

  def update_category
    self.update_attribute(:category_id, nil)
    @category_mode = @category_mode.to_sym unless @category_mode.blank?
    if @category_mode == :existing_category
      return if @existing_category.nil?
      return if !@existing_category.is_i?
      cat_id = @existing_category.to_i
      category = Category.find_by_id(cat_id)
      category.products << self if category
    else
      return if @new_category.blank?
      category = Category.where('name = ?',@new_category).first
      category = Category.create(name: @new_category) if(category.nil?)
      category.products << self
    end
  end

  def update_tags
    self.tags.delete_all

    #set existing tags
    if @existing_tags
      @existing_tags.each do |tag_id|
        next unless tag_id.is_i?
        tag_id = tag_id.to_i
        next unless tag_id >= 0
        tag = Tag.find_by_id(tag_id)
        if(tag)
          begin
            self.tags << tag
          rescue ActiveRecord::RecordNotUnique => e
          end
        end
      end
    end

    #set new tags
    if @new_tags
      @new_tags = @new_tags.split(",")
      @new_tags.each do |name|
        tag = Tag.where('name = ?', name).first
        if(tag)
          begin
            self.tags << tag
          rescue ActiveRecord::RecordNotUnique => e
          end
        else
          self.tags.create(name: name)
        end
      end
    end
  end

end
