#  Autor by Lander (c) 2021. Created for Standart-N LLT
import logging
import os
import datetime
from logging.handlers import TimedRotatingFileHandler
_log_format = f"%(asctime)s - [%(levelname)s] (%(filename)s).%(funcName)s(%(lineno)d) - %(message)s"
datefmt='%m-%d %H:%M'
directory = './log/'



def get_file_handler(name):
    date=datetime.datetime.now().strftime('%Y%m%d%H%M')
    filename = f"./log/{date}loggi_{name}.log"
    file_handler = logging.FileHandler(filename)
    file_handler.setLevel(logging.INFO)
    file_handler.setFormatter(logging.Formatter(_log_format,datefmt=datefmt))
    return file_handler

def get_stream_handler():
    stream_handler = logging.StreamHandler()
    stream_handler.setLevel(logging.INFO)
    stream_handler.setFormatter(logging.Formatter(_log_format,datefmt=datefmt))
    return stream_handler

def get_logger(name):
    logger = logging.getLogger(name)
    logger.setLevel(logging.INFO)
    logger.addHandler(get_file_handler(name))
    logger.addHandler(get_stream_handler())
    return logger
