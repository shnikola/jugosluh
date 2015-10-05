require "open-uri"
require "watir-webdriver"
require "watir-webdriver/wait"

class Downloader
  module Domains

    def get_file(url)
      case url
        when /mega(\.co)?\.nz/ then get_mega_nz(url)
        when /mediafire\.com/ then get_mediafire_com(url)
        when /senspace\.com/ then get_sendspace_com(url)
        when /divshare\.com/ then get_divshare_com(url)
        when /solidfiles\.com/ then get_solidfiles_com(url)
        when /zippyshare\.com/ then get_zippyshare_com(url)
        when /file-upload\.net/ then get_fileupload_net(url)
      end
    end

    def get_mediafire_com(url)
      watir_download(900) do
        browser.goto url
        sleep 5
        if browser.element(id: 'recaptcha_widget_div').present?
          browser.element(id: 'recaptcha-anchor-label').when_present.click
          sleep 5
          browser.element(class: 'dl_startlink').click
        end

        browser.element(class: 'download_link').when_present.click
      end
    end

    def get_zippyshare_com(url)
      watir_download do
        browser.goto url
        sleep 5 # Wait for href to be set up
        browser.element(id: 'dlbutton').when_present.click
      end
    end

    def get_solidfiles_com(url)
      noko = Nokogiri::HTML(open(url))
      button = noko.css("#ddl-btn").first
      file_name = noko.css("#file h1").first.text.strip
      direct_download(button["href"], file_name) if button
    end

    def get_sendspace_com(url)
      url.gsub("http://", "https://")
      noko = Nokogiri::HTML(open(url))
      button = noko.css("#download_button").first

      direct_download(button["href"]) if button
    end

    def get_divshare_com(url)
      noko = Nokogiri::HTML(open(url))
      s = noko.css("#fileInfoTextStat script").first.to_s
      download_url = s.match(%r['(http://[\w]+.divshare[^']*)'])[1]
      file_name = noko.css(".fileNameHeader").text.strip

      direct_download(download_url, file_name) if download_url.present?
    end

    def get_fileupload_net(url)
      watir_download do
        browser.goto url
        browser.element(title: 'download').when_present.click
      end
    end

    def get_mega_nz(url)
      watir_download(30) do
        browser.cookies.clear
        browser.goto url
        sleep 3
        browser.execute_script("window.onbeforeunload = null;") # Disable prompts
        browser.execute_script("window.localStorage.clear();")
        sleep 2

        return nil if browser.div(class: 'not-available-some-reason').present?

        browser.div(class: 'new-download-red-button').when_present.click

        # Check if error message appears
        3.times do
          sleep 10
          return nil if browser.div(class: 'temporary-error').present?
        end

        browser.div(class: 'download-complete-icon').wait_until_present(600)
      end
    end

    private

    def direct_download(url, file_name = nil)
      file_name ||= url.split("/").last
      file_path = "#{download_path}/#{file_name}"
      File.open(file_path, 'wb') do |fo|
        fo.write open(url).read
      end
      file_name
    end

    def watir_download(seconds_wait = 300)
      downloads_before = Dir.entries(download_path)

      yield

      seconds_wait.times do
        sleep 1
        new_files = Dir.entries(download_path) - downloads_before
        if new_files.count > 0 && new_files.none?{|d| d.start_with?(".com.google") || d.end_with?(".crdownload")}
          return new_files.last
        end
      end

      return nil
    rescue Watir::Wait::TimeoutError => e
      p "Timeout!"
      return nil
    end

    def browser
      @browser ||= Watir::Browser.new(:chrome, browser_profile)
    end

    def browser_profile
      caps = Selenium::WebDriver::Remote::Capabilities.chrome
      caps['chromeOptions'] = {
        "prefs" => {
          "download" => {
            "default_directory" => download_path,
            "directory_upgrade" => true,
            "extensions_to_open" => ""
          }
        }
      }

      # Use uBlock Origin
      switches = [
        '--load-extension=/Users/nikola/Library/Application Support/Google/Chrome/Default/Extensions/cjpalhdlnbpafiamejdnhcphjbkeiagm/1.1.1_0'
      ]

      {desired_capabilities: caps, switches: switches}
    end
  end
end
