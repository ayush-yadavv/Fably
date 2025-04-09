from flask_wtf import FlaskForm
from wtforms import StringField, TextAreaField, DecimalField, IntegerField, FileField, SubmitField
from wtforms.validators import DataRequired

class AddItemForm(FlaskForm):
    name = StringField('Name', validators=[DataRequired()])
    description = TextAreaField('Description', validators=[DataRequired()])
    price = DecimalField('Price ($)', validators=[DataRequired()])
    photos = FileField('Photos')
    category = StringField('Category', validators=[DataRequired()])
    stock_quantity = IntegerField('Stock Quantity', validators=[DataRequired()])
    submit = SubmitField('Add Item')
