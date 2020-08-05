#!/usr/bin/env bash
RESOURCE_GROUP=$(az group list --query "[0].name" -o tsv)
TA_ACCT_NAME="TweetAnalytics"
TA_LOCATION=$(shuf -n1 -e $(az cognitiveservices account list-skus --query "[?tier=='Free' && kind=='TextAnalytics'].locations[]" | jq -r '.[]' | sed '/EUAP$/d'))
echo "Creating Text Analytics account..."
az cognitiveservices account create --name "$TA_ACCT_NAME" --resource-group "$RESOURCE_GROUP" --kind TextAnalytics --sku F0 --location "$TA_LOCATION" --yes
TA_KEY=$(az cognitiveservices account keys list --name $TA_ACCT_NAME --resource-group "$RESOURCE_GROUP" --query key1 -o tsv)
TA_ENDPOINT=$(az cognitiveservices account show --name $TA_ACCT_NAME --resource-group "$RESOURCE_GROUP" --query properties.endpoint -o tsv)
echo "Done!"
echo
echo "Make a note of the following values for use in the rest of this exercise:"
echo
echo "Cognitive Services account key: $TA_KEY"
echo
echo "Cognitive Services account endpoint: $TA_ENDPOINT"
echo
