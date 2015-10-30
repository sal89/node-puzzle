fs = require 'fs'

GEO_FIELD_MIN = 0
GEO_FIELD_MAX = 1
GEO_FIELD_COUNTRY = 2

exports.ip2long = (ip) ->
  ip = ip.split '.', 4
  return +ip[0] * 16777216 + +ip[1] * 65536 + +ip[2] * 256 + +ip[3]


gindex        = []
gindex_sorted = []
subarrays     = 400
exports.load = ->

	data = fs.readFileSync "#{__dirname}/../data/geo.txt", 'utf8'
	data = data.toString().split '\n'

	for line in data when line
    line = line.split '\t'
    # GEO_FIELD_MIN, GEO_FIELD_MAX, GEO_FIELD_COUNTRY
    gindex.push [+line[0], +line[1], line[3]]

  # Sort the data by min IP
  gindex.sort (a,b) -> return parseInt(a[0],10) - parseInt(b[0],10);

  # Break the array into (subarrays) sub arrays
  incr = gindex.length / subarrays
  for j in [0 ... subarrays]
  	sliced = gindex[incr*j...incr*(j+1)]

  	# Clone the array
  	_sliced = sliced.slice(0)

  	# Sort the array by max IP
  	_sliced.sort (a,b) -> return parseInt(a[1],10) - parseInt(b[1],10);

  	# Now push the sliced array into the main array with min & max as keys
  	gindex_sorted.push 'min': sliced[0][0], 'max': _sliced[_sliced.length-1][1], 'data': sliced


normalize = (row) -> country: row[GEO_FIELD_COUNTRY]

exports.lookup = (ip) ->
	return -1 unless ip

	find = this.ip2long ip

	for row, i in gindex_sorted
		# Filter the data by simply checking against min & max
		if find >= row.min and find <= row.max
			for line, j in row.data
				if find >= line[GEO_FIELD_MIN] and find <= line[GEO_FIELD_MAX]
				 return normalize line

	return null
