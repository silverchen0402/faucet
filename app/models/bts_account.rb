class BtsAccount < ActiveRecord::Base
  DATE_SCOPES = ['Today', 'Yesterday', 'This week', 'Last week', 'This month', 'Last month', 'All']

  belongs_to :user

  validates :name, presence: true, format: {
      with: /\A[a-z]+(?:[a-z0-9\-\.])*[a-z0-9]\z/,
      message: 'Only lowercase alphanumeric characters, dashes and periods. Must start with a letter and cannot end with a dash.'
  }
  validates :owner_key, presence: true
  validates :active_key, presence: true
  #validates :memo_key, presence: true

  validates_uniqueness_of :remote_ip, conditions: -> {where("created_at > '#{(DateTime.now - 30.minutes).to_s(:db)}'")}, message: "Can't register more than one account per IP in less than 30 minutes"
  validates :remote_ip, presence: true, exclusion: { in: BlackList.pluck(:remote_ip) }

  before_validation :notify_before
  before_create :register_account

  scope :grouped_by_referrers, -> { select([:referrer, 'count(*) as count']).group(:referrer).order('count desc') }

    def self.dates_range(scope_name)
        return nil if scope_name == 'All' || !scope_name.in?(DATE_SCOPES)
        case scope_name
             when 'Today'
               Date.today.beginning_of_day..Date.today.end_of_day
             when 'Yesterday'
               (Date.today - 1.day).beginning_of_day..(Date.today - 1.day).end_of_day
             when 'This week'
               Date.today.at_beginning_of_week.beginning_of_day..Date.today.end_of_day
             when 'Last week'
               1.week.ago.at_beginning_of_week..1.week.ago.at_end_of_week
             when 'This month'
               Date.today.at_beginning_of_month..Date.today
             when 'Last month'
               1.month.ago.at_beginning_of_month..1.month.ago.at_end_of_month
           end
  end

  private

  def notify_before
    Airbrake.notify("Faucet new: #{self.name} from #{self.remote_ip}")
    sleep(2)
  end

  def register_account
    #sleep(2)
    referral_code, referrer = nil, self.referrer
    if self.refcode
        referral_code = ReferralCode.where(code: self.refcode).first
        referrer = referral_code.funded_by if referral_code
    end
    result = AccountRegistrator.new(nil, logger).register(self.name, self.owner_key, self.active_key, self.memo_key, referrer)
    if result[:error]
      error_message = result[:error]['message'] ? result[:error]['message'] : 'unknown backend error'
      errors.add(:base, error_message)
      Airbrake.notify("Faucet error: #{error_message}")
      sleep(2)
      return false
    end

    referral_code.claim(self.name) if referral_code

    Airbrake.notify("Faucet create: #{self.name} from #{self.remote_ip}")
    sleep(2)

    return true
  end


end
