# frozen_string_literal: true

class FeedbackMailer < ApplicationMailer
  def submit_feedback(params, ip)
    @mailer_parser = FeedbackMailerParser.new(params, ip)

    mail(to: Settings.EMAIL_TO.FEEDBACK,
         subject: 'Feedback from SearchWorks',
         from: 'feedback@searchworks.stanford.edu',
         reply_to: Settings.EMAIL_TO.FEEDBACK)
  end

  def submit_connection(params, ip)
    @mailer_parser = FeedbackMailerParser.new(params, ip)

    mail(to: Settings.EMAIL_TO.CONNECTION,
         subject: "Connection problem: #{@mailer_parser.resource_name}",
         from: @mailer_parser.email,
         reply_to: Settings.EMAIL_TO.CONNECTION)
  end

  def submit_wrong_book_cover(params, ip)
    @url = params[:url]
    @ip = ip
    mail(to: Settings.EMAIL_TO.FEEDBACK,
         subject: 'Quick Report Wrong Book Cover from SearchWorks',
         from: 'feedback@searchworks.stanford.edu',
         reply_to: Settings.EMAIL_TO.FEEDBACK)
  end
end
