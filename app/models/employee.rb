class Employee < ActiveRecord::Base
  acts_as_paranoid

  has_many :sent_scheduled_messages, dependent: :destroy

  validates :slack_username, presence: true
  validates_uniqueness_of :slack_username, conditions: -> { where(deleted_at: nil) }
  validates(
    :slack_username,
    format: {
      with: /\A[a-z_0-9.-]+\z/,
      message: "Slack usernames can only contain lowercase letters, numbers, underscores, hyphens, and periods."
    }
  )

  validates :started_on, presence: true
  validates :time_zone, presence: true

  def self.filter(params)
    results = self.all.where("slack_username like ?", "%#{params[:slack_username]}%")
    if params[:started_on].present?
      results.where(started_on: params[:started_on])
    end
    results
  end

  def validate_slack_username_in_org
    if !EmployeeFinder.new(slack_username).existing_employee?
      errors.add(
        :slack_username,
        "There is not a slack user with the username \"#{slack_username}\" in your organization."
      )
    end
  end

  def add_slack_user_id_to_employee
    user_id = EmployeeFinder.new(slack_username).slack_user_id
    if user_id.present?
      self.slack_user_id = user_id
    end
  end
end
