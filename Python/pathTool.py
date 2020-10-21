
import os

def currentUserHome():
    return os.environ['HOME']

def pathAppend(path, mainPath = currentUserHome()):
    if path.startswith("/"):
        return f"{mainPath}{path}"
    else:
        return f"{mainPath}/{path}"
