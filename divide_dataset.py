import sys
import csv

data_file = sys.argv[1] or 'data.csv'

test_bucket = []
buckets = [
	{ 'filename': 'data1.csv', 'rows': [] },
	{ 'filename': 'data2.csv', 'rows': [] },
	{ 'filename': 'data3.csv', 'rows': [] },
	{ 'filename': 'data4.csv', 'rows': [] },
	{ 'filename': 'data5.csv', 'rows': [] },
]

with open(data_file) as data_file:
    reader = csv.DictReader(data_file)
    headers = reader.fieldnames
    for row in reader:
    	transaction_id = row['transaction_id']
    	bucket_index = int(transaction_id) % 5;
    	if bucket_index == 0:
    		buckets[0]['rows'].append(row)
    	elif bucket_index == 1:
    		buckets[1]['rows'].append(row)
    	elif bucket_index == 2:
    		buckets[2]['rows'].append(row)
    	elif bucket_index == 3:
    		buckets[3]['rows'].append(row)
    	else:
    		buckets[4]['rows'].append(row)

minimum_count = min([len(bucket['rows']) for bucket in buckets])

for bucket in buckets:
	num_rows = len(bucket['rows']) - minimum_count
	test_bucket.extend(bucket['rows'][minimum_count:minimum_count+num_rows])
	bucket['rows'] = bucket['rows'][:minimum_count]

for bucket in buckets:
	with open(bucket['filename'], 'w') as file:
		file.write(','.join(headers))
		file.write("\n")
		for line in bucket['rows']:
			columns = []
			for field in headers:
				columns.append(line[field])
			file.write(','.join(columns))
			file.write("\n")

with open('test.csv', 'w') as file:
	file.write(','.join(headers))
	file.write("\n")
	for line in test_bucket:
		columns = []
		for field in headers:
			columns.append(line[field])
		file.write(','.join(columns))
		file.write("\n")











