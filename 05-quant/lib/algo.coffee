###*
# This is heart of our trading bot. Function below is called
# for every candle from the history. As a result an order is
# expected, however not mandatory.
#
# Our dummy algorithm works as following:
#  - in 1/3 of cases we sell $1
#  - in 1/3 of cases we buy $1
#  - in 1/3 of cases we do nothing
#
# @param {float}   [price]   Average (weighted) price
# @param {Object}  [candle]  Candle data with `time`, `open`, `high`, `low`, `close`,
#                            `volume` values for given `time` interval.
# @param {Object}  [account] Your account information. It has _realtime_ balance of USD and BTC
# @returns {object}          An order to be executed, can be null
###

current_price = 0
average = 0;
starting_amount = 0

# Calculate the average for last 3 days
no_of_days = 3
average_prices = [];
get_average = (price) ->
	avg = 0;
	if average_prices.length >= no_of_days
		avg += val for val, i in average_prices
		average_prices = average_prices[1...no_of_days]

	average_prices.push(price);
	return avg/no_of_days;


exports.tick = (price, candle, account) ->
	if starting_amount == 0 then starting_amount = account.USD

	# Selling
	# Get avegare of last three days
	avg = get_average price

	# Continue if below conditions are met
	if account.USD > 0 && avg != 0 and price < avg
		diff = avg - price

		# Set several conditions for the diff
		switch true
			when diff > 0 && diff < 1
				# Sell at 10% price or for the remaining balance
				return sell: if (price*10/100) > account.USD then account.USD else (price*10/100)

			when diff > 1 && diff < 2
				# Sell at 20% price or for the remaining balance
				return sell: if (price*20/100) > account.USD then account.USD else (price*20/100)

			when diff > 2 && diff < 3
				# Sell at 30% price or for the remaining balance
				return sell: if (price*30/100) > account.USD then account.USD else (price*30/100)

			when diff > 3 && diff < 5
				# Sell at 35% price or for the remaining balance
				return sell: if (price*35/100) > account.USD then account.USD else (price*35/100)

			when diff > 5
				# Sell at 50% price or for the remaining balance
				return sell: if (price*50/100) > account.USD then account.USD else (price*50/100)


	# Buying
	if account.BTC > 0
		avg_price = (starting_amount - account.USD) / account.BTC;

		# Set several conditions for the diff
		if price >= avg_price
			diff = price - avg_price
			switch true
				when diff > 0 && diff < 1
					# Buy at 10% price or for the remaining balance
					return buy: if (price*10/100) < price*account.BTC then price*10/100 else (price*account.BTC-1)

				when diff > 1 && diff < 2
					# Buy at 20% price or for the remaining balance
					return buy: if (price*20/100) < price*account.BTC then price*20/100 else (price*account.BTC-1)

				when diff > 2 && diff < 3
					# Buy at 25% price or for the remaining balance
					return buy: if (price*25/100) < price*account.BTC then price*25/100 else (price*account.BTC-1)

				when diff > 3 && diff < 5
					# Buy at full price or for the remaining balance
					return buy: if price < price*account.BTC then price else (price*account.BTC-1)

				when diff > 5
					# Buy at 1.5 times the price or for the remaining balance
					return buy: if (price*1.5) < price*account.BTC then price*1.5 else (price*account.BTC-1)

	# Dont do anything if none of the conditions are met
	return null
