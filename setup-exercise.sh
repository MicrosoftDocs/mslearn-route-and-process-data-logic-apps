#!/usr/bin/env bash
RESOURCE_GROUP=$(az group list --query "[0].name" -o tsv)
TA_ACCT_NAME="TweetAnalytics"
TA_LOCATION=$(shuf -n1 -e $(az cognitiveservices account list-skus --query "[?tier=='Free' && kind=='TextAnalytics'].locations[]" | jq -r '.[]' | sed '/EUAP$/d'))
echo "Creating Text Analytics account..."
az cognitiveservices account create --name "$TA_ACCT_NAME" --resource-group "$RESOURCE_GROUP" --kind TextAnalytics --sku F0 --location "$TA_LOCATION" --yes
TA_KEY=$(az cognitiveservices account keys list --name $TA_ACCT_NAME --resource-group "$RESOURCE_GROUP" --query key1 -o tsv)
TA_ENDPOINT=$(az cognitiveservices account show --name $TA_ACCT_NAME --resource-group "$RESOURCE_GROUP" --query endpoint -o tsv)
SQL_LOCATION=$(az group show --name "$RESOURCE_GROUP" --query location -o tsv)
SQL_LOCATION=WESTUS
SQL_SERVERNAME="mslearn-exercise-sqlserver-$(openssl rand -hex 5)"
SQL_PWD="Ab#1$(openssl rand -hex 10)"
SQL_USERNAME=sqladmin
SQL_DBNAME=PositiveTweetDatabase
echo
echo "Creating SQL Server..."
az sql server create --name "$SQL_SERVERNAME" --resource-group "$RESOURCE_GROUP" --location "$SQL_LOCATION" --admin-user "$SQL_USERNAME" --admin-password "$SQL_PWD"
az sql server firewall-rule create --resource-group "$RESOURCE_GROUP" --server "$SQL_SERVERNAME" --name AllowAzureServices --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
az sql db create --name "$SQL_DBNAME" --resource-group "$RESOURCE_GROUP" --server "$SQL_SERVERNAME" --edition Basic
sqlcmd -S "$SQL_SERVERNAME.database.windows.net" -d "$SQL_DBNAME" -U "$SQL_USERNAME" -P "$SQL_PWD" -Q "CREATE TABLE dbo.Mentions ( id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY, Content NVARCHAR(500) NULL, Source NVARCHAR(500) NULL );"
echo
echo "Done!"
echo
echo "Make a note of the following values for use in the rest of this exercise:"
echo
echo "Cognitive Services account key: $TA_KEY"
echo
echo "Cognitive Services account endpoint: $TA_ENDPOINT"
echo
echo "SQL Server name: $SQL_SERVERNAME"
echo
echo "SQL username: $SQL_USERNAME"
echo
echo "SQL password: $SQL_PWD"
echo
echo "SQL database name: $SQL_DBNAME"
echo
