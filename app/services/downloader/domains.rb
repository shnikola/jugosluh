require "open-uri"
require "watir-webdriver"
require "watir-webdriver/wait"

class Downloader
  module Domains

    SHARE_SITE_DOMAINS = {
      "drive.google.com" => :google_drive,
      "file-upload.net" => :file_upload,
      "mega.co.nz" => :mega_nz,
      "mega.nz" => :mega_nz,
      "mediafire.com" => :mediafire,
      "onedrive.live.com" => :one_drive,
      "skydrive.live.com" => :one_drive,
      "sdrv.ms" => :one_drive,
      "sendspace.com" => :sendspace,
      "solidfiles.com" => :solidfiles,
      "yadi.sk" => :yadi,
      "zippyshare.com" => :zippyshare
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
        sleep 5
        if browser.element(id: 'recaptcha_widget_div').present?
          browser.element(id: 'recaptcha-anchor-label').when_present.click
          sleep 5
          browser.element(class: 'dl_startlink').click
        end

        browser.element(class: 'download_link').when_present.click
      end
    end

    def get_mega_nz(url)
      watir_download(30) do
        browser.cookies.clear
        browser.goto url
        sleep 3
        browser.execute_script("window.onbeforeunload = null;") # Disable prompts
        sleep 2

        return nil if browser.div(class: 'download some-reason').present?

        browser.div(class: 'throught-browser').when_present.click

        browser.div(class: 'status-txt green').wait_until_present(600)
      end
    end

    def get_one_drive(url)
      watir_download do
        browser.cookies.clear
        browser.goto url
        browser.div(class: 'CommandBar').wait_until_present
        sleep 2
        browser.divs(class: 'CommandBarItem-link').last.click
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
        sleep 5
        # Remove overlay
        browser.execute_script("document.getElementsByClassName('ui-dialog')[0].nextElementSibling.remove()")
        browser.element(id: 'ddl-text').when_present.click
      end
    end

    def get_yadi(url)
      watir_download do
        browser.goto url
        browser.element(class: 'js-download-button').when_present.click
      end
    end

    def get_zippyshare(url)
      watir_download do
        browser.goto url
        sleep 5 # Wait for href to be set up
        browser.element(id: 'dlbutton').when_present.click
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
        '--load-extension=/Users/nikola/Library/Application Support/Google/Chrome/Default/Extensions/cjpalhdlnbpafiamejdnhcphjbkeiagm/1.5.6_0'
      ]

      {desired_capabilities: caps, switches: switches}
    end
  end
end
