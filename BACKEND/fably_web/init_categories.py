from pymongo import MongoClient
from datetime import datetime
import os

MONGO_URI = os.environ.get('MONGO_URI')
client = MongoClient(MONGO_URI)
db = client['fably_db']

clothing_categories = [
    {
        "name": "Men's Clothing",
        "created_at": datetime.utcnow()
    },
    {
        "name": "Women's Clothing",
        "created_at": datetime.utcnow()
    },
    {
        "name": "Kids' Clothing",
        "created_at": datetime.utcnow()
    },
    {
        "name": "Accessories",
        "created_at": datetime.utcnow()
    },
    {
        "name": "Footwear",
        "created_at": datetime.utcnow()
    }
]

try:
    db.categories.drop()
    result = db.categories.insert_many(clothing_categories)
    print(f"Successfully inserted {len(result.inserted_ids)} categories!")
except Exception as e:
    print(f"An error occurred: {e}")
finally:
    client.close()