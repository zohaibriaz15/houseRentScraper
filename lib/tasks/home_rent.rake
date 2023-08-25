require 'watir'
require 'webdrivers/chromedriver'
desc 'To scrape data from zameen'

task home_rent: :environment do
  base_url = 'https://www.zameen.com'
  links_array = []
  max_retries = 3
  retry_count = 0
  #  //*[contains(@class, "close_cross_big")]
  page = 1
  until page.blank?
    puts "=====================  Page number : #{page} ============================"
    url = "https://www.zameen.com/Rentals_Houses_Property/Lahore-1-#{page}.html?area_min=62.709552&area_max=313.54776000000004"
    # url = "https://www.zameen.com/Rentals/Lahore-1-#{page}.html?area_min=104.51592000000001&area_max=104.51592000000001"

    chrome_options = { args: ['--headless', '--disable-gpu', '--no-sandbox'] }
    browser = Watir::Browser.new :chrome, options: chrome_options

    begin
      browser.goto url
      browser.scroll.to :bottom

     #  puts "=========== Start Scraping #{browser.url} ============"
      if browser.element(xpath: '//span[contains(@class, "_5264eceb")]').present?
        message_element = browser.element(xpath: '//span[contains(@class, "_5264eceb")]')
        if message_element && (message_element.text == 'Sorry, there are no active properties matching your criteria.')
          puts 'No active properties matching criteria. Stopping scrapi browser = Watir::Browser.new :chrome
          ng.'
          break
        end
      end

      count = browser.element(xpath: '//*[@class="_357a9937"]').children.count
      page_number = browser.element(xpath: '//*[@class="d02376f9 _3ccbf7e4"]').text.strip 

      (0..count).each do |i|
        unless browser.element(xpath: "//*[@id='body-wrapper']/main/div[3]/div[2]/div[5]/div[1]/ul/li[#{i + 1}]/article/div[1]/a").present?
          next
        end

        link = browser.element(xpath: "//*[@id='body-wrapper']/main/div[3]/div[2]/div[5]/div[1]/ul/li[#{i + 1}]/article/div[1]/a").attributes[:href]
        link = base_url + link
        get_card_details(link, page_number, count)
        link = nil
      end
    rescue StandardError => e
      if retry_count < max_retries
        puts "Retrying (#{retry_count + 1}) due to: #{e.message}"
        retry_count += 1
        sleep 5  # Add a delay before retrying
        browser.quit
        retry
      else
        puts "Max retries reached. Cannot continue: #{e.message}"
      end
    end
    browser.quit
    page += 1
  end
end

private

def get_card_details(link, page_number, count)
  contact_element = []
  max_retries_2 = 3
  retry_count_2 = 0
  chrome_options = { args: ['--headless', '--disable-gpu', '--no-sandbox'] }
  browser = Watir::Browser.new :chrome, options: chrome_options
  begin
    browser.goto link
    # puts "=========== Start Scraping #{browser.url} ============"
    browser.scroll.to :bottom

    price_element = browser.element(xpath: '//span[contains(@class, "_812aa185")][@aria-label="Price"]')
    location_element = browser.element(xpath: '//span[contains(@class, "_812aa185")][@aria-label="Location"]')
    area_element = browser.element(xpath: '//span[contains(@class, "_812aa185")][@aria-label="Area"]')
    beds_element = browser.element(xpath: '//span[contains(@class, "_812aa185")][@aria-label="Beds"]')
    baths_element = browser.element(xpath: '//span[contains(@class, "_812aa185")][@aria-label="Baths"]')
    description_element = browser.element(xpath: '//span[contains(@class, "_2a806e1e")]')

    # Check if all required elements are present
    price = price_element.text.strip
    location = location_element.text.strip
    area = area_element.text.strip.split(" ").first.to_f
    bed = beds_element.text.strip.to_i
    bath = baths_element.text.strip.to_i
    description = description_element.text.strip
    
    price = price.include?("PKR") ? price.remove("PKR").strip : price
    if price.split(" ").last.eql?("Thousand")
      price = (price.split(" ").first.to_f * 1000).to_i
    elsif price.split(" ").last.eql?("Lakh")
      price = (price.split(" ").first.to_f * 100000).to_i
    elsif price.split(" ").last.eql?("Crore")
      price = (price.split(" ").first.to_f * 10000000).to_i
    end
    puts ":::::::::::::::::::::::::::::::::::"
    puts price
    puts ":::::::::::::::::::::::::::::::::::"

    # browser.element(xpath: "//*[@id='body-wrapper']/main/div[4]/div[1]/div[1]").click

    if browser.element(xpath: "//*[@class='_219b7e0a']").present?
      image_url = browser.element(xpath: "//*[@id='body-wrapper']/main/div[4]/div[1]/div[1]").element(tag_name: 'img').attribute('src')
      if image_url.nil?
      end
    end
    if HouseRent.exists?(price: price, location: location, area: area, bed: bed, bath: bath, description: description, image: image_url)
          puts 'Data already exists in the database'
    else
          scrapper = HouseRent.new(price: price, location: location, area: area, bed: bed, bath: bath, description: description, image: image_url)
          if scrapper.save
            status = 'Data saved successfully!'
            puts status
          else
            status = "Failed to save data: #{scrapper.errors.full_messages}"
            puts status
          end
    end
    # (0..image_count).each do |k|
    #   byebug
    #   unless browser.element(xpath: "//*[@class='image-gallery-thumbnails-container']").children[k].present?
    #     next
    #   end
    #   image_count = browser.element(xpath: "//*[@class='image-gallery-thumbnails-container']").children.count

    #   (0..image_count).each do |k|
    #     byebug
    #     unless browser.element(xpath: "//*[@class='image-gallery-thumbnails-container']").children[k].present?
    #       next
    #     end
  
    #     img = browser.element(xpath: "//*[@class='image-gallery-thumbnails-container']").children[k].element(tag_name: 'img').attribute_value('src')
    #     image << img
    #     img = browser.element(xpath: "//*[@class='image-gallery-thumbnails-container']").children[k].present?
  
    #   endxpath: ("//*[@class='image-gallery-thumbnails-container']").children[k].present?

    # end

    # if browser.element(xpath: '//button[contains(@class, "_5b77d672 da62f2ae _8a1d083b")][@aria-label="Call"][@type="button"]').present?
    #     browser.element(xpath: '//button[contains(@class, "_5b77d672 da62f2ae _8a1d083b")][@aria-label="Call"][@type="button"]').click
    #     contact_element << browser.element(xpath: '//td[contains(@class, "ee1fcc1c")]').present? 
    # end
    #   if Scrapper.exists?(price:, location:, area:, description:)
    #     puts 'Data already exists in the database'
    #   else
    #     scrapper = Scrapper.new(price:, location:, area:, description:)
    #     if scrapper.save
    #       status = 'Data saved successfully!'
    #       puts status
    #     else
    #       status = "Failed to save data: #{scrapper.errors.full_messages}"
    #       puts status
    #     end
    #   end


    # ... continue with your scraping loop ...
  rescue StandardError => e
    if retry_count_2 < max_retries_2
      puts "Retrying (#{retry_count_2 + 1}) due to: #{e.message}"
      retry_count_2 += 1
      browser.quit
      sleep 5  # Add a delay before retrying
      retry
    else
      puts "Max retries reached. Cannot continue: #{e.message}"
    end
  end
  card_count = count
  #   log = Log.new(page_number:, card_count:, link:, status:)
  #   puts 'Saved in logs' if log.save
  browser.quit
end

