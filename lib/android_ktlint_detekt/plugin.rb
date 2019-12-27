module Danger
  # This library allows you to send messages via Danger for detekt and ktlint issues
  #
  # @example Ensure people are well warned about merging on Mondays
  #
  #          android_ktlint_detekt.ktlint_report_file = path_to_ktlint_xml
  #          android_ktlint_detekt.detekt_report_file = path_to_detekt_xml
  #          android_ktlint_detekt.report(inline_mode: true)
  #
  # @see  Juan Manuel Pereira/danger-android_ktlint_detekt
  # @tags kotlin,android,ktlint,detekt
  #
  class DangerAndroidKtlintDetekt < Plugin
    # A getter for `detekt_report_file`.
    # Returns default path if not set
    # @return [String]
    attr_accessor :ktlint_report_file

    def ktlint_report_file
      return @ktlint_report_file || "beacon-ui/build/reports/ktlint/ktlintMainSourceSetCheck.xml"
    end

    # A getter for `detekt_report_file`.
    # Returns default path if not set
    # @return [String]
    attr_accessor :detekt_report_file

    def detekt_report_file
      return @detekt_report_file || "beacon-ui/build/reports/detekt.xml"
    end

    ### PUBLIC METHODS

    # Method to report ktlint + detekt messages
    # @return  [void]
    def report
      ktlint_report_file_complete = "#{Dir.pwd}/#{ktlint_report_file}"
      detekt_report_file_complete= "#{Dir.pwd}/#{detekt_report_file}"

      check_file_integrity(ktlint_report_file_complete)
      check_file_integrity(detekt_report_file_complete)

      ktlint_issues = read_issues_from_report(ktlint_report_file)
      detekt_issues = read_issues_from_report(detekt_report_file)

      report_issues(ktlint_issues)
      report_issues(detekt_issues)
    end

    private

    def check_file_integrity(file)
      raise "No XML file provided. Please provide a file route." if file.empty?
      raise "No checkstyle file was found at #{file}" unless File.exist? file
    end

    def read_issues_from_report(report_file)
      file = File.open(report_file)

      require "oga"
      report = Oga.parse_xml(file)

      report.xpath("//file")
    end

    def report_issues(issues)
      target_files = (git.modified_files - git.deleted_files) + git.added_files
      dir = "#{Dir.pwd}/"

      issues.each do |file|
        location = file.get("name")
        filename = location.gsub(dir, "")

        next unless (target_files.include? filename)
        file.xpath("error").each do |error|
          severity = error.get("severity")
          message = error.get("message")
          line = error.get("line")

          if severity == "error" || severity == "warning"
            warn(message, file: filename, line: line)
          else
            message(message, file: filename, line: line)
          end
        end
      end
    end
  end
end
