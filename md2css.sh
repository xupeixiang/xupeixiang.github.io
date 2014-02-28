#! /bin/bash

sed -i '' "s/\*\*\([^\*]*\)\*\*/<span id='edu'>\1<\/span>/g" _posts/*
