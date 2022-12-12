import os
import configparser
from threading import Lock, Thread

class SingletonMeta(type):
    _instances = {}
    _lock: Lock = Lock()

    def __call__(cls, *args, **kwargs):
        with cls._lock:
            if cls not in cls._instances:
                instance = super().__call__(*args, **kwargs)
                cls._instances[cls] = instance

        return cls._instances[cls]

class ConfigFile(metaclass=SingletonMeta):
    def read(self):
        fileDir = os.path.dirname(__file__)
        config = configparser.ConfigParser()
        config_filename = fileDir.replace("utils", "") + 'base.conf'
        config.read(config_filename)
    
        return config
