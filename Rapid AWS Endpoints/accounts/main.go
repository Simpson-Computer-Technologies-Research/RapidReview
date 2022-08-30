package main

import (
	"aws-rapid-accounts/handlers"
	"database/sql"
	"net/http"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	_ "github.com/go-sql-driver/mysql"
)

func main() {
	var db, _ = sql.Open("mysql", "database")
	defer db.Close()

	lambda.Start(func(req events.APIGatewayProxyRequest) (*events.APIGatewayProxyResponse, error) {
		if req.HTTPMethod == "GET" {
			if _, ok := req.QueryStringParameters["state"]; ok {
				return handlers.AccountLinkTokenHandler(req, db)
			} else if _, ok := req.QueryStringParameters["auth_token"]; ok {
				return handlers.DiscordRedirectHandler(req)
			}
			return handlers.GetLinkedAccounts(req, db)
		} else if req.HTTPMethod == "DELETE" {
			return handlers.DeleteLinkedAccount(req, db)
		}
		return handlers.ApiResponse(http.StatusMethodNotAllowed, "method not allowed")
	})
}
