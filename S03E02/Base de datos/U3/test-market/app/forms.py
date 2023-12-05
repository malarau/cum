# -*- encoding: utf-8 -*-
"""
Copyright (c) 2019 - present AppSeed.us
"""

from flask_wtf import FlaskForm
from wtforms import IntegerField, StringField, PasswordField, SubmitField
from wtforms.validators import Email, DataRequired

# login and registration


class LoginForm(FlaskForm):
    username = StringField('Username',
                         id='username_login',
                         validators=[DataRequired()])
    password = PasswordField('Password',
                             id='pwd_login',
                             validators=[DataRequired()])


class CreateAccountForm(FlaskForm):
    username = StringField('Username',
                         id='username_create',
                         validators=[DataRequired()])
    email = StringField('Email',
                      id='email_create',
                      validators=[DataRequired(), Email()])
    password = PasswordField('Password',
                             id='pwd_create',
                             validators=[DataRequired()])
    
class AgregarProducto(FlaskForm):
    nombre_producto = StringField('Nombre del Producto')
    cantidad = IntegerField('Cantidad')
    marca = StringField('Marca')
    submit = SubmitField('Agregar')

class ModificarProductoForm(FlaskForm):
    nombre_producto = StringField('Nombre del Producto', validators=[DataRequired()])
    cantidad = IntegerField('Cantidad', validators=[DataRequired()])
    marca = StringField('Marca', validators=[DataRequired()])
    guardar_cambios = SubmitField('Guardar Cambios')
