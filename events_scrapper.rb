#!/usr/bin/ruby
require 'json'
require 'restclient'
require 'pry'
require 'nokogiri'

class EventsFinder

    attr_reader   :events
    attr_accessor :max_number_number, :output_file, :print_output
    DEFAULT_MAX_NUMBER_PAGES = 10
    DEFAULT_OUTPUT_FILE      = 'output.json'
    DEFAULT_PRINT_OUTPUT     = 1 #print by default

    # Initialise instance variables, default as necessary
    def initialize(max_number_number, output_file, print_output)
        @events = []
        
        # If arguments are not provided, default them
        if max_number_number.nil?
            @max_number_number = DEFAULT_MAX_NUMBER_PAGES
        else
            @max_number_number = max_number_number.to_i
        end
        
        if output_file.nil?
            @output_file = DEFAULT_OUTPUT_FILE
        else
            @output_file = output_file
        end
        
        if print_output.nil?
            @print_output = DEFAULT_PRINT_OUTPUT
        else
            @print_output = print_output.to_i
        end
    end

    # Main function, processes all events for all pages, and convert to JSON
    def run
        process_pages
        to_json
    end
  
    # Process all pages
    def process_pages
        for page_number in 1..@max_number_number
           process_page(page_number)
        end
    end
  
    # Process one page
    def process_page(page_number)
        puts "Processing page #{page_number}/#{max_number_number}"
        listing_outers = get_listing_outers(page_number)
        listing_outers.each do |outer|
            process_outer(outer)
        end
    end

    # Process an event
    def process_outer(outer)
        # Exclude events with comedy in their name. 
        # Not great, this will not show a Divine Comedy gig :(
        unless outer.css('.ListingAct h3').text =~ /comedy/i
            event = {}
            event[:name]  = outer.css('.ListingAct h3').text
            event[:city]  = outer.css('.ListingAct blockquote .venuetown').text
            event[:venue] = outer.css('.ListingAct blockquote .venuename').text
            # The currency symbol does not display nicely, needs some formatting
            event[:date]  = outer.css('.ListingAct blockquote p').text
            event[:price] = outer.css('.ListingPrices .searchResultsPrice strong').text
            event[:link]  = outer.css('.ListingAct h3 a')[0]['href']
            @events << event
        end
    end
  
    # Return the events for a page
    def get_listing_outers(page_number)
        current_page = "http://www.wegottickets.com/searchresults/page/#{page_number}/all"
        html_page = Nokogiri::HTML(RestClient.get(current_page))

        ticket_listing = html_page.css('.TicketListing')
        return ticket_listing.css('.ListingOuter')
    end

    # Write to JSON. Print if needed
    def to_json
        json_output = @events.to_json
        
        if @print_output == 1
            puts json_output
        end
        
        File.write(@output_file, json_output)
        exit 0
    end
    
end

s = EventsFinder.new(ARGV[0], ARGV[1], ARGV[2])
s.run