require "open-uri"
require "watir-webdriver"

class Downloader
  module Domains

    # Sorted by preference

    SHARE_SITE_DOMAINS = {
      "mega.co.nz" => :mega_nz,
      "mega.nz" => :mega_nz,
      "onedrive.live.com" => :one_drive,
      "skydrive.live.com" => :one_drive,
      "sdrv.ms" => :one_drive,
      "drive.google.com" => :google_drive,
      "file-upload.net" => :file_upload,
      "sendspace.com" => :sendspace,
      "solidfiles.com" => :solidfiles,
      "yadi.sk" => :yadi,
      "zippyshare.com" => :zippyshare,
      "mediafire.com" => :mediafire,
      "4shared.com" => :four_shared,
    }

    def get_file(url)
      SHARE_SITE_DOMAINS.each do |domain, name|
        return __send__(:"get_#{name}", url) if url.include?(domain)
      end
    end

    def get_file_upload(url)
      watir_download do
        browser.goto url
        browser.element(title: 'download').when_present.click
      end
    end

    def get_google_drive(url)
      watir_download do
        browser.goto url
        browser.element(class: 'drive-viewer-download-icon').when_present.click
        sleep 5
        if !browser.windows.last.current?
          browser.windows.last.use
          browser.element(id: 'uc-download-link').click
          sleep 5
          browser.windows.last.close
        end
      end
    end

    def get_mediafire(url)
      watir_download(900) do
        browser.goto url
        sleep 10
        if browser.element(id: 'recaptcha_widget_div').present?
          browser.element(id: 'recaptcha-anchor-label').when_present.click
          sleep 5
          browser.element(class: 'dl_startlink').click
        end

        browser.element(class: 'download_link').when_present.click
      end
    end

    def get_mega_nz(url)
      watir_download do
        browser.cookies.clear
        browser.goto url
        sleep 3
        browser.execute_script("window.onbeforeunload = null;") # Disable prompts
        sleep 2

        return nil if browser.div(class: 'download some-reason').present?

        browser.div(class: 'throught-browser').when_present.click
      end
    end

    def get_one_drive(url)
      watir_download(900) do
        browser.cookies.clear
        browser.goto url
        browser.div(class: 'CommandBar').wait_until_present
        sleep 2
        browser.div(class: 'CommandBar-mainArea').div(class: 'CommandBarItem').click
      end
    end

    def get_sendspace(url)
      url.gsub("http://", "https://")
      noko = Nokogiri::HTML(open(url))
      button = noko.css("#download_button").first

      direct_download(button["href"]) if button
    end

    def get_solidfiles(url)
      watir_download do
        browser.goto url
        browser.element(class: 'btn-primary').when_present.click
      end
    end

    def get_yadi(url)
      watir_download do
        browser.goto url
        browser.element(class: 'button_download').when_present.click
      end
    end

    def get_zippyshare(url)
      watir_download do
        browser.goto url
        sleep 5 # Wait for href to be set up
        browser.element(id: 'dlbutton').when_present.click
      end
    end

    def get_four_shared(url)
      four_shared_login
      direct_url = url.gsub(/4shared.com\/\w+\//, "4shared.com/get/")
      watir_download do
        browser.goto url # For some reason we need to visit this first
        sleep 5
        browser.goto direct_url
        browser.element(class: 'freeDownloadButton').when_present.click
      end
    end

    def four_shared_login
      return if @four_shared_logged_in
      browser.goto "https://www.4shared.com/web/login"
      browser.element(id: "tform").wait_until_present
      browser.element(id: "tform").text_field(name: "login").set("jugosluh@gmail.com")
      browser.element(id: "tform").text_field(name: "password").set("qwertz")
      browser.element(class: "loginButton").click
      sleep 5
      @four_shared_logged_in = true
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
      puts "Download Timeout!\n".red
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
        "--load-extension=#{adblock_path}"
      ]

      {desired_capabilities: caps, switches: switches}
    end

    def adblock_path
      path = '/Users/nikola/Library/Application Support/Google/Chrome/Default/Extensions/cjpalhdlnbpafiamejdnhcphjbkeiagm'
      version = `ls "#{path}"`.split("\n").last.strip
      path + "/" + version
    end
  end
end
