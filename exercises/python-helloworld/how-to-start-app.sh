#!/bin/bash

#First method
python app.python

#Second method
export Flask_APP=app
export FLASK_ENV=development
flask run