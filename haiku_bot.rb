#!/usr/bin/ruby
#███████╗██╗  ██╗███╗   ███╗ █████╗ ███████╗ ██████╗  ██████╗ ██╗     
#██╔════╝██║  ██║████╗ ████║██╔══██╗╚══███╔╝██╔═══██╗██╔═══██╗██║     
#███████╗███████║██╔████╔██║███████║  ███╔╝ ██║   ██║██║   ██║██║     
#╚════██║██╔══██║██║╚██╔╝██║██╔══██║ ███╔╝  ██║   ██║██║   ██║██║     
#███████║██║  ██║██║ ╚═╝ ██║██║  ██║███████╗╚██████╔╝╚██████╔╝███████╗
#╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝ ╚══════╝
#Written by Celina Yousief

require 'twitter'

#--------------------------------------------------------------------
def markov_it(original_text)
    markov_hash = Hash.new     

    for i in 0..original_text.length-1 do
        word = original_text[i]
        nxt = original_text[i+1]
        
        if markov_hash.include? word
            markov_hash[word] << nxt unless nxt.nil?
        else
            markov_hash[word] ||=[]
            markov_hash[word] << nxt unless nxt.nil?
        end

    end

    return markov_hash

end
#---------------------------------------------------------------------
def syllable_count(words)
    
    count = 0

    words.each do |word|
        tmp_count = 0
        tmp_count = tmp_count + word.scan(/[aeiouy]/i).size
        tmp_count = tmp_count - word.scan(/(?:[aeiouy][aeiouy][aeiouy]|([aeiouy][aeiouy]))/i).size
        tmp_count = tmp_count - word.scan(/(?:[^laeiouy]es\b|ed\b|([^laeiouy]e\b))/i).size
       
        tmp_count = 1 if word.length <= 3
        count = count + tmp_count
        #print "curr word = #{word} #{tmp_count} \n"
    end

    return count
end
#-----------------------------------------------------------------------
def generate(markoved_text,length,last_word = " ")

    curr_word = " "
    line_list = Array.new
    caps = Array.new
    
    markoved_text.each_key do |key|
        if key[0] =~ /[A-Z]/
            caps << key 
        end
    end
    
    if last_word == " "
        curr_word = caps.sample
    else
        curr_word = markoved_text[last_word].sample
    end

    line_list << curr_word

    if syllable_count(line_list) > length
        generate(markoved_text, length, last_word) 
    elsif syllable_count(line_list) == length
        return line_list
    else
        while 1
            line_list << markoved_text[curr_word].sample

            if syllable_count(line_list) > length
                break
            elsif syllable_count(line_list) == length
                return line_list
            else
                curr_word = line_list.last
            end
        end
    end


    return generate(markoved_text, length, last_word)

end
#-----------------------------------------------------------------------
def get_text

    file = File.open("nick.txt", "r")
    raw_text = file.read
    file.close
    out_array = raw_text.gsub(/[^a-zA-Z'\s]/,'').split

    return out_array

end
#----------------------------------------------------------------------
def haiku_gen

    og_text = get_text
    markoved_text = markov_it(og_text)

    line1 = generate(markoved_text,5)
    last = line1[-1]
    out_line1 = line1.join(" ")

    line2 = generate(markoved_text,7,last)
    last = line2[-1]
    out_line2 = line2.join(" ").capitalize

    line3 = generate(markoved_text,5,last)
    out_line3 = line3.join(" ").capitalize

    haiku = out_line1 + "\n" + out_line2 + "\n" + out_line3
    puts haiku

    return haiku




end
#---------------------------------------------------------------------

def post(haiku)
    
    client = Twitter::REST::Client.new do |config|
        config.consumer_key = ""
        config.consumer_secret = ""
        config.access_token = ""
        config.access_token_secret = ""
    end
    
    puts "Would you like to post?"
    client.update(haiku) if gets.chomp == 'y'

    return 0 
    
end

final_haiku=haiku_gen
post(final_haiku)

