from flask import Flask, jsonify, request
import random
from datetime import datetime, timedelta

app = Flask(__name__)

# Function to generate realistic random data
def generate_random_data(start_price, num_points, interval):
    data = {}
    current_time = datetime(2024, 5, 15, 16, 0, 0)
    current_price = start_price
    for _ in range(num_points):
        high = current_price * (1 + random.uniform(0, 0.02))
        low = current_price * (1 - random.uniform(0, 0.02))
        close = random.uniform(low, high)
        volume = random.randint(100000, 1000000)
        data[current_time.strftime('%Y-%m-%d %H:%M:%S')] = {
            '1. open': f'{current_price:.2f}',
            '2. high': f'{high:.2f}',
            '3. low': f'{low:.2f}',
            '4. close': f'{close:.2f}',
            '5. volume': str(volume)
        }
        current_price = close
        current_time += timedelta(minutes=interval)
    return data

# Mock data for different time series functions
time_series_data = {
    '1min': {
        '2024-05-15 16:00:00': {'1. open': '150.00', '2. high': '155.00', '3. low': '148.00', '4. close': '152.00', '5. volume': '1000000'},
        '2024-05-15 16:01:00': {'1. open': '152.00', '2. high': '153.00', '3. low': '150.00', '4. close': '151.00', '5. volume': '500000'},
        '2024-05-15 16:02:00': {'1. open': '151.00', '2. high': '154.00', '3. low': '149.00', '4. close': '150.00', '5. volume': '300000'},
        '2024-05-15 16:03:00': {'1. open': '150.00', '2. high': '153.00', '3. low': '148.00', '4. close': '151.00', '5. volume': '200000'},
        '2024-05-15 16:04:00': {'1. open': '151.00', '2. high': '152.00', '3. low': '149.00', '4. close': '150.00', '5. volume': '400000'},
        '2024-05-15 16:05:00': {'1. open': '150.00', '2. high': '151.00', '3. low': '148.00', '4. close': '149.00', '5. volume': '100000'},
        '2024-05-15 16:06:00': {'1. open': '149.00', '2. high': '150.00', '3. low': '147.00', '4. close': '148.00', '5. volume': '200000'},
        '2024-05-15 16:07:00': {'1. open': '148.00', '2. high': '149.00', '3. low': '146.00', '4. close': '147.00', '5. volume': '300000'},
        '2024-05-15 16:08:00': {'1. open': '147.00', '2. high': '148.00', '3. low': '145.00', '4. close': '146.00', '5. volume': '400000'},
        '2024-05-15 16:09:00': {'1. open': '146.00', '2. high': '147.00', '3. low': '144.00', '4. close': '145.00', '5. volume': '500000'},
        '2024-05-15 16:10:00': {'1. open': '145.00', '2. high': '146.00', '3. low': '143.00', '4. close': '144.00', '5. volume': '600000'},
        '2024-05-15 16:11:00': {'1. open': '144.00', '2. high': '145.00', '3. low': '142.00', '4. close': '143.00', '5. volume': '700000'},
        '2024-05-15 16:12:00': {'1. open': '143.00', '2. high': '144.00', '3. low': '141.00', '4. close': '142.00', '5. volume': '800000'},
        '2024-05-15 16:13:00': {'1. open': '142.00', '2. high': '143.00', '3. low': '140.00', '4. close': '141.00', '5. volume': '900000'},
        '2024-05-15 16:14:00': {'1. open': '141.00', '2. high': '142.00', '3. low': '139.00', '4. close': '140.00', '5. volume': '1000000'}
    },
    '5min': {
        '2024-05-15 16:00:00': {'1. open': '150.00', '2. high': '155.00', '3. low': '148.00', '4. close': '152.00', '5. volume': '1000000'},
        '2024-05-15 16:05:00': {'1. open': '152.00', '2. high': '153.00', '3. low': '150.00', '4. close': '151.00', '5. volume': '500000'},
        '2024-05-15 16:10:00': {'1. open': '151.00', '2. high': '154.00', '3. low': '149.00', '4. close': '150.00', '5. volume': '300000'},
        '2024-05-15 16:15:00': {'1. open': '150.00', '2. high': '152.00', '3. low': '148.00', '4. close': '151.00', '5. volume': '200000'},
        '2024-05-15 16:20:00': {'1. open': '151.00', '2. high': '153.00', '3. low': '149.00', '4. close': '150.00', '5. volume': '400000'},
        '2024-05-15 16:25:00': {'1. open': '150.00', '2. high': '151.00', '3. low': '148.00', '4. close': '149.00', '5. volume': '100000'},
        '2024-05-15 16:30:00': {'1. open': '149.00', '2. high': '150.00', '3. low': '147.00', '4. close': '148.00', '5. volume': '200000'},
        '2024-05-15 16:35:00': {'1. open': '148.00', '2. high': '149.00', '3. low': '146.00', '4. close': '147.00', '5. volume': '300000'},
        '2024-05-15 16:40:00': {'1. open': '147.00', '2. high': '148.00', '3. low': '145.00', '4. close': '146.00', '5. volume': '400000'},
        '2024-05-15 16:45:00': {'1. open': '146.00', '2. high': '147.00', '3. low': '144.00', '4. close': '145.00', '5. volume': '500000'},
        '2024-05-15 16:50:00': {'1. open': '145.00', '2. high': '146.00', '3. low': '143.00', '4. close': '144.00', '5. volume': '600000'},
        '2024-05-15 16:55:00': {'1. open': '144.00', '2. high': '145.00', '3. low': '142.00', '4. close': '143.00', '5. volume': '700000'},
        '2024-05-15 17:00:00': {'1. open': '143.00', '2. high': '144.00', '3. low': '141.00', '4. close': '142.00', '5. volume': '800000'},
        '2024-05-15 17:05:00': {'1. open': '142.00', '2. high': '143.00', '3. low': '140.00', '4. close': '141.00', '5. volume': '900000'},
        '2024-05-15 17:10:00': {'1. open': '141.00', '2. high': '142.00', '3. low': '139.00', '4. close': '140.00', '5. volume': '1000000'}
    },
    '15min': {
        '2024-05-15 16:00:00': {'1. open': '150.00', '2. high': '155.00', '3. low': '148.00', '4. close': '152.00', '5. volume': '1000000'},
        '2024-05-15 16:15:00': {'1. open': '152.00', '2. high': '153.00', '3. low': '150.00', '4. close': '151.00', '5. volume': '500000'},
        '2024-05-15 16:30:00': {'1. open': '151.00', '2. high': '154.00', '3. low': '149.00', '4. close': '150.00', '5. volume': '300000'},
        '2024-05-15 16:45:00': {'1. open': '150.00', '2. high': '152.00', '3. low': '148.00', '4. close': '151.00', '5. volume': '200000'},
        '2024-05-15 17:00:00': {'1. open': '151.00', '2. high': '153.00', '3. low': '149.00', '4. close': '150.00', '5. volume': '400000'},
        '2024-05-15 17:15:00': {'1. open': '150.00', '2. high': '151.00', '3. low': '148.00', '4. close': '149.00', '5. volume': '100000'},
        '2024-05-15 17:30:00': {'1. open': '149.00', '2. high': '150.00', '3. low': '147.00', '4. close': '148.00', '5. volume': '200000'},
        '2024-05-15 17:45:00': {'1. open': '148.00', '2. high': '149.00', '3. low': '146.00', '4. close': '147.00', '5. volume': '300000'},
        '2024-05-15 18:00:00': {'1. open': '147.00', '2. high': '148.00', '3. low': '145.00', '4. close': '146.00', '5. volume': '400000'},
        '2024-05-15 18:15:00': {'1. open': '146.00', '2. high': '147.00', '3. low': '144.00', '4. close': '145.00', '5. volume': '500000'},
        '2024-05-15 18:30:00': {'1. open': '145.00', '2. high': '146.00', '3. low': '143.00', '4. close': '144.00', '5. volume': '600000'},
        '2024-05-15 18:45:00': {'1. open': '144.00', '2. high': '145.00', '3. low': '142.00', '4. close': '143.00', '5. volume': '700000'},
        '2024-05-15 19:00:00': {'1. open': '143.00', '2. high': '144.00', '3. low': '141.00', '4. close': '142.00', '5. volume': '800000'},
        '2024-05-15 19:15:00': {'1. open': '142.00', '2. high': '143.00', '3. low': '140.00', '4. close': '141.00', '5. volume': '900000'},
        '2024-05-15 19:30:00': {'1. open': '141.00', '2. high': '142.00', '3. low': '139.00', '4. close': '140.00', '5. volume': '1000000'}
    },
    '30min': {
        '2024-05-15 16:00:00': {'1. open': '150.00', '2. high': '155.00', '3. low': '148.00', '4. close': '152.00', '5. volume': '1000000'},
        '2024-05-15 16:30:00': {'1. open': '152.00', '2. high': '153.00', '3. low': '150.00', '4. close': '151.00', '5. volume': '500000'},
        '2024-05-15 17:00:00': {'1. open': '151.00', '2. high': '154.00', '3. low': '149.00', '4. close': '150.00', '5. volume': '300000'},
        '2024-05-15 17:30:00': {'1. open': '150.00', '2. high': '152.00', '3. low': '148.00', '4. close': '151.00', '5. volume': '200000'},
        '2024-05-15 18:00:00': {'1. open': '151.00', '2. high': '153.00', '3. low': '149.00', '4. close': '150.00', '5. volume': '400000'},
        '2024-05-15 18:30:00': {'1. open': '150.00', '2. high': '151.00', '3. low': '148.00', '4. close': '149.00', '5. volume': '100000'},
        '2024-05-15 19:00:00': {'1. open': '149.00', '2. high': '150.00', '3. low': '147.00', '4. close': '148.00', '5. volume': '200000'},
        '2024-05-15 19:30:00': {'1. open': '148.00', '2. high': '149.00', '3. low': '146.00', '4. close': '147.00', '5. volume': '300000'},
        '2024-05-15 20:00:00': {'1. open': '147.00', '2. high': '148.00', '3. low': '145.00', '4. close': '146.00', '5. volume': '400000'},
        '2024-05-15 20:30:00': {'1. open': '146.00', '2. high': '147.00', '3. low': '144.00', '4. close': '145.00', '5. volume': '500000'},
        '2024-05-15 21:00:00': {'1. open': '145.00', '2. high': '146.00', '3. low': '143.00', '4. close': '144.00', '5. volume': '600000'},
        '2024-05-15 21:30:00': {'1. open': '144.00', '2. high': '145.00', '3. low': '142.00', '4. close': '143.00', '5. volume': '700000'},
        '2024-05-15 22:00:00': {'1. open': '143.00', '2. high': '144.00', '3. low': '141.00', '4. close': '142.00', '5. volume': '800000'},
        '2024-05-15 22:30:00': {'1. open': '142.00', '2. high': '143.00', '3. low': '140.00', '4. close': '141.00', '5. volume': '900000'},
        '2024-05-15 23:00:00': {'1. open': '141.00', '2. high': '142.00', '3. low': '139.00', '4. close': '140.00', '5. volume': '1000000'}
    },
    '60min': {
        '2024-05-15 16:00:00': {'1. open': '150.00', '2. high': '155.00', '3. low': '148.00', '4. close': '152.00', '5. volume': '1000000'},
        '2024-05-15 17:00:00': {'1. open': '152.00', '2. high': '153.00', '3. low': '150.00', '4. close': '151.00', '5. volume': '500000'},
        '2024-05-15 18:00:00': {'1. open': '151.00', '2. high': '154.00', '3. low': '149.00', '4. close': '150.00', '5. volume': '300000'},
        '2024-05-15 19:00:00': {'1. open': '150.00', '2. high': '152.00', '3. low': '148.00', '4. close': '151.00', '5. volume': '200000'},
        '2024-05-15 20:00:00': {'1. open': '151.00', '2. high': '153.00', '3. low': '149.00', '4. close': '150.00', '5. volume': '400000'},
        '2024-05-15 21:00:00': {'1. open': '150.00', '2. high': '151.00', '3. low': '148.00', '4. close': '149.00', '5. volume': '100000'},
        '2024-05-15 22:00:00': {'1. open': '149.00', '2. high': '150.00', '3. low': '147.00', '4. close': '148.00', '5. volume': '200000'},
        '2024-05-15 23:00:00': {'1. open': '148.00', '2. high': '149.00', '3. low': '146.00', '4. close': '147.00', '5. volume': '300000'},
        '2024-05-16 00:00:00': {'1. open': '147.00', '2. high': '148.00', '3. low': '145.00', '4. close': '146.00', '5. volume': '400000'},
        '2024-05-16 01:00:00': {'1. open': '146.00', '2. high': '147.00', '3. low': '144.00', '4. close': '145.00', '5. volume': '500000'},
        '2024-05-16 02:00:00': {'1. open': '145.00', '2. high': '146.00', '3. low': '143.00', '4. close': '144.00', '5. volume': '600000'},
        '2024-05-16 03:00:00': {'1. open': '144.00', '2. high': '145.00', '3. low': '142.00', '4. close': '143.00', '5. volume': '700000'},
        '2024-05-16 04:00:00': {'1. open': '143.00', '2. high': '144.00', '3. low': '141.00', '4. close': '142.00', '5. volume': '800000'},
        '2024-05-16 05:00:00': {'1. open': '142.00', '2. high': '143.00', '3. low': '140.00', '4. close': '141.00', '5. volume': '900000'},
        '2024-05-16 06:00:00': {'1. open': '141.00', '2. high': '142.00', '3. low': '139.00', '4. close': '140.00', '5. volume': '1000000'}
    },
    'daily': {
        '2024-05-01': {'1. open': '148.00', '2. high': '153.00', '3. low': '147.00', '4. close': '150.00', '5. volume': '1200000'},
        '2024-05-02': {'1. open': '150.00', '2. high': '155.00', '3. low': '148.00', '4. close': '152.00', '5. volume': '1000000'},
        '2024-05-03': {'1. open': '152.00', '2. high': '153.00', '3. low': '150.00', '4. close': '151.00', '5. volume': '500000'},
        '2024-05-04': {'1. open': '151.00', '2. high': '152.00', '3. low': '149.00', '4. close': '150.00', '5. volume': '200000'},
        '2024-05-05': {'1. open': '150.00', '2. high': '151.00', '3. low': '148.00', '4. close': '149.00', '5. volume': '100000'},
        '2024-05-06': {'1. open': '149.00', '2. high': '150.00', '3. low': '147.00', '4. close': '148.00', '5. volume': '200000'},
        '2024-05-07': {'1. open': '148.00', '2. high': '149.00', '3. low': '146.00', '4. close': '147.00', '5. volume': '300000'},
        '2024-05-08': {'1. open': '147.00', '2. high': '148.00', '3. low': '145.00', '4. close': '146.00', '5. volume': '400000'},
        '2024-05-09': {'1. open': '146.00', '2. high': '147.00', '3. low': '144.00', '4. close': '145.00', '5. volume': '500000'},
        '2024-05-10': {'1. open': '145.00', '2. high': '146.00', '3. low': '143.00', '4. close': '144.00', '5. volume': '600000'},
        '2024-05-11': {'1. open': '144.00', '2. high': '145.00', '3. low': '142.00', '4. close': '143.00', '5. volume': '700000'},
        '2024-05-12': {'1. open': '143.00', '2. high': '144.00', '3. low': '141.00', '4. close': '142.00', '5. volume': '800000'},
        '2024-05-13': {'1. open': '142.00', '2. high': '143.00', '3. low': '140.00', '4. close': '141.00', '5. volume': '900000'},
        '2024-05-14': {'1. open': '141.00', '2. high': '142.00', '3. low': '139.00', '4. close': '140.00', '5. volume': '1000000'},
        '2024-05-15': {'1. open': '140.00', '2. high': '141.00', '3. low': '138.00', '4. close': '139.00', '5. volume': '1100000'}
    },
    'weekly': {
        '2024-05-01': {'1. open': '148.00', '2. high': '153.00', '3. low': '147.00', '4. close': '150.00', '5. volume': '1200000'},
        '2024-05-08': {'1. open': '150.00', '2. high': '155.00', '3. low': '148.00', '4. close': '152.00', '5. volume': '1000000'},
        '2024-05-15': {'1. open': '152.00', '2. high': '153.00', '3. low': '150.00', '4. close': '151.00', '5. volume': '500000'},
        '2024-05-22': {'1. open': '151.00', '2. high': '152.00', '3. low': '149.00', '4. close': '150.00', '5. volume': '200000'},
        '2024-05-29': {'1. open': '150.00', '2. high': '151.00', '3. low': '148.00', '4. close': '149.00', '5. volume': '100000'},
        '2024-06-05': {'1. open': '149.00', '2. high': '150.00', '3. low': '147.00', '4. close': '148.00', '5. volume': '200000'},
        '2024-06-12': {'1. open': '148.00', '2. high': '149.00', '3. low': '146.00', '4. close': '147.00', '5. volume': '300000'},
        '2024-06-19': {'1. open': '147.00', '2. high': '148.00', '3. low': '145.00', '4. close': '146.00', '5. volume': '400000'},
        '2024-06-26': {'1. open': '146.00', '2. high': '147.00', '3. low': '144.00', '4. close': '145.00', '5. volume': '500000'},
        '2024-07-03': {'1. open': '145.00', '2. high': '146.00', '3. low': '143.00', '4. close': '144.00', '5. volume': '600000'},
        '2024-07-10': {'1. open': '144.00', '2. high': '145.00', '3. low': '142.00', '4. close': '143.00', '5. volume': '700000'},
        '2024-07-17': {'1. open': '143.00', '2. high': '144.00', '3. low': '141.00', '4. close': '142.00', '5. volume': '800000'},
        '2024-07-24': {'1. open': '142.00', '2. high': '143.00', '3. low': '140.00', '4. close': '141.00', '5. volume': '900000'},
        '2024-07-31': {'1. open': '141.00', '2. high': '142.00', '3. low': '139.00', '4. close': '140.00', '5. volume': '1000000'},
        '2024-08-07': {'1. open': '140.00', '2. high': '141.00', '3. low': '138.00', '4. close': '139.00', '5. volume': '1100000'}
    },
    'monthly': {
        '2024-01-31': {'1. open': '140.00', '2. high': '145.00', '3. low': '138.00', '4. close': '142.00', '5. volume': '1400000'},
        '2024-02-29': {'1. open': '142.00', '2. high': '148.00', '3. low': '140.00', '4. close': '145.00', '5. volume': '1300000'},
        '2024-03-31': {'1. open': '145.00', '2. high': '150.00', '3. low': '144.00', '4. close': '148.00', '5. volume': '1200000'},
        '2024-04-30': {'1. open': '148.00', '2. high': '153.00', '3. low': '147.00', '4. close': '150.00', '5. volume': '1100000'},
        '2024-05-31': {'1. open': '150.00', '2. high': '155.00', '3. low': '148.00', '4. close': '152.00', '5. volume': '1000000'},
        '2024-06-30': {'1. open': '152.00', '2. high': '153.00', '3. low': '150.00', '4. close': '151.00', '5. volume': '900000'},
        '2024-07-31': {'1. open': '151.00', '2. high': '152.00', '3. low': '149.00', '4. close': '150.00', '5. volume': '800000'},
        '2024-08-31': {'1. open': '150.00', '2. high': '151.00', '3. low': '148.00', '4. close': '149.00', '5. volume': '700000'},
        '2024-09-30': {'1. open': '149.00', '2. high': '150.00', '3. low': '147.00', '4. close': '148.00', '5. volume': '600000'},
        '2024-10-31': {'1. open': '148.00', '2. high': '149.00', '3. low': '146.00', '4. close': '147.00', '5. volume': '500000'},
        '2024-11-30': {'1. open': '147.00', '2. high': '148.00', '3. low': '145.00', '4. close': '146.00', '5. volume': '400000'},
        '2024-12-31': {'1. open': '146.00', '2. high': '147.00', '3. low': '144.00', '4. close': '145.00', '5. volume': '300000'},
        '2025-01-31': {'1. open': '145.00', '2. high': '146.00', '3. low': '143.00', '4. close': '144.00', '5. volume': '200000'},
        '2025-02-28': {'1. open': '144.00', '2. high': '145.00', '3. low': '142.00', '4. close': '143.00', '5. volume': '100000'}
    }
}

# Mock data for currency exchange rates
currency_exchange_data = {
    ('USD', 'EUR'): {'Exchange Rate': '0.8425', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('USD', 'GBP'): {'Exchange Rate': '0.7192', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('USD', 'JPY'): {'Exchange Rate': '109.53', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('USD', 'CNY'): {'Exchange Rate': '6.4521', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('USD', 'BRL'): {'Exchange Rate': '5.25', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('EUR', 'USD'): {'Exchange Rate': '1.1871', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('EUR', 'GBP'): {'Exchange Rate': '0.8542', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('EUR', 'JPY'): {'Exchange Rate': '130.02', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('EUR', 'CNY'): {'Exchange Rate': '7.6603', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('EUR', 'BRL'): {'Exchange Rate': '6.23', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('GBP', 'USD'): {'Exchange Rate': '1.3902', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('GBP', 'EUR'): {'Exchange Rate': '1.1704', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('GBP', 'JPY'): {'Exchange Rate': '152.16', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('GBP', 'CNY'): {'Exchange Rate': '8.9671', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('GBP', 'BRL'): {'Exchange Rate': '7.37', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('JPY', 'USD'): {'Exchange Rate': '0.0091', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('JPY', 'EUR'): {'Exchange Rate': '0.0077', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('JPY', 'GBP'): {'Exchange Rate': '0.0066', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('JPY', 'CNY'): {'Exchange Rate': '0.0589', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('JPY', 'BRL'): {'Exchange Rate': '0.0484', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('CNY', 'USD'): {'Exchange Rate': '0.155', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('CNY', 'EUR'): {'Exchange Rate': '0.1306', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('CNY', 'GBP'): {'Exchange Rate': '0.1116', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('CNY', 'JPY'): {'Exchange Rate': '16.98', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('CNY', 'BRL'): {'Exchange Rate': '0.818', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('BRL', 'USD'): {'Exchange Rate': '0.1905', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('BRL', 'EUR'): {'Exchange Rate': '0.1606', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('BRL', 'GBP'): {'Exchange Rate': '0.1356', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('BRL', 'JPY'): {'Exchange Rate': '20.65', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
    ('BRL', 'CNY'): {'Exchange Rate': '1.223', 'Last Refreshed': '2024-05-16 14:29:01', 'Time Zone': 'UTC'},
}

# Mock data for detailed company information for SYMBOL_SEARCH
detailed_company_info = {
    "bestMatches": [
        {
            "1. symbol": "AAPL",
            "2. name": "Apple Inc.",
            "3. type": "Equity",
            "4. region": "United States",
            "5. marketOpen": "09:30",
            "6. marketClose": "16:00",
            "7. timezone": "UTC-04",
            "8. currency": "USD",
            "9. matchScore": "1.0000"
        },
        {
            "1. symbol": "MSFT",
            "2. name": "Microsoft Corporation",
            "3. type": "Equity",
            "4. region": "United States",
            "5. marketOpen": "09:30",
            "6. marketClose": "16:00",
            "7. timezone": "UTC-04",
            "8. currency": "USD",
            "9. matchScore": "0.9000"
        },
        {
            "1. symbol": "AMZN",
            "2. name": "Amazon.com Inc.",
            "3. type": "Equity",
            "4. region": "United States",
            "5. marketOpen": "09:30",
            "6. marketClose": "16:00",
            "7. timezone": "UTC-04",
            "8. currency": "USD",
            "9. matchScore": "0.8500"
        },
        {
            "1. symbol": "IBM",
            "2. name": "IBM Corporation",
            "3. type": "Equity",
            "4. region": "United States",
            "5. marketOpen": "09:30",
            "6. marketClose": "16:00",
            "7. timezone": "UTC-04",
            "8. currency": "USD",
            "9. matchScore": "0.8000"
        },
        {
            "1. symbol": "META",
            "2. name": "Meta Platforms Inc.",
            "3. type": "Equity",
            "4. region": "United States",
            "5. marketOpen": "09:30",
            "6. marketClose": "16:00",
            "7. timezone": "UTC-04",
            "8. currency": "USD",
            "9. matchScore": "0.7500"
        }
    ]
}

# Mock data for default companies
default_companies = [
    {'id': 1, 'symbol': 'AAPL', 'name': 'Apple Inc.', 'type': 'Equity', 'value': 148.97, 'isFollowing': False},
    {'id': 2, 'symbol': 'MSFT', 'name': 'Microsoft Corporation', 'type': 'Equity', 'value': 301.87, 'isFollowing': False},
    {'id': 3, 'symbol': 'AMZN', 'name': 'Amazon.com Inc.', 'type': 'Equity', 'value': 3383.87, 'isFollowing': False},
    {'id': 4, 'symbol': 'IBM', 'name': 'IBM Corporation', 'type': 'Equity', 'value': 132.52, 'isFollowing': False},
    {'id': 5, 'symbol': 'META', 'name': 'Meta Platforms Inc.', 'type': 'Equity', 'value': 266.23, 'isFollowing': False},
    {'id': 6, 'symbol': 'GOOGL', 'name': 'Alphabet Inc.', 'type': 'Equity', 'value': 2734.26, 'isFollowing': False},
    {'id': 7, 'symbol': 'HPQ', 'name': 'HP Inc.', 'type': 'Equity', 'value': 30.19, 'isFollowing': False},
    {'id': 8, 'symbol': 'ORCL', 'name': 'Oracle Corporation', 'type': 'Equity', 'value': 89.45, 'isFollowing': False},
    {'id': 9, 'symbol': 'INTC', 'name': 'Intel Corporation', 'type': 'Equity', 'value': 54.76, 'isFollowing': False},
    {'id': 10, 'symbol': 'TSLA', 'name': 'Tesla Inc', 'type': 'Equity', 'value': 688.99, 'isFollowing': False},
    {'id': 11, 'symbol': 'NFLX', 'name': 'Netflix Inc.', 'type': 'Equity', 'value': 515.22, 'isFollowing': False},
    {'id': 12, 'symbol': 'NVDA', 'name': 'NVIDIA Corporation', 'type': 'Equity', 'value': 205.56, 'isFollowing': False},
    {'id': 13, 'symbol': 'BABA', 'name': 'Alibaba Group', 'type': 'Equity', 'value': 222.22, 'isFollowing': False},
    {'id': 14, 'symbol': 'ADBE', 'name': 'Adobe Inc.', 'type': 'Equity', 'value': 572.02, 'isFollowing': False},
    {'id': 15, 'symbol': 'PYPL', 'name': 'PayPal Holdings Inc.', 'type': 'Equity', 'value': 247.73, 'isFollowing': False},
]

# Mock data for news sentiment for multiple companies
news_data = [
    {
        "title": "Top 10 Cryptocurrencies in 2024",
        "url": "https://investingnews.com/daily/tech-investing/blockchain-investing/top-cryptocurrencies/",
        "time_published": "20240513T213000",
        "authors": ["Melissa Pistilli"],
        "summary": "The crypto market is no stranger to intense volatility, making it a risky investment that can work for or against your portfolio. However, you can minimize risk by sticking to the top cryptocurrencies that have earned their place.",
        "banner_image": "https://investingnews.com/media-library/pile-of-cryptocurrencies-including-bitcoin-ethereum-and-litecoin.jpg?id=32409558&width=1200&height=800&quality=85&coordinates=0%2C0%2C0%2C0",
        "source": "Investing News Network",
        "category_within_source": "n/a",
        "source_domain": "investingnews.com",
        "topics": [
            {"topic": "Financial Markets", "relevance_score": "0.818451"},
            {"topic": "Earnings", "relevance_score": "0.360215"},
            {"topic": "Finance", "relevance_score": "1.0"},
            {"topic": "Blockchain", "relevance_score": "0.999999"}
        ],
        "overall_sentiment_score": 0.273052,
        "overall_sentiment_label": "Somewhat-Bullish",
        "ticker_sentiment": [
            {"ticker": "BLK", "relevance_score": "0.024175", "ticker_sentiment_score": "0.203809", "ticker_sentiment_label": "Somewhat-Bullish"},
            {"ticker": "IVZ", "relevance_score": "0.024175", "ticker_sentiment_score": "0.203809", "ticker_sentiment_label": "Somewhat-Bullish"},
            {"ticker": "BRPHF", "relevance_score": "0.024175", "ticker_sentiment_score": "0.203809", "ticker_sentiment_label": "Somewhat-Bullish"},
            {"ticker": "COIN", "relevance_score": "0.048327", "ticker_sentiment_score": "0.118911", "ticker_sentiment_label": "Neutral"},
            {"ticker": "FOREX:USD", "relevance_score": "0.048327", "ticker_sentiment_score": "0.198884", "ticker_sentiment_label": "Somewhat-Bullish"},
            {"ticker": "CRYPTO:BTC", "relevance_score": "0.261117", "ticker_sentiment_score": "0.239289", "ticker_sentiment_label": "Somewhat-Bullish"},
            {"ticker": "CRYPTO:ETH", "relevance_score": "0.214937", "ticker_sentiment_score": "0.210897", "ticker_sentiment_label": "Somewhat-Bullish"},
            {"ticker": "CRYPTO:SHIB", "relevance_score": "0.024175", "ticker_sentiment_score": "0.05075", "ticker_sentiment_label": "Neutral"},
            {"ticker": "CRYPTO:DOGE", "relevance_score": "0.048327", "ticker_sentiment_score": "-0.004983", "ticker_sentiment_label": "Neutral"},
            {"ticker": "CRYPTO:ADA", "relevance_score": "0.096477", "ticker_sentiment_score": "0.128199", "ticker_sentiment_label": "Neutral"}
        ]
    },
    {
        "title": "Bitcoin, Ethereum, Dogecoin Lose Ground, Cannot Back Up Friday's ETF Flows Inflows: 'Bitcoin Is The Escape Hatch'",
        "url": "https://www.benzinga.com/markets/cryptocurrency/24/05/38654240/bitcoin-ethereum-dogecoin-lose-ground-cannot-back-up-fridays-etf-flows-inflows-bitcoin-is-",
        "time_published": "20240506T203214",
        "authors": ["Khyathi Dalal"],
        "summary": "Cryptocurrency markets could not continue their uptrend initiated by surprisingly strong ETF data on Friday. What Happened: Major cryptocurrencies are trading lower at the time of writing: In the past 24 hours, 66,592 traders were liquidated.",
        "banner_image": "https://cdn.benzinga.com/files/images/story/2024/05/06/bitcoin-ai23.png?width=1200&height=800&fit=crop",
        "source": "Benzinga",
        "category_within_source": "Markets",
        "source_domain": "www.benzinga.com",
        "topics": [
            {"topic": "Financial Markets", "relevance_score": "0.650727"},
            {"topic": "Technology", "relevance_score": "0.5"},
            {"topic": "Finance", "relevance_score": "0.5"},
            {"topic": "Blockchain", "relevance_score": "0.310843"}
        ],
        "overall_sentiment_score": 0.153173,
        "overall_sentiment_label": "Somewhat-Bullish",
        "ticker_sentiment": [
            {"ticker": "MSTR", "relevance_score": "0.133841", "ticker_sentiment_score": "0.141935", "ticker_sentiment_label": "Neutral"},
            {"ticker": "COIN", "relevance_score": "0.133841", "ticker_sentiment_score": "0.0", "ticker_sentiment_label": "Neutral"},
            {"ticker": "FOREX:USD", "relevance_score": "0.133841", "ticker_sentiment_score": "-0.208695", "ticker_sentiment_label": "Somewhat-Bearish"},
            {"ticker": "CRYPTO:BTC", "relevance_score": "0.688096", "ticker_sentiment_score": "0.080537", "ticker_sentiment_label": "Neutral"},
            {"ticker": "CRYPTO:ETH", "relevance_score": "0.133841", "ticker_sentiment_score": "0.258325", "ticker_sentiment_label": "Somewhat-Bullish"}
        ]
    },
    {
        "title": "Crypto Market Sees Massive Inflows: Ethereum and Cardano Lead the Charge",
        "url": "https://cryptonews.com/news/crypto-market-sees-massive-inflows-ethereum-cardano-lead-charge.htm",
        "time_published": "20240510T150000",
        "authors": ["John Doe"],
        "summary": "The cryptocurrency market experienced significant inflows this week, with Ethereum and Cardano at the forefront. Analysts believe this trend could continue as more institutional investors enter the space.",
        "banner_image": "https://investingnews.com/media-library/pile-of-cryptocurrencies-including-bitcoin-ethereum-and-litecoin.jpg?id=32409558&width=1200&height=800&quality=85&coordinates=0%2C0%2C0%2C0",
        "source": "Crypto News",
        "category_within_source": "Market Trends",
        "source_domain": "cryptonews.com",
        "topics": [
            {"topic": "Financial Markets", "relevance_score": "0.8"},
            {"topic": "Blockchain", "relevance_score": "0.7"},
            {"topic": "Finance", "relevance_score": "0.9"}
        ],
        "overall_sentiment_score": 0.320584,
        "overall_sentiment_label": "Bullish",
        "ticker_sentiment": [
            {"ticker": "CRYPTO:ETH", "relevance_score": "0.4", "ticker_sentiment_score": "0.5", "ticker_sentiment_label": "Bullish"},
            {"ticker": "CRYPTO:ADA", "relevance_score": "0.3", "ticker_sentiment_score": "0.4", "ticker_sentiment_label": "Bullish"},
            {"ticker": "CRYPTO:BTC", "relevance_score": "0.2", "ticker_sentiment_score": "0.2", "ticker_sentiment_label": "Neutral"}
        ]
    },
    {
        "title": "Bitcoin Faces Resistance at $30,000: What’s Next for the Cryptocurrency?",
        "url": "https://cryptobriefing.com/bitcoin-faces-resistance-at-30000-whats-next-for-the-cryptocurrency/",
        "time_published": "20240515T120000",
        "authors": ["Jane Smith"],
        "summary": "Bitcoin is struggling to break through the $30,000 resistance level. Analysts are divided on whether it will break out or fall back to lower levels.",
        "banner_image": "https://investingnews.com/media-library/pile-of-cryptocurrencies-including-bitcoin-ethereum-and-litecoin.jpg?id=32409558&width=1200&height=800&quality=85&coordinates=0%2C0%2C0%2C0",
        "source": "Crypto Briefing",
        "category_within_source": "Price Analysis",
        "source_domain": "cryptobriefing.com",
        "topics": [
            {"topic": "Financial Markets", "relevance_score": "0.85"},
            {"topic": "Blockchain", "relevance_score": "0.6"},
            {"topic": "Finance", "relevance_score": "0.75"}
        ],
        "overall_sentiment_score": 0.181253,
        "overall_sentiment_label": "Neutral",
        "ticker_sentiment": [
            {"ticker": "CRYPTO:BTC", "relevance_score": "0.7", "ticker_sentiment_score": "0.15", "ticker_sentiment_label": "Neutral"},
            {"ticker": "CRYPTO:ETH", "relevance_score": "0.2", "ticker_sentiment_score": "0.05", "ticker_sentiment_label": "Neutral"}
        ]
    },
    {
        "title": "Ethereum 2.0: A Game Changer for Blockchain Technology",
        "url": "https://coindesk.com/ethereum-2-0-game-changer-blockchain-technology/",
        "time_published": "20240514T100000",
        "authors": ["Alice Brown"],
        "summary": "Ethereum 2.0 is set to revolutionize the blockchain space with its new proof-of-stake consensus mechanism, promising faster and more efficient transactions.",
        "banner_image": "https://investingnews.com/media-library/pile-of-cryptocurrencies-including-bitcoin-ethereum-and-litecoin.jpg?id=32409558&width=1200&height=800&quality=85&coordinates=0%2C0%2C0%2C0",
        "source": "CoinDesk",
        "category_within_source": "Technology",
        "source_domain": "coindesk.com",
        "topics": [
            {"topic": "Technology", "relevance_score": "1.0"},
            {"topic": "Blockchain", "relevance_score": "0.95"},
            {"topic": "Finance", "relevance_score": "0.8"}
        ],
        "overall_sentiment_score": 0.365789,
        "overall_sentiment_label": "Bullish",
        "ticker_sentiment": [
            {"ticker": "CRYPTO:ETH", "relevance_score": "0.9", "ticker_sentiment_score": "0.4", "ticker_sentiment_label": "Bullish"},
            {"ticker": "CRYPTO:BTC", "relevance_score": "0.1", "ticker_sentiment_score": "0.1", "ticker_sentiment_label": "Neutral"}
        ]
    },
    {
        "title": "Ripple Gains Momentum as SEC Lawsuit Nears Conclusion",
        "url": "https://financialtimes.com/ripple-gains-momentum-sec-lawsuit-nears-conclusion/",
        "time_published": "20240509T090000",
        "authors": ["Tom White"],
        "summary": "Ripple's XRP token has seen a surge in value as the long-standing SEC lawsuit appears to be drawing to a close. Investors are optimistic about a favorable outcome.",
        "banner_image": "https://investingnews.com/media-library/pile-of-cryptocurrencies-including-bitcoin-ethereum-and-litecoin.jpg?id=32409558&width=1200&height=800&quality=85&coordinates=0%2C0%2C0%2C0",
        "source": "Financial Times",
        "category_within_source": "Legal",
        "source_domain": "financialtimes.com",
        "topics": [
            {"topic": "Legal Issues", "relevance_score": "1.0"},
            {"topic": "Blockchain", "relevance_score": "0.85"},
            {"topic": "Finance", "relevance_score": "0.9"}
        ],
        "overall_sentiment_score": 0.450982,
        "overall_sentiment_label": "Bullish",
        "ticker_sentiment": [
            {"ticker": "CRYPTO:XRP", "relevance_score": "0.8", "ticker_sentiment_score": "0.5", "ticker_sentiment_label": "Bullish"},
            {"ticker": "CRYPTO:BTC", "relevance_score": "0.1", "ticker_sentiment_score": "0.1", "ticker_sentiment_label": "Neutral"},
            {"ticker": "CRYPTO:ETH", "relevance_score": "0.1", "ticker_sentiment_score": "0.1", "ticker_sentiment_label": "Neutral"}
        ]
    },
    {
        "title": "Litecoin Halving: What Investors Need to Know",
        "url": "https://investopedia.com/litecoin-halving-what-investors-need-to-know/",
        "time_published": "20240512T080000",
        "authors": ["Peter Green"],
        "summary": "The upcoming Litecoin halving event is generating buzz in the crypto community. Experts weigh in on what this could mean for Litecoin's future price and network security.",
        "banner_image": "https://investingnews.com/media-library/pile-of-cryptocurrencies-including-bitcoin-ethereum-and-litecoin.jpg?id=32409558&width=1200&height=800&quality=85&coordinates=0%2C0%2C0%2C0",
        "source": "Investopedia",
        "category_within_source": "Educational",
        "source_domain": "investopedia.com",
        "topics": [
            {"topic": "Technology", "relevance_score": "0.85"},
            {"topic": "Blockchain", "relevance_score": "0.8"},
            {"topic": "Finance", "relevance_score": "0.7"}
        ],
        "overall_sentiment_score": 0.298746,
        "overall_sentiment_label": "Somewhat-Bullish",
        "ticker_sentiment": [
            {"ticker": "CRYPTO:LTC", "relevance_score": "0.9", "ticker_sentiment_score": "0.3", "ticker_sentiment_label": "Somewhat-Bullish"},
            {"ticker": "CRYPTO:BTC", "relevance_score": "0.1", "ticker_sentiment_score": "0.1", "ticker_sentiment_label": "Neutral"}
        ]
    },
    {
        "title": "Dogecoin Surges After Elon Musk's Tweet",
        "url": "https://marketwatch.com/dogecoin-surges-after-elon-musks-tweet/",
        "time_published": "20240508T070000",
        "authors": ["Linda Johnson"],
        "summary": "Dogecoin saw a significant price increase following a tweet from Elon Musk. The Tesla CEO's influence on the cryptocurrency market continues to be strong.",
        "banner_image": "https://investingnews.com/media-library/pile-of-cryptocurrencies-including-bitcoin-ethereum-and-litecoin.jpg?id=32409558&width=1200&height=800&quality=85&coordinates=0%2C0%2C0%2C0",
        "source": "MarketWatch",
        "category_within_source": "Social Media",
        "source_domain": "marketwatch.com",
        "topics": [
            {"topic": "Social Media", "relevance_score": "1.0"},
            {"topic": "Blockchain", "relevance_score": "0.7"},
            {"topic": "Finance", "relevance_score": "0.6"}
        ],
        "overall_sentiment_score": 0.412563,
        "overall_sentiment_label": "Bullish",
        "ticker_sentiment": [
            {"ticker": "CRYPTO:DOGE", "relevance_score": "0.9", "ticker_sentiment_score": "0.4", "ticker_sentiment_label": "Bullish"},
            {"ticker": "CRYPTO:BTC", "relevance_score": "0.05", "ticker_sentiment_score": "0.1", "ticker_sentiment_label": "Neutral"},
            {"ticker": "CRYPTO:ETH", "relevance_score": "0.05", "ticker_sentiment_score": "0.1", "ticker_sentiment_label": "Neutral"}
        ]
    }
]

# Mock data for news sentiment for a single company
single_company_news_data = [
    {
        "title": "Huawei Vs Apple: The Retail War Escalates In China - Apple  ( NASDAQ:AAPL )",
        "url": "https://www.benzinga.com/markets/asia/24/05/38837611/huawei-vs-apple-the-retail-war-escalates-in-china",
        "time_published": "20240515T100823",
        "authors": ["Benzinga Neuro"],
        "summary": "Despite U.S. sanctions, Huawei Technologies Co is making a bold move to reclaim its position in the premium electronics market in China. The company is aggressively expanding its retail presence, posing a direct challenge to Apple Inc AAPL. What Happened: Huawei has opened four flagship stores in ...",
        "banner_image": "https://cdn.benzinga.com/files/images/story/2024/05/15/Huawei.jpeg?width=1200&height=800&fit=crop",
        "source": "Benzinga",
        "category_within_source": "Markets",
        "source_domain": "www.benzinga.com",
        "topics": [
            {"topic": "Earnings", "relevance_score": "0.158519"},
            {"topic": "Technology", "relevance_score": "0.5"},
            {"topic": "Manufacturing", "relevance_score": "0.5"}
        ],
        "overall_sentiment_score": 0.116797,
        "overall_sentiment_label": "Neutral",
        "ticker_sentiment": [
            {"ticker": "QCOM", "relevance_score": "0.07913", "ticker_sentiment_score": "-0.099508", "ticker_sentiment_label": "Neutral"},
            {"ticker": "AAPL", "relevance_score": "0.380591", "ticker_sentiment_score": "0.098041", "ticker_sentiment_label": "Neutral"},
            {"ticker": "INTC", "relevance_score": "0.07913", "ticker_sentiment_score": "-0.099508", "ticker_sentiment_label": "Neutral"}
        ]
    },
    {
        "title": "Why Is Everyone Talking About Apple Stock?",
        "url": "https://www.fool.com/investing/2024/05/15/why-is-everyone-talking-about-apple-stock/",
        "time_published": "20240515T091500",
        "authors": ["CFA", "Parkev Tatevosian"],
        "summary": "Apple announced a massive share buyback program, receiving significant chatter in the investing community.",
        "banner_image": "https://g.foolcdn.com/editorial/images/777358/stock-market-person-studying-computer.jpg",
        "source": "Motley Fool",
        "category_within_source": "n/a",
        "source_domain": "www.fool.com",
        "topics": [
            {"topic": "Technology", "relevance_score": "1.0"}
        ],
        "overall_sentiment_score": -0.383535,
        "overall_sentiment_label": "Bearish",
        "ticker_sentiment": [
            {"ticker": "AAPL", "relevance_score": "0.876064", "ticker_sentiment_score": "-0.86822", "ticker_sentiment_label": "Bearish"}
        ]
    },
    {
        "title": "Apple's New iPhone 15: Features and Expectations",
        "url": "https://www.techradar.com/news/apple-new-iphone-15-features-expectations",
        "time_published": "20240514T110000",
        "authors": ["Sarah Perez"],
        "summary": "Apple is set to release its new iPhone 15, boasting impressive features and advancements. Industry experts are weighing in on what this means for the market.",
        "banner_image": "https://cdn.benzinga.com/files/images/story/2024/05/15/Huawei.jpeg?width=1200&height=800&fit=crop",
        "source": "TechRadar",
        "category_within_source": "Technology",
        "source_domain": "www.techradar.com",
        "topics": [
            {"topic": "Technology", "relevance_score": "0.95"},
            {"topic": "Manufacturing", "relevance_score": "0.5"},
            {"topic": "Consumer Electronics", "relevance_score": "0.9"}
        ],
        "overall_sentiment_score": 0.312584,
        "overall_sentiment_label": "Bullish",
        "ticker_sentiment": [
            {"ticker": "AAPL", "relevance_score": "0.876064", "ticker_sentiment_score": "0.36822", "ticker_sentiment_label": "Bullish"}
        ]
    },
    {
        "title": "Apple Faces Antitrust Challenges in the EU",
        "url": "https://www.reuters.com/technology/apple-faces-antitrust-challenges-eu-2024-05-13/",
        "time_published": "20240513T150000",
        "authors": ["Foo Bar"],
        "summary": "The European Union has launched a new antitrust investigation into Apple's App Store practices, which could result in significant fines and operational changes.",
        "banner_image": "https://cdn.benzinga.com/files/images/story/2024/05/15/Huawei.jpeg?width=1200&height=800&fit=crop",
        "source": "Reuters",
        "category_within_source": "Regulation",
        "source_domain": "www.reuters.com",
        "topics": [
            {"topic": "Regulation", "relevance_score": "1.0"},
            {"topic": "Technology", "relevance_score": "0.8"},
            {"topic": "Finance", "relevance_score": "0.7"}
        ],
        "overall_sentiment_score": -0.289312,
        "overall_sentiment_label": "Bearish",
        "ticker_sentiment": [
            {"ticker": "AAPL", "relevance_score": "0.876064", "ticker_sentiment_score": "-0.26822", "ticker_sentiment_label": "Bearish"}
        ]
    },
    {
        "title": "Apple Expands into AR: What Investors Need to Know",
        "url": "https://www.cnbc.com/apple-expands-into-ar-what-investors-need-to-know/",
        "time_published": "20240512T080000",
        "authors": ["John Smith"],
        "summary": "Apple's latest push into augmented reality (AR) technology has the potential to revolutionize the industry. Investors are keen to see how this will impact Apple's stock price.",
        "banner_image": "https://cdn.benzinga.com/files/images/story/2024/05/15/Huawei.jpeg?width=1200&height=800&fit=crop",
        "source": "CNBC",
        "category_within_source": "Technology",
        "source_domain": "www.cnbc.com",
        "topics": [
            {"topic": "Technology", "relevance_score": "0.95"},
            {"topic": "Finance", "relevance_score": "0.7"},
            {"topic": "Consumer Electronics", "relevance_score": "0.8"}
        ],
        "overall_sentiment_score": 0.412563,
        "overall_sentiment_label": "Bullish",
        "ticker_sentiment": [
            {"ticker": "AAPL", "relevance_score": "0.876064", "ticker_sentiment_score": "0.46822", "ticker_sentiment_label": "Bullish"}
        ]
    },
    {
        "title": "Apple's Q2 Earnings: Beating Expectations",
        "url": "https://www.forbes.com/apples-q2-earnings-beating-expectations/",
        "time_published": "20240511T090000",
        "authors": ["Mary Johnson"],
        "summary": "Apple reported its Q2 earnings, which surpassed analysts' expectations. The strong performance is attributed to robust iPhone sales and increased services revenue.",
        "banner_image": "https://cdn.benzinga.com/files/images/story/2024/05/15/Huawei.jpeg?width=1200&height=800&fit=crop",
        "source": "Forbes",
        "category_within_source": "Finance",
        "source_domain": "www.forbes.com",
        "topics": [
            {"topic": "Earnings", "relevance_score": "1.0"},
            {"topic": "Finance", "relevance_score": "0.9"},
            {"topic": "Technology", "relevance_score": "0.8"}
        ],
        "overall_sentiment_score": 0.384745,
        "overall_sentiment_label": "Bullish",
        "ticker_sentiment": [
            {"ticker": "AAPL", "relevance_score": "0.876064", "ticker_sentiment_score": "0.36822", "ticker_sentiment_label": "Bullish"}
        ]
    },
    {
        "title": "Apple's New MacBook Air: Reviews and Market Impact",
        "url": "https://www.theverge.com/2024/05/10/apple-new-macbook-air-reviews-market-impact/",
        "time_published": "20240510T070000",
        "authors": ["Linda Brown"],
        "summary": "The latest MacBook Air has hit the market with positive reviews highlighting its performance and design. This launch is expected to boost Apple's market share in the laptop segment.",
        "banner_image": "https://cdn.benzinga.com/files/images/story/2024/05/15/Huawei.jpeg?width=1200&height=800&fit=crop",
        "source": "The Verge",
        "category_within_source": "Technology",
        "source_domain": "www.theverge.com",
        "topics": [
            {"topic": "Consumer Electronics", "relevance_score": "1.0"},
            {"topic": "Technology", "relevance_score": "0.9"},
            {"topic": "Finance", "relevance_score": "0.8"}
        ],
        "overall_sentiment_score": 0.294735,
        "overall_sentiment_label": "Somewhat-Bullish",
        "ticker_sentiment": [
            {"ticker": "AAPL", "relevance_score": "0.876064", "ticker_sentiment_score": "0.26822", "ticker_sentiment_label": "Somewhat-Bullish"}
        ]
    },
    {
        "title": "Apple's Environmental Initiatives: Progress and Challenges",
        "url": "https://www.bbc.com/news/apple-environmental-initiatives-progress-challenges/",
        "time_published": "20240509T060000",
        "authors": ["Mark Green"],
        "summary": "Apple continues to make strides in its environmental initiatives, focusing on sustainability and reducing its carbon footprint. However, challenges remain in achieving its ambitious goals.",
        "banner_image": "https://cdn.benzinga.com/files/images/story/2024/05/15/Huawei.jpeg?width=1200&height=800&fit=crop",
        "source": "BBC News",
        "category_within_source": "Environment",
        "source_domain": "www.bbc.com",
        "topics": [
            {"topic": "Environment", "relevance_score": "1.0"},
            {"topic": "Technology", "relevance_score": "0.8"},
            {"topic": "Corporate Responsibility", "relevance_score": "0.9"}
        ],
        "overall_sentiment_score": 0.256347,
        "overall_sentiment_label": "Somewhat-Bullish",
        "ticker_sentiment": [
            {"ticker": "AAPL", "relevance_score": "0.876064", "ticker_sentiment_score": "0.26822", "ticker_sentiment_label": "Somewhat-Bullish"}
        ]
    },
    {
        "title": "Apple Car Rumors: What We Know So Far",
        "url": "https://www.autonews.com/2024/05/08/apple-car-rumors-what-we-know-so-far/",
        "time_published": "20240508T050000",
        "authors": ["Peter White"],
        "summary": "Speculation about Apple's entry into the automotive market continues to grow. Industry insiders provide insights into the potential features and timeline of the rumored Apple Car.",
        "banner_image": "https://cdn.benzinga.com/files/images/story/2024/05/15/Huawei.jpeg?width=1200&height=800&fit=crop",
        "source": "Automotive News",
        "category_within_source": "Automotive",
        "source_domain": "www.autonews.com",
        "topics": [
            {"topic": "Automotive", "relevance_score": "1.0"},
            {"topic": "Technology", "relevance_score": "0.9"},
            {"topic": "Finance", "relevance_score": "0.8"}
        ],
        "overall_sentiment_score": 0.312584,
        "overall_sentiment_label": "Bullish",
        "ticker_sentiment": [
            {"ticker": "AAPL", "relevance_score": "0.876064", "ticker_sentiment_score": "0.36822", "ticker_sentiment_label": "Bullish"}
        ]
    },
    {
        "title": "Apple's Supply Chain Challenges Amid Global Chip Shortage",
        "url": "https://www.wsj.com/articles/apple-supply-chain-challenges-global-chip-shortage/",
        "time_published": "20240507T040000",
        "authors": ["Julia Blue"],
        "summary": "The global chip shortage is impacting Apple's supply chain, leading to potential delays in product releases. Analysts discuss how this could affect Apple's market performance.",
        "banner_image": "https://cdn.benzinga.com/files/images/story/2024/05/15/Huawei.jpeg?width=1200&height=800&fit=crop",
        "source": "The Wall Street Journal",
        "category_within_source": "Supply Chain",
        "source_domain": "www.wsj.com",
        "topics": [
            {"topic": "Supply Chain", "relevance_score": "1.0"},
            {"topic": "Technology", "relevance_score": "0.8"},
            {"topic": "Finance", "relevance_score": "0.7"}
        ],
        "overall_sentiment_score": -0.198745,
        "overall_sentiment_label": "Somewhat-Bearish",
        "ticker_sentiment": [
            {"ticker": "AAPL", "relevance_score": "0.876064", "ticker_sentiment_score": "-0.26822", "ticker_sentiment_label": "Somewhat-Bearish"}
        ]
    }
]


@app.route('/query', methods=['GET'])
def query():
    function = request.args.get('function')
    symbol = request.args.get('symbol')
    interval = request.args.get('interval')
    
    # Log the request parameters
    app.logger.debug(f"Received request with Function: {function}, Symbol: {symbol}, Interval: {interval}")

    if function == 'SYMBOL_SEARCH':
        return symbol_search()
    elif function == 'GLOBAL_QUOTE':
        return global_quote()
    elif function == 'NEWS_SENTIMENT':
        return news_sentiment()
    elif function == 'CURRENCY_EXCHANGE_RATE':
        return currency_exchange_rate()
    elif function in ['TIME_SERIES_INTRADAY', 'TIME_SERIES_DAILY', 'TIME_SERIES_WEEKLY', 'TIME_SERIES_MONTHLY']:
         if symbol == 'ORCL':
            return jsonify({'infor': 'Test'}), 200
         if symbol == 'HPQ':
            return jsonify({'infor': 'Test'}), 400
         return time_series(function, symbol, interval)
    else:
        app.logger.error(f"Invalid function: {function}")
        return jsonify({'error': 'Invalid function provided.'}), 400

def symbol_search():
    keywords = request.args.get('keywords')
    if not keywords:
        return jsonify({'error': 'Keywords parameter is missing'}), 400
    # Check if the keywords match any of the company symbols to return the detailed company info
    matched_companies = [company for company in detailed_company_info['bestMatches'] if keywords.lower() in company['1. symbol'].lower() or keywords.lower() in company['2. name'].lower()]
    if matched_companies:
        return jsonify({'bestMatches': matched_companies})
    results = [company for company in default_companies if keywords.lower() in company['symbol'].lower() or keywords.lower() in company['name'].lower()]
    return jsonify({'bestMatches': results})

def global_quote():
    symbol = request.args.get('symbol')
    if not symbol:
        return jsonify({'error': 'Symbol parameter is missing'}), 400
    for company in default_companies:
        if company['symbol'] == symbol:
            return jsonify({
                'Global Quote': {
                    '01. symbol': company['symbol'],
                    '02. open': '150.00',
                    '03. high': '155.00',
                    '04. low': '148.00',
                    '05. price': str(company['value']),
                    '06. volume': '1000000',
                    '07. latest trading day': '2024-05-15',
                    '08. previous close': '149.00',
                    '09. change': str(company['value'] - 149.00),
                    '10. change percent': f"{(company['value'] - 149.00) / 149.00 * 100:.2f}%"
                }
            })
    return jsonify({'error': 'Symbol not found'}), 404

def news_sentiment():
    tickers = request.args.get('tickers')
    if not tickers:
        return jsonify({'error': 'Tickers parameter is missing'}), 400

    ticker_list = tickers.split(',')
    if len(ticker_list) > 1:
        return jsonify({
            "items": "20",
            "sentiment_score_definition": "x <= -0.35: Bearish; -0.35 < x <= -0.15: Somewhat-Bearish; -0.15 < x < 0.15: Neutral; 0.15 <= x < 0.35: Somewhat_Bullish; x >= 0.35: Bullish",
            "relevance_score_definition": "0 < x <= 1, with a higher score indicating higher relevance.",
            "feed": news_data
        })
    else:
        return jsonify({
            "items": "50",
            "sentiment_score_definition": "x <= -0.35: Bearish; -0.35 < x <= -0.15: Somewhat-Bearish; -0.15 < x < 0.15: Neutral; 0.15 <= x < 0.35: Somewhat_Bullish; x >= 0.35: Bullish",
            "relevance_score_definition": "0 < x <= 1, with a higher score indicating higher relevance.",
            "feed": single_company_news_data
        })
        
def currency_exchange_rate():
    from_currency = request.args.get('from_currency')
    to_currency = request.args.get('to_currency')
    if not from_currency or not to_currency:
        return jsonify({'error': 'from_currency or to_currency parameter is missing'}), 400

    exchange_rate_info = currency_exchange_data.get((from_currency, to_currency))
    if not exchange_rate_info:
        return jsonify({'error': f'Exchange rate data for {from_currency} to {to_currency} not found'}), 404
    
    return jsonify({
        'Realtime Currency Exchange Rate': {
            '1. From_Currency Code': from_currency,
            '2. From_Currency Name': from_currency,
            '3. To_Currency Code': to_currency,
            '4. To_Currency Name': to_currency,
            '5. Exchange Rate': exchange_rate_info['Exchange Rate'],
            '6. Last Refreshed': exchange_rate_info['Last Refreshed'],
            '7. Time Zone': exchange_rate_info['Time Zone'],
            '8. Bid Price': str(float(exchange_rate_info['Exchange Rate']) - 0.0001),
            '9. Ask Price': str(float(exchange_rate_info['Exchange Rate']) + 0.0001)
        }
    })

'''
def time_series(function):
    symbol = request.args.get('symbol')
    interval = request.args.get('interval')
    if not symbol:
        app.logger.error('Symbol parameter is missing')
        return jsonify({'error': 'Symbol parameter is missing'}), 400
    
    if function == 'TIME_SERIES_INTRADAY':
        if not interval:
            app.logger.error('Interval parameter is missing')
            return jsonify({'error': 'Interval parameter is missing'}), 400
        if interval not in time_series_data:
            app.logger.error(f'Interval {interval} is not available')
            return jsonify({'error': f'Interval {interval} is not available'}), 400
        return jsonify({'Time Series ({}min)'.format(interval): time_series_data[interval]})
    elif function == 'TIME_SERIES_DAILY':
        return jsonify({'Time Series (Daily)': time_series_data['daily']})
    elif function == 'TIME_SERIES_WEEKLY':
        return jsonify({'Time Series (Weekly)': time_series_data['weekly']})
    elif function == 'TIME_SERIES_MONTHLY':
        return jsonify({'Time Series (Monthly)': time_series_data['monthly']})
    else:
        app.logger.error(f"Invalid function inside time_series: {function}")
        return jsonify({'error': 'Invalid function inside time_series.'}), 400
'''

def time_series(function, symbol, interval):
    if not symbol:
        app.logger.error('Symbol parameter is missing')
        return jsonify({'error': 'Symbol parameter is missing'}), 400
    
    # Define the number of data points for each interval
    interval_map = {
        '1min': (1, 15),
        '5min': (5, 15),
        '15min': (15, 15),
        '30min': (30, 15),
        '60min': (60, 15),
        'daily': (1440, 30),
        'weekly': (10080, 12),
        'monthly': (43200, 12)
    }

    if function == 'TIME_SERIES_INTRADAY' and interval:
        if interval not in interval_map:
            app.logger.error(f'Interval {interval} is not available')
            return jsonify({'error': f'Interval {interval} is not available'}), 400
        time_delta, num_points = interval_map[interval]
    else:
        if function == 'TIME_SERIES_DAILY':
            time_delta, num_points = interval_map['daily']
        elif function == 'TIME_SERIES_WEEKLY':
            time_delta, num_points = interval_map['weekly']
        elif function == 'TIME_SERIES_MONTHLY':
            time_delta, num_points = interval_map['monthly']
        else:
            app.logger.error(f"Invalid function inside time_series: {function}")
            return jsonify({'error': 'Invalid function inside time_series.'}), 400

    start_price = next((company['value'] for company in default_companies if company['symbol'] == symbol), None)
    if start_price is None:
        return jsonify({'error': 'Symbol not found'}), 404

    generated_data = generate_random_data(start_price, num_points, time_delta)

    if function == 'TIME_SERIES_INTRADAY':
        return jsonify({'Time Series ({}min)'.format(interval): generated_data})
    elif function == 'TIME_SERIES_DAILY':
        return jsonify({'Time Series (Daily)': generated_data})
    elif function == 'TIME_SERIES_WEEKLY':
        return jsonify({'Time Series (Weekly)': generated_data})
    elif function == 'TIME_SERIES_MONTHLY':
        return jsonify({'Time Series (Monthly)': generated_data})
    else:
        return jsonify({'error': 'Invalid function inside time_series.'}), 400



if __name__ == '__main__':
    app.run(debug=True)
