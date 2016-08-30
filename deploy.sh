#!/bin/bash -e

R=`dirname $0`

set -x

for f in fonts img js; do
    aws s3 sync $R/larry/$f s3://www.ogrodnek.com/larry/$f --cache-control max-age=3600 --profile ogrodnek
done

aws s3 sync $R/larry/css s3://www.ogrodnek.com/larry/css --cache-control max-age=600 --profile ogrodnek
aws s3 sync $R/ s3://www.ogrodnek.com/ --exclude "*" --include "*.html" --cache-control max-age=600 --profile ogrodnek


# Cloudfront invalidation of main HTML
INVALIDATION_ID=$(date +"%s")
INVALIDATION_JSON="{
    \"DistributionId\": \"E35REUJVRNXBPX\",
    \"InvalidationBatch\": {
        \"Paths\": {
            \"Quantity\": 2,
            \"Items\": [
                \"/index.html\",
                \"/larry/index.html\"
            ]
        },
        \"CallerReference\": \"$INVALIDATION_ID\"
    }
}"

aws cloudfront create-invalidation --cli-input-json "$INVALIDATION_JSON" --profile ogrodnek
