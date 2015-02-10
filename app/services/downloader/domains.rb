require "open-uri"
require "watir-webdriver"
require "watir-webdriver/wait"

class Downloader
  module Domains
    
    def get_mediafire_com(url)
      noko = Nokogiri::HTML(open(url))
      noko.css("script").find do |s|
        match = s.to_s.match(%r["(http://download\d+.mediafire[^"]*)"])
        if match
          download_url = match[1] and break
        end
      end
      
      download
    end
  
    def get_sendspace_com(url)
      url.gsub("http://", "https://")
      noko = Nokogiri::HTML(open(url))
      s = noko.css("#download_button").first
      return s["href"] if s
    end
  
    def get_divshare_com(url)
      noko = Nokogiri::HTML(open(url))
      s = noko.css("#fileInfoTextStat script").first.to_s
      download_url = s.match(%r['(http://[\w]+.divshare[^']*)'])
      return download_url[1] if download_url.present?
    end
    
    def get_mega_co_nz(url)
      downloads_before = Dir.entries(download_path)
      browser.goto url
      
      browser.div(class: 'new-download-red-button').when_present.click
      sleep 5
      
      if browser.div(class: 'temporary-error').present?
        browser.execute_script("window.onbeforeunload = null") # Disable prompts
        return nil
      end
      
      browser.div(class: 'download-complete-icon').wait_until_present(600)
      
      30.times do
        sleep 1
        new_files = Dir.entries(download_path) - downloads_before
        if new_files.count > 0 && new_files.none?{|d| d.start_with?(".com.google") || d.end_with?(".crdownload")}
          return new_files.last
        end
      end
      
      return nil
    rescue Watir::Wait::TimeoutError => e
      p "Timeout!"
      browser.execute_script("window.onbeforeunload = null") # Disable prompts
      return nil
    end
    
    def direct_download(url)
      file_path = "#{download_path}/#{Time.now}"
      File.open(file_path, 'wb') do |fo|
        fo.write open(url).read
      end
      file_path
    end
    
    private
  
    def browser
      @browser ||= Watir::Browser.new(:chrome, desired_capabilities: browser_profile)
    end
  
    def browser_profile
      prefs = {"download" => {"default_directory" => download_path, "directory_upgrade" => true, "extensions_to_open" => ""}}
      caps = Selenium::WebDriver::Remote::Capabilities.chrome
      caps['chromeOptions'] = {'prefs' => prefs}
      caps
    end
  end
end