class SystemNotifier < ActionMailer::Base
  def alert(exception, object)
    @subject    = "[UNICEF] Alert (#{exception.class}) #{exception.message.inspect}"
    @body       = { :exception => exception, :backtrace => sanitize_backtrace(exception.backtrace), :object => object }
    @recipients = "errors@winstondesign.se"
    @from       = 'no.reply@winstondesign.se'
  end
  
  private

    def sanitize_backtrace(trace)
      re = Regexp.new(/^#{Regexp.escape(rails_root)}/)
      trace.map { |line| Pathname.new(line.gsub(re, "[RAILS_ROOT]")).cleanpath.to_s }
    end

    def rails_root
      return @rails_root if @rails_root
      @rails_root = Pathname.new(RAILS_ROOT).cleanpath.to_s
    end
end