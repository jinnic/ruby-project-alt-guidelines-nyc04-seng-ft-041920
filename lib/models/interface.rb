 class Interface 
    #< ActiveRecord::Base
#     validate :watering_date_cannot_be_in_the_future
#     def watering_date_cannot_be_in_the_future
#         errors.add(:watering_date, "can't be in the future") if
#           !watering_date.blank? and watering_date < Date.today
#     end
    

    attr_accessor :prompt
    def initialize
        @prompt = TTY::Prompt.new
    end
    
    def greet
        # puts 'Thinking of florishing your house with some green but not sure to keep it alive?'
        puts 'Welcome to Green Fairy 🧚'
        puts 'The best scheduler for watering your plants!'
        puts 'Let\'s get you started'
        puts 'Tell us your username 📛'
    end
    
    def run
        
        # @prompt.ask('date?') do |q|
        #      q.validate  /^((0[1-9])|(1[0-2]))\/(\d{2})$/
        #  end

        greet
        username_input = gets.chomp.downcase
        self.loading(30, "~", 0.1)
        user = User.find_create_user(username_input)
        main_menu(user)
    end

    def main_menu(user)
        user = user
        menu = ["My plants","ADD NEW PLANT","Delete My Account","Exit"]
        menu_selection = @prompt.select("What would you like to do?",menu)
            
            case menu_selection
            when "My plants"
                my_plant(user)
            when "ADD NEW PLANT"
                #find plant
                #add plant to myplant
                add_plant(user)
            when "Delete My Account"
                answer = @prompt.yes?("Are you sure?")
                goodbye
                user.delete
            when "Exit"
                self.goodbye
                p "something good bye"
                
            end
            # main_menu(user)
    end
    def my_plant(user)
        # binding.pry
        main_my_plants_table(user)
        if user.all_plants.blank?
            puts "Looks like you don't have any plants"
            answer = @prompt.yes?("Do you want to add plants?")
            add_plant(user)
        else
            plant_num = user.num_of_plants
            nicknames = user.my_plants.nicknames
            nickname = @prompt.select("Which plant do you want to water?", nicknames)
            selected_plant = user.find_plant_nickname(nickname)
            update_plant(selected_plant,user)
        end
    end

    def update_plant(selected_plant, user)
        menu = ["update water status","change watering cycle","back"]
        menu_selection = @prompt.select("options",menu)
        case menu_selection
        when "update water status"
            #$$$$$$$$need to check if it is future date. not possible
            date =  @prompt.ask("when did you water #{selected_plant.nickname}? (in mm/dd)", convert: :date)
            selected_plant.update_waterdate_status(date)
            # selected_plant.update(watering_date: date)
            # selected_plant.update(watered: true)
            # puts selected_plant
            # binding.pry
            #==============================>show table
            main_menu(user)
        when "change watering cycle"
            #plant.water_cycle = new_cycle
            days =  @prompt.ask("Change #{selected_plant.nickname}'s watering cycle to every 'x' days?", convert: :int)
            selected_plant.change_watercycle(days)
            # selected_plant.update(water_cycle: days)
            # puts selected_plant
            # binding.pry
            #==============================>show table
            main_menu(user)
        when "back"
            main_menu(user)
        end
    end

    def add_plant(user)
        user = user
        new_plant = @prompt.ask("Enter a plant species you want to add: (ex: Lily, Mint, Spider plant etc.)?")
        # puts "Enter a plant species you want to add: (ex: Lily, Mint, Spider plant etc.)"
        # plant_name = gets.chomp.downcase
        new_plant = PlantList.check_plant(new_plant)
        nickname = @prompt.ask("Give a nickname to #{new_plant.species}:")
        # binding.pry
        MyPlant.add_plant(nickname, user, new_plant)
        main_menu(user)
    end
    
    def loading(length, sym, timing)
        length.times do |a|
          print sym
          sleep(timing)
        end
        puts ""
    end

    def goodbye
        length = 30
        sym = "*"
        timing =0.1

        length.times do |a|
          print sym
          sleep(timing)
        end
        puts "bye bye"
    end

    def main_my_plants_table(user)
        rows = user.all_plants.map.with_index{|plant, index| my_plant_list(plant,index+1)}
        headings = default_table_headings
        table = create_display_table("My Plants", headings, rows)
        table.style = default_table_style
        table.align_column(0, :left)
        puts table
    end

    # Default table setup and settings
    def create_display_table(title, headings, rows)
        Terminal::Table.new :title=> title, :headings => headings, :rows => rows
    end

    def default_table_style
        {:alignment => :center, :padding_left => 2, :border_x => "=", :border_i => "x"}
    end

    def default_table_headings
        MyPlant.heading
    end

    def my_plant_list(my_plant, index)
        my_plant.show_each_plant_spec(index)
    end

    

end