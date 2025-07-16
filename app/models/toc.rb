class Toc < ApplicationRecord
  include Current
  cattr_accessor :current 
  attr_accessor :current_toc
  has_paper_trail on: [:update, :destroy], ignore: [:track_changes,:updated_at,:gauth_tmp,:gauth_tmp_datetime], if: Proc.new { Current.toc }
  attr_accessor :executed
  after_update :track_changes_in_table, unless: :executed
  attr_accessor :gauth_token

  has_one :role
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :google_authenticatable,:database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  # def self.current
 #    Thread.current[:toc]
 #    # RequestStore.store[:toc]
 #  end
 #  def self.current=(toc)
 #    Thread.current[:toc] = toc
 #    RequestStore.store[:toc] = toc
 #  end         

  rails_admin do
    list do
      field :id do
        visible do
           Current.toc.role.role.eql?"superadmin"
        end
      end
      field :email
      field :sign_in_count do
        visible do
           Current.toc.role.role.eql?"superadmin"
        end
      end
      field :current_sign_in_at do
        visible do
           Current.toc.role.role.eql?"superadmin"
        end
      end
      field :last_sign_in_at do
        visible do
           Current.toc.role.role.eql?"superadmin"
        end
      end
      field :current_sign_in_ip do
        visible do
           Current.toc.role.role.eql?"superadmin"
        end
      end
      field :last_sign_in_ip do
        visible do
           Current.toc.role.role.eql?"superadmin"
        end
      end
      field :created_at do
        visible do
           Current.toc.role.role.eql?"superadmin"
        end
      end
      field :updated_at do
        visible do
           Current.toc.role.role.eql?"superadmin"
        end
      end
      field :gauth_secret do
        visible do
           Current.toc.role.role.eql?"superadmin"
        end
      end
      field :gauth_enabled do
        visible do
           Current.toc.role.role.eql?"superadmin"
        end
      end
      field :backup_code do
        visible do
           Current.toc.role.role.eql?"superadmin"
        end
      end
      field :role do
        visible do
           Current.toc.role.role.eql?"superadmin"
        end
      end
    end
    show do
      field :id do
        visible do
           Current.toc.role.role.eql?"superadmin"
        end
      end
      field :email
      field :sign_in_count do
        visible do
           Current.toc.role.role.eql?"superadmin"
        end
      end
      field :current_sign_in_at do
        visible do
           Current.toc.role.role.eql?"superadmin"
        end
      end
      field :last_sign_in_at do
        visible do
           Current.toc.role.role.eql?"superadmin"
        end
      end
      field :current_sign_in_ip do
        visible do
           Current.toc.role.role.eql?"superadmin"
        end
      end
      field :last_sign_in_ip do
        visible do
           Current.toc.role.role.eql?"superadmin"
        end
      end
      field :created_at do
        visible do
           Current.toc.role.role.eql?"superadmin"
        end
      end
      field :updated_at do
        visible do
           Current.toc.role.role.eql?"superadmin"
        end
      end
      field :gauth_secret do
        visible do
           Current.toc.role.role.eql?"superadmin"
        end
      end
      field :gauth_enabled do
        visible do
           Current.toc.role.role.eql?"superadmin"
        end
      end
      field :backup_code do
        visible do
           Current.toc.role.role.eql?"superadmin"
        end
      end
      field :role do
        visible do
           Current.toc.role.role.eql?"superadmin"
        end
      end
    end
    edit do
      field :email
      field :password
      field :password_confirmation
      field :role
    end
    create do
      field :email
      field :password
      field :password_confirmation
      field :role
    end
  end

  def has_role?(role)
    # self.role.where(role: role.to_s).length > 0
    self.role.role == role.to_s rescue false
  end

  def self.get_read_privileges(id)
    m = Toc.find(id)
    read_array = m.role.read_privileges.compact.reject(&:blank?)
    if !read_array.nil?
      read_array.each_with_index do |model,index|
        read_array[index] = Object.const_get(model)
      end
    else
      read_array=[]
    end
    return read_array
  end#self.get_read_privileges(id)

  def self.get_create_privileges(id)
    m = Toc.find(id)
    create_array = m.role.create_privileges.compact.reject(&:blank?) rescue nil
    if !create_array.nil?
      create_array.each_with_index do |model,index|
        create_array[index] = Object.const_get(model)
      end
    else
      create_array=[]
    end
    return create_array
  end#self.get_create_privileges(id)

  def self.get_update_privileges(id)
    m = Toc.find(id)
    update_array = m.role.update_privileges.compact.reject(&:blank?) rescue nil
    if !update_array.nil?
      update_array.each_with_index do |model,index|
        update_array[index] = Object.const_get(model)
      end
    else
      update_array=[]
    end
    return update_array
  end#self.get_update_privileges(id)

  def self.get_export_privileges(id)
    m = Toc.find(id)
    update_array = m.role.export_privileges.compact.reject(&:blank?) rescue nil
    if !update_array.nil?
      update_array.each_with_index do |model,index|
        update_array[index] = Object.const_get(model)
      end
    else
      update_array=[]
    end
    return update_array
  end#self.get_update_privileges(id)


  def self.get_delete_privileges(id)
    m = Toc.find(id)
    delete_array = m.role.delete_privileges.compact.reject(&:blank?) rescue nil
    if !delete_array.nil?
      delete_array.each_with_index do |model,index|
        delete_array[index] = Object.const_get(model)
      end
    else
      delete_array=[]
    end
    return delete_array
  end#self.get_delete_privileges

  def self.get_history_privileges(id)
    m = Toc.find(id)
    history_array = m.role.history_privileges.compact.reject(&:blank?)
    if !history_array.nil?
      history_array.each_with_index do |model,index|
        history_array[index] = Object.const_get(model)
      end
    else
      history_array=[]
    end
    return history_array
  end#self.get_history_privileges(id)

private

  def track_changes_in_table
    allowed_changes = ["email","encrypted_password"] & self.saved_changes.keys
    if Current.toc.present? && allowed_changes.present? 
      row = Toc.find(self.id)
      version = PaperTrail::Version.where('item_type=? and item_id=? and whodunnit=?','Toc',self.id,Current.toc.id.to_s).last.object_changes rescue nil
      if version.present?
        version_data = version.gsub("\n"," ").gsub("--- ","")
        message = "Admin #{Current.toc.email} with id '#{Current.toc.id}' updated the following fields of Toc '#{row.id}'"+' '+version_data
        subject = "Admin  with id '#{Current.toc.id}', role #{Current.toc.role.role} updated TOC table"
        latest_changes = []
        latest_changes << version_data
        latest_changes << Current.toc.email[0..3]+""+Current.toc.id.to_s+" "+Time.zone.now.strftime("%d/%m/%Y %H:%M")
        all_changes = (row.track_changes + latest_changes).flatten
        row.track_changes = all_changes
        row.executed = true
        row.save!
        UserMailer.track_changes(message,subject).deliver_later
      end#version.present?
    end#Current.toc.present? && self.saved_changes.present? 
  end#track_changes_in_table
end
