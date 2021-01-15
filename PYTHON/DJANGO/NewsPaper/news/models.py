from django.db import models # импорт

class Autor(models.Model): # наследуемся от класса Model
    pass


class Category(models.Model): #
    pass

class Post(models.Model): #
    autor =
    text =
    date =
    header =
    category =
    pass

class PostCategory(models.Model): #
    name = models.CharField(max_length = 255)
    pass

class Comment(models.Model): #
    autor =
    text =
    pass

class Product(models.Model):
    name = models.CharField(max_length = 255)
    price = models.FloatField(default = 0.0)