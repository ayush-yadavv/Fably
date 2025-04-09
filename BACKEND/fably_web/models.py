from flask_login import UserMixin
from datetime import datetime
from bson import ObjectId

class Seller(UserMixin):
    def __init__(self, seller_data):
        self.id = str(seller_data.get('_id'))
        self.name = seller_data.get('name')
        self.email = seller_data.get('email')
        self.phone = seller_data.get('phone')
        self.created_date = seller_data.get('created_date')

    def get_id(self):
        return self.id