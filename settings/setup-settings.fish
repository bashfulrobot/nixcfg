#!/usr/bin/env fish

# Check if template.json exists
if test -f template.json
    # Copy template.json to digdug.json, dustinkrysak.json, and qbert.json
    cp template.json digdug.json
    cp template.json dustinkrysak.json
    cp template.json qbert.json

    # Update username and home in dustinkrysak.json
    jq '.user.username = "dustin.krysak" | .user.home = "/Users/dustin.krysak"' dustinkrysak.json > dustinkrysak.tmp.json
    mv dustinkrysak.tmp.json dustinkrysak.json
else
    echo "template.json not found in settings directory."
end
