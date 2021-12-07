import random
from flask import Flask
from flask import render_template

# generate new background color
R = random.randint(0, 255)
G = random.randint(0, 255)
B = random.randint(0, 255)
#rgb = [r,g,b]
#print('A Random color is :',rgb)

#create new background html
hello = """
    <html style="background-color:rgb({}, {}, {});">
    <head>
    <title>Flask Tutorial</title>
    </head>
    <body>
    <h1> Hello World v3!</h1>
    </body>
    </html>  
""".format(R, G, B)

print(hello)

INDEX = open('templates/index.html', 'w')
INDEX.write(hello)
INDEX.close()

APP = Flask(__name__)

@APP.route('/')
def index():
    return render_template('index.html')
APP.run(host='0.0.0.0', port=81)
