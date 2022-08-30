package main

import (
	handlers "aws-rapid-roles/handlers"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func main() {
	lambda.Start(func(req events.APIGatewayProxyRequest) (*events.APIGatewayProxyResponse, error) {
		if req.HTTPMethod == "PUT" || req.HTTPMethod == "DELETE" {
			return handlers.EditRole(req)
		}
		return handlers.ApiResponse(405, "method not allowed")
	})
}
