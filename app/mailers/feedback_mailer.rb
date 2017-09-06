class FeedbackMailer < ActionMailer::Base
  def submit_feedback(params, ip)
    @mailer_parser = FeedbackMailerParser.new(params, ip)

    mail(to: Settings.EMAIL_TO,
         subject: 'Feedback from SearchWorks',
         from: 'feedback@searchworks.stanford.edu',
         reply_to: Settings.EMAIL_TO,
         template_name: @mailer_parser.type)
  end

  def submit_wrong_book_cover(params, ip)
    @url = params[:url]
    @ip = ip
    mail(to: Settings.EMAIL_TO,
         subject: 'Quick Report Wrong Book Cover from SearchWorks',
         from: 'feedback@searchworks.stanford.edu',
         reply_to: Settings.EMAIL_TO)
  end
end
