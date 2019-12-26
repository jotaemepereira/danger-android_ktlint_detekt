module Danger
  # This is your plugin class. Any attributes or methods you expose here will
  # be available from within your Dangerfile.
  #
  # To be published on the Danger plugins site, you will need to have
  # the public interface documented. Danger uses [YARD](http://yardoc.org/)
  # for generating documentation from your plugin source, and you can verify
  # by running `danger plugins lint` or `bundle exec rake spec`.
  #
  # You should replace these comments with a public description of your library.
  #
  # @example Ensure people are well warned about merging on Mondays
  #
  #          my_plugin.warn_on_mondays
  #
  # @see  Juan Manuel Pereira/danger-android_ktlint_detekt
  # @tags monday, weekends, time, rattata
  #
  class DangerAndroidKtlintDetekt < Plugin


    # A getter for `detekt_report_file`.
    # Returns default path if not set
    # @return [String]
    attr_accessor :ktlint_report_file

    def ktlint_report_file
      return @ktlint_report_file || 'app/build/reports/lint/lint-result.xml'
    end

    # A getter for `detekt_report_file`.
    # Returns default path if not set
    # @return [String]
    attr_accessor :detekt_report_file

    def detekt_report_file
      return @detekt_report_file || 'app/build/reports/lint/lint-result.xml'
    end

    ### PUBLIC METHODS

    # Method to report ktlint messages
    def report(inline_mode: false)
      check_file_integrity(ktlint_report_file)
      check_file_integrity(detekt_report_file)

      ktlint_issues = read_issues_from_report(ktlint_report_file)
      detekt_issues = read_issues_from_report(detekt_report_file)

      report_issues(ktlint_issues)
      report_issues(detekt_issues)
    end

    ### PRIVATE METHODS
    private

    def check_file_integrity(file)
      raise "No XML file provided. Please provide a file route." if file.empty?
      raise "No checkstyle file was found at #{file}" unless File.exist? file
    end

    def read_issues_from_report(report_file)
      file = File.open(report_file)

      require 'oga'
      report = Oga.parse_xml(file)

      report.xpath('//file')
    end

    def report_issues(issues)
      dir = "#{Dir.pwd}/"

      issues.each do |file|
        location = file.get('name')
        filename = location.gsub(dir, "")

        file.xpath('error').each do |error|
          severity = error.get('severity')
          message = error.get('message')
          line = error.get('line')

          if severity == 'error'
            send('fail', message, file: filename, line: line)
          elsif severity == 'warning'
            send('warn', message, file: filename, line: line)
          else
            send('message', message, file: filename, line: line)
          end

        end
      end
    end

    # def message_for_issues(issues)
    #   message = ""
    #
    #   message << parse_results(issues, level) unless filtered.empty?
    #
    #   message
    # end

    # def parse_results(results, heading)
    #   target_files = (git.modified_files - git.deleted_files) + git.added_files
    #   dir = "#{Dir.pwd}/"
    #   count = 0
    #   message = ""
    #
    #   results.each do |r|
    #     location = r.xpath('location').first
    #     filename = location.get('file').gsub(dir, "")
    #     next unless !filtering || (target_files.include? filename)
    #     line = location.get('line') || 'N/A'
    #     reason = r.get('message')
    #     count = count + 1
    #     message << "`#{filename}` | #{line} | #{reason} \n"
    #   end
    #   if count != 0
    #     header = "#### #{heading} (#{count})\n\n"
    #     header << "| File | Line | Reason |\n"
    #     header << "| ---- | ---- | ------ |\n"
    #     message = header + message
    #   end
    #
    #   message
    # end

    # Send inline comment with danger's warn or fail method
    #
    # @return [void]
    # def send_inline_comment (issues)
    #   target_files = (git.modified_files - git.deleted_files) + git.added_files
    #   dir = "#{Dir.pwd}/"
    #   SEVERITY_LEVELS.reverse.each do |level|
    #     filtered = issues.select{|issue| issue.get("severity") == level}
    #     next if filtered.empty?
    #     filtered.each do |r|
    #       location = r.xpath('location').first
    #       filename = location.get('file').gsub(dir, "")
    #       next unless !filtering || (target_files.include? filename)
    #       line = (location.get('line') || "0").to_i
    #       send(level === "Warning" ? "warn" : "fail", r.get('message'), file: filename, line: line)
    #     end
    #   end
    # end

  end
end
