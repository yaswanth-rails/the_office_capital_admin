class BankAccount < ApplicationRecord
  include Current
  attr_accessor :current_toc
  has_paper_trail on: [:create, :update, :destroy], ignore: [:track_changes,:updated_at], if: Proc.new { Current.toc }
  attr_accessor :executed
  after_update :track_changes_in_table, unless: :executed
  after_update :bank_account_update_alert, unless: :executed
  belongs_to :user, optional: true 
  before_destroy :check_withdraws

  has_many :withdraws
  # has_many :sell_bitcoins
  # belongs_to :affiliate, optional: true
  def account_type_enum
    [['savings'],['current']]
  end#contest_type_enum
  def emp_status_enum
    [['pending'],['in-review'],['completed']]
  end

  mount_uploader :bank_account_proof, KycUploader
  mount_uploader :additional_doc1, KycUploader
  mount_uploader :additional_doc2, KycUploader

  validates_format_of :account_holder_first_name, with: /\A[a-zA-Z ]*\z/
  validates_length_of :account_holder_first_name, minimum: 3, maximum: 30
  # validates_format_of :account_holder_middle_name, with: /\A[a-zA-Z ]*\z/, unless: lambda{ |user| user.account_holder_middle_name.blank? } 
  # validates_length_of :account_holder_middle_name, minimum: 3, maximum: 30, unless: lambda{ |user| user.account_holder_middle_name.blank? } 
  validates_format_of :account_holder_last_name, with: /\A[a-zA-Z ]*\z/, unless: lambda{ |user| user.account_holder_last_name.blank? }    
  validates_length_of :account_holder_last_name, minimum: 3, maximum: 30, unless: lambda{ |user| user.account_holder_last_name.blank? }       
  validates_format_of :account_number, with: /\A[0-9]*\z/
  validates :account_number, uniqueness: true
  # validates_format_of :bank_name, with: /\A[a-zA-Z0-9. ]*\z/
  # validates_length_of :bank_name, minimum: 2
  # validates_format_of :swift_code, with: /\A[a-zA-Z0-9. ]*\z/
  validates_presence_of :ifsc_code
  validates_format_of :ifsc_code, with: /\A^[A-Z]{4}[0][A-Z0-9]{6}$\z/, unless: lambda{ |bank_account| bank_account.ifsc_code.blank? }
  # validates_format_of :ifsc_code, with: /\A[a-zA-Z0-9. ]*\z/
  validates_format_of :account_type, with: /\A[a-zA-Z0-9. ]*\z/
  # validates_format_of :branch_name, with: /\A[a-zA-Z0-9. ]*\z/
  validates_format_of :city, with: /\A[a-zA-Z0-9. ]*\z/
  validates_format_of :nick_name, with: /\A[a-zA-Z0-9. ]*\z/
  validates_length_of :nick_name, minimum: 3, maximum: 10    
  # validates_format_of :country, with: /\A[a-zA-Z0-9. ]*\z/
  # validates_format_of :mobile_number, with: /\A[0-9]*\z/
  # validates_length_of :mobile_number, minimum: 10, maximum: 10
  # validates_format_of :mobile_number,with: /\A^[6-9]\d{9}$\z/, message: " invalid", unless: lambda{ |user| user.mobile_number.blank? }
  # validates :mobile_number, allow_blank: true, allow_nil: true#, on: :create
  validates_format_of :mobile_number, with: /\A[a-zA-Z0-9+\- ]*\z/
  validates :nick_name, uniqueness: {scope: :user_id}

    rails_admin do
      list do
        field :id        
        field :user 
        field :account_holder_first_name
        field :account_holder_middle_name
        field :account_holder_last_name
        field :bank_name
        field :account_number
        field :account_type      
        field :ifsc_code
        field :branch_name
        # field :primary_account
        field :verify
        field :emp_status
        field :created_at             
        field :updated_at                     
        field :hide_account
        field :nick_name
        field :city
        field :state
        field :country
        field :mobile_number
        field :bank_account_proof
        field :reject_bank_account
        field :reject_bank_account_reason        
        field :swift_code
        field :follow_up_count
        field :follow_up_time
        field :bank_account_instruction_1
        field :bank_account_instruction_2
        field :bank_account_instruction_3
        field :track_changes do 
          visible do
            Current.toc.role.role.eql?"superadmin"
          end
        end                      
      end#list 
      show do
        field :id        
        field :account_holder_first_name
        field :account_holder_middle_name
        field :account_holder_last_name
        field :account_number
        # field :primary_account
        field :verify              
        field :ifsc_code
        field :user
        # field :affiliate         
        field :bank_name
        field :created_at             
        field :updated_at                     
        field :hide_account
        field :account_type      
        field :branch_name
        field :nick_name
        field :city
        field :state
        field :country
        field :mobile_number
        field :bank_account_proof
        field :reject_bank_account
        field :reject_bank_account_reason        
        field :swift_code
        field :follow_up_count
        field :follow_up_time
        field :withdraws
        field :emp_status
        field :bank_account_instruction_1
        field :bank_account_instruction_2
        field :bank_account_instruction_3
        field :track_changes do 
          visible do
            Current.toc.role.role.eql?"superadmin"
          end
        end                      
      end#show            
      create do
         field :user_id #, :enum do
        #   enum do
        #     User.all.collect {|p| [p.email, p.id]}
        #   end
        # end   
        field :account_holder_first_name
        field :account_holder_middle_name
        field :account_holder_last_name
        field :account_number      
        field :bank_name
        field :swift_code              
        field :ifsc_code
        field :account_type      
        field :branch_name
        field :city
        field :state
        field :country
        field :mobile_number
        # field :primary_account
        field :nick_name
        field :additional_doc1
        field :additional_doc2        
        field :verify
        field :hide_account
        field :bank_account_proof
        field :reject_bank_account
        field :reject_bank_account_reason
        field :emp_status
        field :bank_account_instruction_1
        field :bank_account_instruction_2
        field :bank_account_instruction_3
      end
      # configure :track_changes do
      #   hide do
      #     Current.toc && Current.toc.role != "superadmin"
      #   end
      # end      
      edit do
        field :account_holder_first_name
        field :account_holder_middle_name
        field :account_holder_last_name
        field :account_number      
        field :bank_name
        field :swift_code              
        field :ifsc_code
        field :account_type      
        field :branch_name
        field :city
        field :state
        field :country
        field :mobile_number                      
        # field :primary_account
        field :nick_name
        field :verify do
          read_only do
            bindings[:object].verify ==true && Current.toc.role.role =="employee"
          end
        end
        field :hide_account
        field :bank_account_proof #do
        #   visible do
        #     if bindings[:object].bank_account_proof.present?
        #       def render
        #         bindings[:view].render partial: 'proof', locals: {value: bindings[:object].bank_account_proof.url, form: bindings[:form], field_name: 'bank_account_proof', model: 'bank_account', bucket: ENV["PRECEED_SELFIE_WITH"] }
        #       end
        #     else
        #       true
        #     end#if bindings[:object].bank_account_proof.present?
        #   end#visible do
        # end#field :bank_account_proof do
        field :additional_doc1 #do
        #   visible do
        #     if bindings[:object].additional_doc1.present?
        #       def render
        #         bindings[:view].render partial: 'proof', locals: {value: bindings[:object].additional_doc1.url, form: bindings[:form], field_name: 'additional_doc1', model: 'bank_account', bucket: ENV["PRECEED_SELFIE_WITH"] }
        #       end
        #     else
        #       true
        #     end#if bindings[:object].additional_doc1.present?
        #   end#visible do
        # end#field :additional_doc1 do
        field :additional_doc2 #do
        #   visible do
        #     if bindings[:object].additional_doc2.present?
        #       def render
        #         bindings[:view].render partial: 'proof', locals: {value: bindings[:object].additional_doc2.url, form: bindings[:form], field_name: 'additional_doc2', model: 'bank_account', bucket: ENV["PRECEED_SELFIE_WITH"] }
        #       end
        #     else
        #       true
        #     end#if bindings[:object].additional_doc2.present?
        #   end#visible do
        # end#field :additional_doc2 do         
        field :reject_bank_account
        field :reject_bank_account_reason 
        field :follow_up_count
        field :follow_up_time
        field :emp_status  
        field :bank_account_instruction_1
        field :bank_account_instruction_2
        field :bank_account_instruction_3     
      end
    end#rails_admin    
  private
  def check_withdraws
    if self.withdraws.any?
      errors[:base] << 'This Bank account have withdraws'
      throw :abort
    end
  end  

  def track_changes_in_table
    if Current.toc.present? && self.saved_changes.present? 
      row = BankAccount.find(self.id)
      version = PaperTrail::Version.where('item_type=? and item_id=? and whodunnit=?','BankAccount',self.id,Current.toc.id.to_s).last.object_changes rescue nil
      if version.present?
        version_data = version.gsub("\n"," ").gsub("--- ","")
        message = "Admin #{Current.toc.email} with id '#{Current.toc.id}' updated the following fields of BankAccount '#{row.id}'"+' '+version_data
        subject = "Admin  with id '#{Current.toc.id}', role #{Current.toc.role.role} updated BankAccount table"
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

  def bank_account_update_alert
    ua = AgentOrange::UserAgent.new('Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/45.0.2454.101 Chrome/45.0.2454.101 Safari/537.36')
    if bank_account_proof.present?
      if bank_account_proof_previously_changed? && persisted?
        UserMailer.bank_proof_alert(self,"bank_account_proof").deliver_now
      end
    end 

    if additional_doc1.present?
      if additional_doc1_previously_changed? && persisted?
        UserMailer.bank_proof_alert(self,"additional_doc1").deliver_now
      end
    end

    if additional_doc2.present?
      if additional_doc2_previously_changed? && persisted?
        UserMailer.bank_proof_alert(self,"additional_doc2").deliver_now
      end
    end

    if (verify_previously_changed? && persisted?) or (reject_bank_account_previously_changed? && persisted?)
      if verify == true
        if (reject_bank_account_previously_changed? && persisted?) && self.reject_bank_account == true
          self.verify = false
        elsif (verify_previously_changed? && persisted?) && self.reject_bank_account == true
          self.reject_bank_account = false
          self.reject_bank_account_reason = nil
        end
        # self.reject_bank_account = false
      end
      if self.verify == true
        user = self.user
        if user.present?
          # if verify set to true bank account verified to true in user
          user.bank_account1_verified = true
          user.save!(validate:false)
        end
        # creating employee kyc stat for bank account verified set to true
        employee_stat = EmployeeKycStat.new(:toc_id=>Current.toc.id,:bank_account_id=>self.id,:user_id=>self.user_id)
        employee_stat.action_performed ="Bank Account verified set to true" if (verify_previously_changed? && persisted?)
        self.emp_status = "completed" if (verify_previously_changed? && persisted?)
        employee_stat.save!
      elsif self.reject_bank_account == true || self.verify == false
        # update user bank account verified in User
        user = self.user
        if user.present?
          # if none of bank accounts are verify to true
          if !user.bank_accounts.where("id != ? and verify =?",self.id,true).present?
            user.bank_account1_verified = false
            #if user tier level index is greater than 0 modifying tier verified to false
            # if self.user.tier.level_index > 0
            #   self.user.tier_verified = false
            # end
            user.save!(validate:false)
          end
        end
        self.emp_status = "completed" if (reject_bank_account_previously_changed? && persisted?) && self.reject_bank_account == true
        # creating employee kyc stat for bank account verified set to false or rejected set to true,false
        employee_stat = EmployeeKycStat.new(:toc_id=>Current.toc.id,:bank_account_id=>self.id)
        employee_stat.action_performed ="Bank Account verified set to false" if (verify_previously_changed? && persisted?) && self.verify == false
        employee_stat.action_performed ="Bank Account rejected set to true" if (reject_bank_account_previously_changed? && persisted?) && self.reject_bank_account == true
        employee_stat.action_performed ="Bank Account rejected set to false" if (reject_bank_account_previously_changed? && persisted?) && self.reject_bank_account == false
        employee_stat.save!
      end
      if !self.verify && !self.reject_bank_account
        self.emp_status = "pending"
      end
      self.executed = true
      self.save!
      if self.verify == true or self.reject_bank_account == true
        UserMailer.bank_account_update_alert(self,ua.device.engine.browser.type).deliver_later
      end
    end#address_proof      
  end

end#BankBankAccount