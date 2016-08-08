class Food
	attr_accessor :name, :description, :price, :calories, :fat, :carbs, :type

	def initialize(name, description, price, calories, fat, carbs, type)
		@name = name
		@description = description
		@price = price
		@calories = calories
		@fat = fat
		@carbs = carbs
		@type = type
	end

	def full_details
		puts "\n\nItem: #{@name}"
		puts "Description: #{@description}"
		puts "Price: $#{'%.02f' % @price}"
		puts "Nutrition: #{@calories} cal, #{@fat}g fat, #{@carbs}g carbs"
	end
end

@main = [
	{name: "Chili Dog", description: "A little tasty", price: 4.00, calories: 550, fat: 20, carbs: 38, type: "main"},
	{name: "Tikka Masala", description: "Indian-ish", price: 6.00, calories: 350, fat: 16, carbs: 30, type: "main"},
	{name: "Fried Chicken", description: "The best!", price: 5.00, calories: 600, fat: 20, carbs: 12, type: "main"}
]
@side = [
	{name: "A block of cheese", description: "Too much cheese for one", price: 7.00, calories: 1000, fat: 75, carbs: 20, type: "side"},
	{name: "Potato Chips", description: "Greasey and salty!", price: 2.50, calories: 200, fat: 12, carbs: 32, type: "side"},
	{name: "Brussel Sprouts", description: "Almost like vegetables", price: 3.50, calories: 150, fat: 10, carbs: 5, type: "side"}
]

@instances_hash = {}
@order = []
@wallet = 0

def instances(food_array)
	food_array.each do |i|
		new_food = (Food.new(i[:name], i[:description], i[:price], i[:calories], i[:fat], i[:carbs], i[:type]))
		@instances_hash[(i[:name])] = new_food
	end
end

def options(food_array)
	puts "\n\nChoose an item to view details or type 'back'"
	x = 1
	food_array.each do |key|
		puts "#{x}. #{key[:name]}"
		x += 1
	end
	puts "\n"
	if food_array == @main && @order.length > 0 && @order[0].type == "main"
		puts "You have already selected a main dish."
		puts "Choosing another will replace your #{@order[0].name}."
		details(food_array)
	else
		details(food_array)
	end
	
end

def identify(food_array)
	while true
	choice = gets.strip.downcase.gsub(/\s+/, "")
		if choice == "back"
			menu
		elsif choice =~ /^[0-9]+\.?.*$/ && choice.to_i <= food_array.length && choice.to_i > 0
			item_num = (choice.to_i - 1).to_i
			item = @instances_hash[(food_array[item_num][:name])]
			break food_array, item_num, item
		elsif food_array.any? { |hash| hash[:name].downcase.gsub(/\s+/, "").include?(choice)} && choice.length >= 4
			item_num = (food_array.find_index { |hash| hash[:name].downcase.gsub(/\s+/, "").include?(choice)}).to_i
			item = @instances_hash[(food_array[item_num][:name])]
			break food_array, item_num, item
		else 
			puts "Sorry. I missed that? Can you say it again?"
		end
	end
end

def details(food_array)
	food_array, item_num, item = identify(food_array)
	puts item.full_details
	while true
		puts "\n\norder --> Add to current order"
		puts "back --> Return to menu items"
		nav = gets.strip.downcase
		case nav
			when "back"
				options(food_array)			
			when "order"
				if @wallet <= (wallet + item.price)
					puts "\n\nSorry. You don't have enough money for that item."
					puts "Check your order summary and try again."
					options(food_array)
				elsif @order.length > 0 && item.type == "main" && @order[0].type == "main"
					old = @order.shift.name
					@order.unshift(item)
					puts "\n\n#{old} removed. #{item.name} added to order."
					menu
				elsif item.type == "main"
					@order.unshift(item)
					puts "\n\n#{item.name} added to order."
					menu
				else
					@order.push(item)
					puts "\n\n#{item.name} added to order."
					options(food_array)
				end
			else
				error
		end
	end
end


def intro
	puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n"
	puts "WELCOME TO THE CAFETERIA!\n\n"
	puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n"
	puts "How much money is in your wallet?\n\n"
	while true
	amount = gets.strip.to_f
		if amount < 10.00
			puts "Oh, looks like our system is crashing..."
			puts "Goodbye!\n\n"
			quit
		elsif amount >= 10.00
			puts "Looks like our system is working just fine. Enjoy!"
			@wallet = amount
			menu
		else
			puts "How much did you say?"
		end
	end
end

def menu
	puts "\n\nmain --> View main dish options"
	puts "side --> View side dish options"
	puts "summ --> View order summary"
	puts "wallet --> Check your wallet"
	puts "order --> Get your food!"
	puts "quit --> leave!"
	while true
		nav = gets.strip.downcase
		case nav
			when "main"
				options(@main)
			when "side"
				options(@side)
			when "summ"
				summary
			when "wallet"
				wallet_check
			when "order"
				order
			when "quit"
				quit
			else
				error
		end
	end
end

def summary
	items = ""
	@order.each do |item|
		items += item.name.to_s + (", ")
	end
	items = items.chomp(", ")
	total_price = 0
	@order.each do |item|
		total_price += item.price.to_f
	end
	total_cal = 0
	@order.each do |item|
		total_cal += item.calories.to_i
	end
	total_fat = 0
	@order.each do |item|
		total_fat += item.fat.to_i
	end
	total_carbs = 0
	@order.each do |item|
		total_carbs += item.carbs.to_i
	end
	puts "\n\nOrder Summary"
	puts "Items: #{items}"
	puts "Total price: $#{'%.02f' % total_price}"
	puts "Total calories: #{total_cal}"
	puts "Total fat: #{total_fat}g"
	puts "Total carbs: #{total_carbs}g"
	puts "\n\n Type 'edit' to remove items or 'back' to return to menu"
	while true
		nav = gets.strip.downcase
		case nav
			when "back"
				menu
			when "edit"
				remove
			else
				error
		end
	end
end

def remove
	puts "\n\nCurrent Order"
	puts "Select item to remove or type 'back'"
	x = 1
	@order.each do |ob|
		puts "#{x}. #{ob.name} #{'%.02f' % ob.price}"
		x += 1
	end
	while true
	choice = gets.strip.downcase.gsub(/\s+/, "")
		if choice == "back"
			summary
		elsif choice =~ /^[0-9]+\.?.*$/ && choice.to_i <= @order.length && choice.to_i > 0
			item_num = (choice.to_i - 1).to_i
			break item_num
		elsif @order.any? { |ob| ob.name.downcase.gsub(/\s+/, "").include?(choice)} && choice.length >= 4
			item_num = (@order.find_index { |ob| ob.name.downcase.gsub(/\s+/, "").include?(choice)}).to_i
			break item_num
		else 
			puts "Sorry. I missed that? Can you say it again?"
		end
	end
	puts "#{@order[item_num].name} has been removed from the order."
	@order.delete_at(item_num)
	remove

end


def wallet
	total_price = 0
	@order.each { |item| total_price += item.price.to_f }
	total_price
end

def wallet_check
	wallet
	puts "\n\nYou have $#{'%.02f' % @wallet} left in your wallet."
	puts "Your current order totals $#{'%.02f' % wallet}.\n\n"
	puts "press 'enter' to return to the menu"
	gets
	menu
end

def order
	wallet
	puts "\n\nYou have $#{'%.02f' % @wallet} left in your wallet."
	puts "Your current order totals $#{'%.02f' % wallet}\n\n"
	if @wallet <= wallet
		puts "\n\nSorry. You don't have enough money."
		puts "Press 'enter' to return to menu."
		gets
		menu
	end
	puts "\n\nType 'order' to complete if your order or 'back' to return to menu."
	while true
		nav = gets.strip.downcase
		if nav == "order" && (@wallet - wallet) > 0
			@wallet = @wallet - wallet
			puts "DELICIOUS!!!"
			puts "You still have $#{'%.02f' % @wallet}. Press 'enter' to return to menu and buy more stuff!"
			@order = []
			gets
			menu
		elsif nav == "order"
			puts "DELICIOUS!!!"
			puts "Unfortunately, you are out of money. Goodbye!"
			quit
		elsif nav == "back"
			menu
		else
			error
		end
	end
end


def error
	puts "\n\nInvalid entry. Please refer to options and try again."
end

def quit
	exit(0)
end

instances(@main)
instances(@side)

intro