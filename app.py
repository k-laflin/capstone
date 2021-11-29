import random
from flask import Flask

# generate new background color
R = random.randint(0, 255)
G = random.randint(0, 255)
B = random.randint(0, 255)
#rgb = [r,g,b]
#print('A Random color is :',rgb)

#create new background html
HELLO = """
    <html style="background-color:rgb({}, {}, {});">
    <head>
    <title>Flask Tutorial</title>
    </head>
    <body>
    <h1> Hello World!</h1>
    </body>
    </html>  
""".format(R, G, B)

print(HELLO)

INDEX = open('index.html', 'w')
INDEX.write(HELLO)
INDEX.close()

APP = Flask(__name__)

@APP.route('/')
def index():
    return 'Hello World!'
APP.run(host='0.0.0.0', port=81)
