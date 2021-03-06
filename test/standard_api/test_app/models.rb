# = Models

class Account < ActiveRecord::Base
  has_many :photos
  belongs_to :property
end

class Photo < ActiveRecord::Base
  belongs_to :account, :counter_cache => true
  has_and_belongs_to_many :properties
end

class Document < ActiveRecord::Base
  attr_accessor :file
end

class Pdf < Document
end

class Property < ActiveRecord::Base
  has_and_belongs_to_many :photos
  has_many :accounts, -> { order(:created_at) }
  has_one :landlord, class_name: 'Account'
  has_one :document_attachments, class_name: "Attachment", as: :record, inverse_of: :record
  has_one :document, through: "document_attachments"


  validates :name, presence: true
  accepts_nested_attributes_for :photos

  def english_name
    'A Name'
  end
end

class Reference < ActiveRecord::Base
  belongs_to :subject, polymorphic: true
end

class Document < ActiveRecord::Base
  attr_accessor :file
end

class Attachment < ActiveRecord::Base
  belongs_to :record, polymorphic: true
  belongs_to :document
end

# = Migration

class CreateModelTables < ActiveRecord::Migration[6.0]

  def self.up

    comment = "test comment"
    exec_query(<<-SQL, "SQL")
      COMMENT ON DATABASE #{quote_column_name(current_database)} IS #{quote(comment)};
    SQL

    create_table "accounts", force: :cascade do |t|
      t.string   'name',                 limit: 255
      t.integer  'property_id'
      t.integer  'photos_count', null: false, default: 0
      t.datetime "created_at",                         null: false
    end

    create_table "landlords", force: :cascade do |t|
      t.string  "name"
    end

    create_table "photos", force: :cascade do |t|
      t.integer  "account_id"
      t.integer  "property_id"
      t.string   "format",                 limit: 255
    end

    create_table "properties", force: :cascade do |t|
      t.string   "name",                 limit: 255
      t.string   "aliases",              default: [],   array: true
      t.text     "description"
      t.integer  "constructed"
      t.decimal  "size"
      t.datetime "created_at",                         null: false
      t.boolean  "active",             default: false
    end

    create_table "references", force: :cascade do |t|
      t.integer  "subject_id"
      t.string   "subject_type",         limit: 255
      t.string   "key"
      t.string   "value"
    end
    
    create_table "photos_properties", force: :cascade do |t|
      t.integer  "photo_id"
      t.integer  "property_id"
    end
    
    create_table "landlords_properties", force: :cascade do |t|
      t.integer  "landlord_id"
      t.integer  "property_id"
    end

    create_table "documents", force: :cascade do |t|
      t.string   'type'
    end
    
    create_table "attachments", force: :cascade do |t| 
      t.string  'record_type'
      t.integer  'record_id'
      t.integer  'document_id'
    end
  end

end
ActiveRecord::Migration.verbose = false
CreateModelTables.up
